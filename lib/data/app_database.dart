import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Table and column names.
abstract final class Db {
  static const String fileName = 'fee_optimizer.db';

  /// v1: providers + fee_intervals, v2: currencies, v3: fee_type,
  /// v4: foreign keys, index on fee_intervals.provider_id, unused tables
  /// removed, v5: currencies removed (amounts are shown without currency),
  /// v6: operation and source of each grid, app_meta table.
  static const int version = 6;

  static const String providers = 'providers';
  static const String feeIntervals = 'fee_intervals';
  static const String meta = 'app_meta';

  static const String id = 'id';
  static const String creationDatetime = 'creation_datetime';

  static const String name = 'name';
  static const String description = 'description';
  static const String iconName = 'icon_name';
  static const String operation = 'operation';
  static const String sourceUrl = 'source_url';
  static const String sourceType = 'source_type';
  static const String effectiveDate = 'effective_date';
  static const String key = 'key';
  static const String value = 'value';

  static const String providerId = 'provider_id';
  static const String minAmount = 'min_amount';
  static const String maxAmount = 'max_amount';
  static const String fee = 'fee';
  static const String feeType = 'fee_type';
}

/// Single access point to the SQLite database.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Future<Database>? _database;

  /// Incremented after every write to providers or fee intervals, so screens
  /// can reload (they listen to it).
  static final ValueNotifier<int> changes = ValueNotifier(0);

  static void notifyChanged() => changes.value++;

  /// Lazily opened database. Concurrent callers share the same opening
  /// future, so the file is never opened twice.
  Future<Database> get database => _database ??= _open();

  /// Uses another database (tests).
  void overrideDatabase(Future<Database> database) => _database = database;

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), Db.fileName);
    return openDatabase(
      path,
      version: Db.version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: createSchema,
      onUpgrade: upgradeSchema,
    );
  }

  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Db.providers} (
        ${Db.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Db.name} TEXT NOT NULL,
        ${Db.description} TEXT NOT NULL,
        ${Db.iconName} TEXT DEFAULT 'business',
        ${Db.creationDatetime} INTEGER NOT NULL,
        ${Db.operation} TEXT,
        ${Db.sourceUrl} TEXT,
        ${Db.sourceType} TEXT,
        ${Db.effectiveDate} TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Db.feeIntervals} (
        ${Db.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Db.providerId} INTEGER NOT NULL,
        ${Db.minAmount} REAL NOT NULL,
        ${Db.maxAmount} REAL NOT NULL,
        ${Db.fee} REAL NOT NULL,
        ${Db.feeType} INTEGER DEFAULT 0,
        ${Db.creationDatetime} INTEGER NOT NULL,
        FOREIGN KEY (${Db.providerId})
        REFERENCES ${Db.providers} (${Db.id})
        ON DELETE CASCADE
      )
    ''');
    await _createIndexes(db);
    await _createMeta(db);
  }

  static Future<void> upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 3) {
      final columns = await db.rawQuery(
        'PRAGMA table_info(${Db.feeIntervals})',
      );
      final hasFeeType = columns.any((c) => c['name'] == Db.feeType);
      if (!hasFeeType) {
        await db.execute(
          'ALTER TABLE ${Db.feeIntervals} ADD COLUMN ${Db.feeType} INTEGER DEFAULT 0',
        );
      }
    }
    if (oldVersion < 4) {
      // These tables were created by earlier versions but never used.
      await db.execute('DROP TABLE IF EXISTS optimization_details');
      await db.execute('DROP TABLE IF EXISTS optimization_results');
      // Intervals left behind by providers deleted while foreign keys were
      // disabled.
      await db.execute(
        'DELETE FROM ${Db.feeIntervals} WHERE ${Db.providerId} NOT IN '
        '(SELECT ${Db.id} FROM ${Db.providers})',
      );
      await _createIndexes(db);
    }
    if (oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS currencies');
    }
    if (oldVersion < 6) {
      for (final column in [
        Db.operation,
        Db.sourceUrl,
        Db.sourceType,
        Db.effectiveDate,
      ]) {
        await db.execute('ALTER TABLE ${Db.providers} ADD COLUMN $column TEXT');
      }
      await _createMeta(db);
    }
  }

  static Future<void> _createMeta(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS ${Db.meta} (
      ${Db.key} TEXT PRIMARY KEY,
      ${Db.value} TEXT
    )
  ''');

  /// Small key/value store kept with the data (e.g. seed version).
  Future<String?> getMeta(String key) async {
    final db = await database;
    final rows = await db.query(
      Db.meta,
      where: '${Db.key} = ?',
      whereArgs: [key],
    );
    return rows.isEmpty ? null : rows.first[Db.value] as String?;
  }

  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert(Db.meta, {
      Db.key: key,
      Db.value: value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> _createIndexes(Database db) => db.execute(
    'CREATE INDEX IF NOT EXISTS idx_fee_intervals_provider '
    'ON ${Db.feeIntervals} (${Db.providerId})',
  );
}
