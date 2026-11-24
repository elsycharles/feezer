import 'package:sqflite/sqflite.dart';

import '../model/fee_operation.dart';
import '../model/provider_model.dart';
import 'app_database.dart';

/// Persistence of [Provider]s.
class ProviderRepository {
  ProviderRepository([AppDatabase? database])
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Provider>> getAll({DatabaseExecutor? executor}) async {
    final db = executor ?? await _database.database;
    final rows = await db.query(Db.providers, orderBy: Db.id);
    return rows.map(Provider.fromMap).toList();
  }

  /// Grid of operator [name] for [operation] (case-insensitive name; a `null`
  /// operation matches grids without operation), excluding [excludeId].
  Future<Provider?> findByName(
    String name, {
    FeeOperation? operation,
    String? excludeId,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _database.database;
    // sqflite does not accept null arguments: test NULL in the query itself.
    final rows = await db.query(
      Db.providers,
      where: operation == null
          ? 'LOWER(TRIM(${Db.name})) = ? AND ${Db.operation} IS NULL'
          : 'LOWER(TRIM(${Db.name})) = ? AND ${Db.operation} = ?',
      whereArgs: [name.trim().toLowerCase(), ?operation?.key],
    );
    for (final row in rows) {
      final provider = Provider.fromMap(row);
      if (provider.id != excludeId) return provider;
    }
    return null;
  }

  /// Inserts [provider] and returns it with its database id.
  Future<Provider> insert(
    Provider provider, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _database.database;
    final map = Provider.toMap(provider)..remove(Db.id);
    final id = await db.insert(Db.providers, map);
    if (executor == null) AppDatabase.notifyChanged();
    return provider.copyWith(id: id.toString());
  }

  Future<void> update(Provider provider, {DatabaseExecutor? executor}) async {
    final db = executor ?? await _database.database;
    await db.update(
      Db.providers,
      Provider.toMap(provider),
      where: '${Db.id} = ?',
      whereArgs: [int.tryParse(provider.id)],
    );
    if (executor == null) AppDatabase.notifyChanged();
  }

  /// Marks a downloaded grid as changed by the user (its source stays known).
  Future<void> markEdited(String id, {DatabaseExecutor? executor}) async {
    final db = executor ?? await _database.database;
    await db.update(
      Db.providers,
      {Db.sourceType: Provider.editedSource},
      where: '${Db.id} = ? AND ${Db.sourceType} IS NOT NULL',
      whereArgs: [int.tryParse(id)],
    );
    if (executor == null) AppDatabase.notifyChanged();
  }

  /// Runs [action] in a database transaction.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await _database.database;
    final result = await db.transaction(action);
    AppDatabase.notifyChanged();
    return result;
  }

  /// Deletes providers and their fee intervals atomically.
  Future<void> delete(Iterable<String> ids) async {
    final parsed = ids.map(int.tryParse).whereType<int>().toList();
    if (parsed.isEmpty) return;
    final db = await _database.database;
    final placeholders = List.filled(parsed.length, '?').join(',');
    await db.transaction((txn) async {
      await txn.delete(
        Db.feeIntervals,
        where: '${Db.providerId} IN ($placeholders)',
        whereArgs: parsed,
      );
      await txn.delete(
        Db.providers,
        where: '${Db.id} IN ($placeholders)',
        whereArgs: parsed,
      );
    });
    AppDatabase.notifyChanged();
  }
}
