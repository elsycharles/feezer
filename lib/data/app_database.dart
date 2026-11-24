import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../util/provider_data.dart';

/// Table and column names.
abstract final class Db {
  static const String fileName = 'fee_optimizer.db';

  /// v1: providers + fee_intervals, v2: currencies, v3: fee_type,
  /// v4: foreign keys, index on fee_intervals.provider_id, unused tables
  /// removed.
  static const int version = 4;

  static const String providers = 'providers';
  static const String feeIntervals = 'fee_intervals';
  static const String currencies = 'currencies';

  static const String id = 'id';
  static const String creationDatetime = 'creation_datetime';

  static const String name = 'name';
  static const String description = 'description';
  static const String iconName = 'icon_name';

  static const String providerId = 'provider_id';
  static const String minAmount = 'min_amount';
  static const String maxAmount = 'max_amount';
  static const String fee = 'fee';
  static const String feeType = 'fee_type';

  static const String code = 'code';
  static const String symbol = 'symbol';
  static const String rate = 'rate';
}

/// Single access point to the SQLite database.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Future<Database>? _database;

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
        ${Db.creationDatetime} INTEGER NOT NULL
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
    await _createCurrencies(db);
    await _createIndexes(db);
  }

  static Future<void> upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) await _createCurrencies(db);
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
  }

  static Future<void> _createCurrencies(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS ${Db.currencies} (
      ${Db.id} TEXT PRIMARY KEY,
      ${Db.code} TEXT NOT NULL UNIQUE,
      ${Db.name} TEXT NOT NULL,
      ${Db.symbol} TEXT NOT NULL,
      ${Db.rate} REAL NOT NULL,
      ${Db.creationDatetime} INTEGER NOT NULL
    )
  ''');

  static Future<void> _createIndexes(Database db) => db.execute(
    'CREATE INDEX IF NOT EXISTS idx_fee_intervals_provider '
    'ON ${Db.feeIntervals} (${Db.providerId})',
  );

  /// Inserts the default providers on first launch (empty providers table).
  Future<void> seedDefaultData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${Db.providers}'),
    );
    if ((count ?? 0) > 0) return;

    await db.transaction((txn) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final provider in ProviderData.defaultProviders) {
        final providerId = await txn.insert(Db.providers, {
          Db.name: provider.name,
          Db.description: provider.description,
          Db.iconName: provider.iconName,
          Db.creationDatetime: now,
        });
        final batch = txn.batch();
        for (final interval in provider.feeIntervals) {
          batch.insert(Db.feeIntervals, {
            Db.providerId: providerId,
            Db.minAmount: interval.minAmount,
            Db.maxAmount: interval.maxAmount,
            Db.fee: interval.fee,
            Db.feeType: interval.feeType.index,
            Db.creationDatetime: now,
          });
        }
        await batch.commit(noResult: true);
      }
    });
  }
}
