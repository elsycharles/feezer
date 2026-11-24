import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../model/fee_interval_model.dart';
import '../model/fee_operation.dart';
import '../model/provider_model.dart';
import 'fee_interval_repository.dart';
import 'provider_repository.dart';

/// A fee grid as published online.
class RemoteGrid {
  const RemoteGrid({
    required this.name,
    required this.operation,
    required this.description,
    required this.iconName,
    required this.intervals,
    this.sourceUrl,
    this.sourceType,
    this.effectiveDate,
  });

  final String name;
  final FeeOperation? operation;
  final String description;
  final String iconName;
  final List<FeeInterval> intervals;
  final String? sourceUrl;
  final String? sourceType;
  final DateTime? effectiveDate;
}

/// Fee grids published online (see the feezer-fee-tables repository).
class RemoteFeeTables {
  const RemoteFeeTables({
    required this.updatedAt,
    required this.grids,
    this.checkedAt,
  });

  /// Last time a grid changed.
  final DateTime? updatedAt;

  /// Last time the official websites were read.
  final DateTime? checkedAt;
  final List<RemoteGrid> grids;
}

/// What an update changes.
class FeeUpdatePlan {
  const FeeUpdatePlan({
    required this.tables,
    required this.created,
    required this.updated,
    required this.unchanged,
  });

  final RemoteFeeTables tables;
  final List<RemoteGrid> created;
  final List<RemoteGrid> updated;
  final List<RemoteGrid> unchanged;

  bool get hasChanges => created.isNotEmpty || updated.isNotEmpty;
}

/// Downloads the official fee grids and applies them to the database.
///
/// The grids are read every day from the operators' websites by the
/// feezer-fee-tables repository, which publishes them as JSON.
class FeeTableService {
  FeeTableService({
    http.Client? client,
    ProviderRepository? providers,
    FeeIntervalRepository? intervals,
    this.url = defaultUrl,
  }) : _client = client,
       _providers = providers ?? ProviderRepository(),
       _intervals = intervals ?? FeeIntervalRepository();

  static const String defaultUrl =
      'https://raw.githubusercontent.com/elsycharles/feezer-fee-tables/main/fees.json';
  static const String _lastUpdateKey = 'fee_tables_last_update';
  static const String _checkedAtKey = 'fee_tables_checked_at';

  final http.Client? _client;
  final ProviderRepository _providers;
  final FeeIntervalRepository _intervals;
  final String url;

