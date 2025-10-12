import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'constant_util.dart';

class DatabaseUtil {
  static final DatabaseUtil _instance = DatabaseUtil._internal();
  factory DatabaseUtil() => _instance;
  DatabaseUtil._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), ConstantUtil.databaseName);
    
    return await openDatabase(
      path,
      version: ConstantUtil.databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${ConstantUtil.tableProviders} (
        ${ConstantUtil.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ConstantUtil.columnName} TEXT NOT NULL,
        ${ConstantUtil.columnDescription} TEXT NOT NULL,
        ${ConstantUtil.columnIconName} TEXT DEFAULT 'business',
        ${ConstantUtil.columnCreationDatetime} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ConstantUtil.tableFeeIntervals} (
        ${ConstantUtil.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ConstantUtil.columnProviderId} INTEGER NOT NULL,
        ${ConstantUtil.columnMinAmount} REAL NOT NULL,
        ${ConstantUtil.columnMaxAmount} REAL NOT NULL,
        ${ConstantUtil.columnFee} REAL NOT NULL,
        ${ConstantUtil.columnFeeType} INTEGER DEFAULT 0,
        ${ConstantUtil.columnCreationDatetime} INTEGER NOT NULL,
        FOREIGN KEY (${ConstantUtil.columnProviderId}) 
        REFERENCES ${ConstantUtil.tableProviders} (${ConstantUtil.columnId})
        ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ConstantUtil.tableOptimizationResults} (
        ${ConstantUtil.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ConstantUtil.columnTotalAmount} REAL NOT NULL,
        ${ConstantUtil.columnNetAmount} REAL NOT NULL,
        ${ConstantUtil.columnTotalFees} REAL NOT NULL,
        ${ConstantUtil.columnRemaining} REAL NOT NULL,
        ${ConstantUtil.columnEfficiency} REAL NOT NULL,
        ${ConstantUtil.columnCreationDatetime} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ConstantUtil.tableOptimizationDetails} (
        ${ConstantUtil.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ConstantUtil.columnResultId} INTEGER NOT NULL,
        ${ConstantUtil.columnAmount} REAL NOT NULL,
        ${ConstantUtil.columnFee} REAL NOT NULL,
        ${ConstantUtil.columnCount} INTEGER NOT NULL,
        FOREIGN KEY (${ConstantUtil.columnResultId}) 
        REFERENCES ${ConstantUtil.tableOptimizationResults} (${ConstantUtil.columnId})
        ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ConstantUtil.tableCurrencies} (
        ${ConstantUtil.columnId} TEXT PRIMARY KEY,
        ${ConstantUtil.columnCode} TEXT NOT NULL UNIQUE,
        ${ConstantUtil.columnName} TEXT NOT NULL,
        ${ConstantUtil.columnSymbol} TEXT NOT NULL,
        ${ConstantUtil.columnRate} REAL NOT NULL,
        ${ConstantUtil.columnCreationDatetime} INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration vers la version 2 : ajout de la table currencies
      await db.execute('''
        CREATE TABLE ${ConstantUtil.tableCurrencies} (
          ${ConstantUtil.columnId} TEXT PRIMARY KEY,
          ${ConstantUtil.columnCode} TEXT NOT NULL UNIQUE,
          ${ConstantUtil.columnName} TEXT NOT NULL,
          ${ConstantUtil.columnSymbol} TEXT NOT NULL,
          ${ConstantUtil.columnRate} REAL NOT NULL,
          ${ConstantUtil.columnCreationDatetime} INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      // Migration vers la version 3 : ajout de la colonne fee_type si elle n'existe pas
      final tableInfo = await db.rawQuery('PRAGMA table_info(${ConstantUtil.tableFeeIntervals})');
      final hasFeeTypeColumn = tableInfo.any((column) => column['name'] == ConstantUtil.columnFeeType);
      
      if (!hasFeeTypeColumn) {
        await db.execute('ALTER TABLE ${ConstantUtil.tableFeeIntervals} ADD COLUMN ${ConstantUtil.columnFeeType} INTEGER DEFAULT 0');
      }
    }
  }

  // Méthodes génériques de base de données
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}