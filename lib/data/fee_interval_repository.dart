import 'package:sqflite/sqflite.dart';

import '../model/fee_interval_model.dart';
import 'app_database.dart';

/// Persistence of [FeeInterval]s.
class FeeIntervalRepository {
  FeeIntervalRepository([AppDatabase? database])
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Intervals of a provider, sorted by minimum amount.
  Future<List<FeeInterval>> getByProvider(
    String providerId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _database.database;
    final rows = await db.query(
      Db.feeIntervals,
      where: '${Db.providerId} = ?',
      whereArgs: [int.tryParse(providerId)],
      orderBy: '${Db.minAmount}, ${Db.maxAmount}',
    );
    return rows.map(FeeInterval.fromMap).toList();
  }

  /// Number of intervals and cheapest fixed fee per provider id.
  Future<Map<String, ({int count, double? minFee})>> summaries() async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT ${Db.providerId} AS p, COUNT(*) AS c, '
      'MIN(CASE WHEN ${Db.feeType} = 0 THEN ${Db.fee} END) AS f '
      'FROM ${Db.feeIntervals} GROUP BY ${Db.providerId}',
    );
    return {
      for (final row in rows)
        '${row['p']}': (
          count: (row['c'] as num).toInt(),
          minFee: (row['f'] as num?)?.toDouble(),
        ),
    };
  }

  /// First interval of the provider overlapping [candidate] (ignoring the
  /// interval being edited, [candidate.id]), or `null`.
  Future<FeeInterval?> findOverlap(
    String providerId,
    FeeInterval candidate, {
    DatabaseExecutor? executor,
  }) async {
    final existing = await getByProvider(providerId, executor: executor);
    for (final interval in existing) {
      if (candidate.id != null && interval.id == candidate.id) continue;
      if (interval.overlaps(candidate)) return interval;
    }
    return null;
  }

  /// Inserts [interval] and returns it with its database id.
  Future<FeeInterval> insert(
    FeeInterval interval,
    String providerId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _database.database;
    final map = FeeInterval.toMap(interval, providerId)..remove(Db.id);
    final id = await db.insert(Db.feeIntervals, map);
    if (executor == null) AppDatabase.notifyChanged();
    return interval.copyWith(id: id.toString());
  }

  Future<void> update(FeeInterval interval, String providerId) async {
    final db = await _database.database;
    await db.update(
      Db.feeIntervals,
      FeeInterval.toMap(interval, providerId),
      where: '${Db.id} = ?',
      whereArgs: [int.tryParse(interval.id ?? '')],
    );
    AppDatabase.notifyChanged();
  }

  /// Replaces every interval of the provider with [intervals].
  Future<void> replaceAll(
    String providerId,
    List<FeeInterval> intervals, {
    required DatabaseExecutor executor,
  }) async {
    await executor.delete(
      Db.feeIntervals,
      where: '${Db.providerId} = ?',
      whereArgs: [int.tryParse(providerId)],
    );
    for (final interval in intervals) {
      await insert(interval, providerId, executor: executor);
    }
  }

  Future<void> delete(Iterable<String> ids) async {
    final parsed = ids.map(int.tryParse).whereType<int>().toList();
    if (parsed.isEmpty) return;
    final db = await _database.database;
    await db.delete(
      Db.feeIntervals,
      where: '${Db.id} IN (${List.filled(parsed.length, '?').join(',')})',
      whereArgs: parsed,
    );
    AppDatabase.notifyChanged();
  }
}
