import 'package:flutter/services.dart';

import '../model/fee_interval_model.dart';
import 'app_database.dart';
import 'fee_interval_repository.dart';
import 'fee_table_service.dart';
import 'legacy_defaults.dart';
import 'provider_repository.dart';

/// Installs the official fee grids shipped with the app (a copy of the
/// published fees.json), so the app works offline from the first launch.
class DefaultData {
  const DefaultData._();

  static const String asset = 'assets/data/fees.json';
  static const int seedVersion = 2;
  static const String _seedKey = 'seed_version';

  /// Runs once per [seedVersion]:
  /// - fresh install: installs every bundled grid;
  /// - upgrade from 1.x: removes the old default grids the user never
  ///   modified (they were outdated), then installs the missing official ones.
  /// Grids deleted by the user later are never re-installed.
  static Future<void> ensureSeeded({AssetBundle? bundle}) async {
    final database = AppDatabase.instance;
    final current = int.tryParse(await database.getMeta(_seedKey) ?? '') ?? 0;
    if (current >= seedVersion) return;

    final tables = FeeTableService.parse(
      await (bundle ?? rootBundle).loadString(asset),
    );
    await _removeUnmodifiedLegacyGrids();
    await FeeTableService().apply(tables, onlyMissing: true, remember: false);
    await database.setMeta(_seedKey, '$seedVersion');
  }

  static Future<void> _removeUnmodifiedLegacyGrids() async {
    final providers = ProviderRepository();
    final intervals = FeeIntervalRepository();
    final obsolete = <String>[];
    for (final legacy in LegacyDefaults.providers) {
      final provider = await providers.findByName(legacy.name);
      if (provider == null || provider.name != legacy.name) continue;
      final grid = await intervals.getByProvider(provider.id);
      if (_same(grid, legacy.feeIntervals)) obsolete.add(provider.id);
    }
    if (obsolete.isNotEmpty) await providers.delete(obsolete);
  }

  static bool _same(List<FeeInterval> a, List<FeeInterval> b) {
    if (a.length != b.length) return false;
    String key(FeeInterval i) =>
        '${i.minAmount}|${i.maxAmount}|${i.fee}|${i.feeType.index}';
    final left = a.map(key).toList()..sort();
    final right = b.map(key).toList()..sort();
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }
}
