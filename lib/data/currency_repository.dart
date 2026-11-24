import 'package:sqflite/sqflite.dart';

import '../model/currency_model.dart';
import 'app_database.dart';

/// Persistence of [Currency] definitions.
class CurrencyRepository {
  CurrencyRepository([AppDatabase? database])
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static final List<Currency> defaults = [
    Currency(id: 'eur', code: 'EUR', name: 'Euro', symbol: '€', rate: 5200),
    Currency(id: 'mga', code: Currency.baseCode, name: 'Ariary', symbol: 'Ar'),
    Currency(
      id: 'usd',
      code: 'USD',
      name: 'US Dollar',
      symbol: r'$',
      rate: 4478.8,
    ),
  ];

  Future<List<Currency>> getAll() async {
    final db = await _database.database;
    final rows = await db.query(Db.currencies, orderBy: 'rowid');
    return rows.map(Currency.fromMap).toList();
  }

  Future<Currency?> getById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      Db.currencies,
      where: '${Db.id} = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : Currency.fromMap(rows.first);
  }

  Future<Currency?> getByCode(String code) async {
    final db = await _database.database;
    final rows = await db.query(
      Db.currencies,
      where: 'UPPER(${Db.code}) = ?',
      whereArgs: [code.toUpperCase()],
    );
    return rows.isEmpty ? null : Currency.fromMap(rows.first);
  }

  /// Inserts the default currencies that are missing (always guarantees the
  /// base currency exists).
  Future<void> ensureDefaults({required bool includeOptional}) async {
    final db = await _database.database;
    for (final currency in defaults) {
      if (!includeOptional && !currency.isBase) continue;
      await db.insert(
        Db.currencies,
        currency.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Inserts [currency]; throws [DatabaseException] if the code exists.
  Future<void> insert(Currency currency) async {
    final db = await _database.database;
    await db.insert(Db.currencies, currency.toMap());
  }

  Future<void> update(Currency currency) async {
    final db = await _database.database;
    await db.update(
      Db.currencies,
      currency.toMap(),
      where: '${Db.id} = ?',
      whereArgs: [currency.id],
    );
  }

  /// Deletes currencies; the base currency is never deleted.
  Future<void> delete(Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    final db = await _database.database;
    await db.delete(
      Db.currencies,
      where:
          '${Db.id} IN (${List.filled(list.length, '?').join(',')}) '
          'AND UPPER(${Db.code}) != ?',
      whereArgs: [...list, Currency.baseCode],
    );
  }
}