  /// Date of the last successful update, if any.
  static Future<DateTime?> lastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastUpdateKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Date the official websites were last read (as published).
  static Future<DateTime?> lastCheck() async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.tryParse(prefs.getString(_checkedAtKey) ?? '');
  }

  /// Downloads and validates the grids. Throws on network or format errors.
  Future<RemoteFeeTables> fetch() async {
    final client = _client ?? http.Client();
    try {
      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw http.ClientException(
          'HTTP ${response.statusCode}',
          Uri.parse(url),
        );
      }
      return parse(utf8.decode(response.bodyBytes));
    } finally {
      if (_client == null) client.close();
    }
  }

  /// Parses and validates a fee table document (schema 1 or 2).
  static RemoteFeeTables parse(String source) {
    final json = jsonDecode(source);
    if (json is! Map<String, dynamic> || json['providers'] is! List) {
      throw const FormatException('Missing "providers" list');
    }
    final grids = <RemoteGrid>[];
    final keys = <String>{};
    for (final entry in json['providers'] as List) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Invalid provider entry');
      }
      final name = (entry['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) throw const FormatException('Grid without name');
      final operation = FeeOperation.fromKey(entry['operation'] as String?);
      if (entry['operation'] != null && operation == null) {
        continue; // operation unknown to this version of the app
      }
      if (!keys.add('${name.toLowerCase()}|${operation?.key}')) {
        throw FormatException('Duplicate grid $name ${operation?.key}');
      }
      final intervals = <FeeInterval>[];
      for (final raw in (entry['intervals'] as List?) ?? const []) {
        if (raw is! Map<String, dynamic>) {
          throw FormatException('Invalid interval for $name');
        }
        final interval = FeeInterval(
          minAmount: (raw['min'] as num?)?.toDouble(),
          maxAmount: (raw['max'] as num?)?.toDouble(),
          fee: (raw['fee'] as num?)?.toDouble(),
          feeType: raw['type'] == 'percentage'
              ? FeeType.percentage
              : FeeType.fixed,
        );
        if (!interval.isValid) {
          throw FormatException('Invalid interval for $name: $raw');
        }
        if (intervals.any(interval.overlaps)) {
          throw FormatException('Overlapping intervals for $name');
        }
        intervals.add(interval);
      }
      final source = entry['source'];
      grids.add(
        RemoteGrid(
          name: name,
          operation: operation,
          description: (entry['description'] as String?) ?? '',
          iconName: (entry['icon'] as String?) ?? 'business',
          intervals: intervals,
          sourceUrl: source is Map ? source['url'] as String? : null,
          sourceType: source is Map ? source['type'] as String? : null,
          effectiveDate: source is Map
              ? DateTime.tryParse('${source['effectiveDate'] ?? ''}')
              : null,
        ),
      );
    }
    return RemoteFeeTables(
      updatedAt: DateTime.tryParse('${json['updatedAt']}'),
      checkedAt: DateTime.tryParse('${json['checkedAt']}'),
      grids: grids,
    );
  }

  /// Compares the downloaded grids with the local ones.
  Future<FeeUpdatePlan> plan(RemoteFeeTables tables) async {
    final created = <RemoteGrid>[];
    final updated = <RemoteGrid>[];
    final unchanged = <RemoteGrid>[];
    for (final remote in tables.grids) {
      final local = await _providers.findByName(
        remote.name,
        operation: remote.operation,
      );
      if (local == null) {
        created.add(remote);
        continue;
      }
      final current = await _intervals.getByProvider(local.id);
      (_sameGrid(current, remote.intervals) ? unchanged : updated).add(remote);
    }
    return FeeUpdatePlan(
      tables: tables,
      created: created,
      updated: updated,
      unchanged: unchanged,
    );
  }

  /// Applies the grids: unknown grids are created; existing grids get the new
  /// intervals and source, unless [onlyMissing]. Grids not listed are kept.
  Future<void> apply(
    RemoteFeeTables tables, {
    bool onlyMissing = false,
    bool remember = true,
  }) async {
    await _providers.transaction((txn) async {
      for (final remote in tables.grids) {
        await _applyGrid(remote, txn, onlyMissing: onlyMissing);
      }
    });
    if (!remember) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    final checked = tables.checkedAt;
    if (checked != null) {
      await prefs.setString(_checkedAtKey, checked.toIso8601String());
    }
  }

  /// Records the check date of grids that were already up to date.
  static Future<void> rememberCheck(RemoteFeeTables tables) async {
    final checked = tables.checkedAt;
    if (checked == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkedAtKey, checked.toIso8601String());
  }

  Future<void> _applyGrid(
    RemoteGrid remote,
    Transaction txn, {
    required bool onlyMissing,
  }) async {
    final existing = await _providers.findByName(
      remote.name,
      operation: remote.operation,
      executor: txn,
    );
    if (existing != null && onlyMissing) return;
    final Provider provider;
    if (existing == null) {
      provider = await _providers.insert(
        Provider(
          id: '',
          name: remote.name,
          description: remote.description,
          iconName: remote.iconName,
          operation: remote.operation,
          sourceUrl: remote.sourceUrl,
          sourceType: remote.sourceType,
          effectiveDate: remote.effectiveDate,
        ),
        executor: txn,
      );
    } else {
      provider = existing.copyWith(
        sourceUrl: remote.sourceUrl,
        sourceType: remote.sourceType,
        effectiveDate: remote.effectiveDate,
      );
      await _providers.update(provider, executor: txn);
    }
    await _intervals.replaceAll(provider.id, remote.intervals, executor: txn);
  }

  static bool _sameGrid(List<FeeInterval> a, List<FeeInterval> b) {
    String key(FeeInterval i) =>
        '${i.minAmount}|${i.maxAmount}|${i.fee}|${i.feeType.index}';
    final left = a.map(key).toList()..sort();
    final right = b.map(key).toList()..sort();
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }
}
