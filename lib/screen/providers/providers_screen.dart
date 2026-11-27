import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/fee_interval_repository.dart';
import '../../data/fee_table_service.dart';
import '../../data/provider_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../model/provider_model.dart';
import '../../theme/app_theme.dart';
import '../../util/date_label.dart';
import '../../util/grid_labels.dart';
import '../../util/money.dart';
import '../../util/navigation_util.dart';
import '../../widget/app_toast.dart';
import '../../widget/common.dart';
import 'fee_update_flow.dart';

typedef GridSummary = ({int count, double? minFee});

/// Tab listing the operators and their fee grids.
class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final _providerRepository = ProviderRepository();
  final _intervalRepository = FeeIntervalRepository();

  List<Provider>? _grids;
  Map<String, GridSummary> _summaries = const {};
  DateTime? _lastCheck;

  @override
  void initState() {
    super.initState();
    AppDatabase.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppDatabase.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final grids = await _providerRepository.getAll();
      final summaries = await _intervalRepository.summaries();
      final lastCheck = await FeeTableService.lastCheck();
      if (!mounted) return;
      setState(() {
        _grids = grids;
        _summaries = summaries;
        _lastCheck = lastCheck;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _grids = const []);
      AppToast.error(context, AppLocalizations.of(context).failedToLoadData);
    }
  }

  Future<void> _update() async {
    await runFeeUpdate(context);
    await _load();
  }

  /// Grids grouped by operator: alphabetical, operations in a fixed order.
  List<List<Provider>> get _operators {
    final groups = <String, List<Provider>>{};
    for (final grid in _grids ?? const <Provider>[]) {
      groups.putIfAbsent(grid.operatorKey, () => []).add(grid);
    }
    final keys = groups.keys.toList()..sort();
    return [
      for (final key in keys)
        groups[key]!..sort(
          (a, b) =>
              (a.operation?.index ?? 99).compareTo(b.operation?.index ?? 99),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final grids = _grids;
    final operators = _operators;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-grid',
        onPressed: () => NavigationUtil.openNewProvider(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.add),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.xl,
                Space.page,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  Text(l10n.operators, style: context.text.headlineMedium),
                  Space.gapXl,
                  _FeeStatusCard(lastCheck: _lastCheck, onUpdate: _update),
                  Space.gapXl,
                ],
              ),
            ),
            if (grids == null)
              const SliverToBoxAdapter(
                child: SkeletonList(
                  padding: EdgeInsets.symmetric(horizontal: Space.page),
                ),
              )
            else if (grids.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.noProvidersYet,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Space.page,
                  0,
                  Space.page,
                  104,
                ),
                sliver: SliverList.separated(
                  itemCount: operators.length,
                  separatorBuilder: (_, _) => Space.gapMd,
                  itemBuilder: (context, index) => FadeSlideIn(
                    index: index,
                    child: _OperatorCard(
                      grids: operators[index],
                      summaries: _summaries,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Where the fees come from, and the update action.
class _FeeStatusCard extends StatelessWidget {
  const _FeeStatusCard({required this.lastCheck, required this.onUpdate});

  final DateTime? lastCheck;
  final Future<void> Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checked = lastCheck;
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        Space.md,
        Space.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.officialFees, style: context.text.titleSmall),
              ),
              PressScale(
                child: FilledButton.tonalIcon(
                  onPressed: onUpdate,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: Space.md),
                    textStyle: context.text.labelMedium,
                  ),
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: Text(l10n.updateAction),
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: Motion.medium,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            child: Text(
              checked == null
                  ? l10n.feesNeverChecked
                  : l10n.feesCheckedOn(context.date(checked)),
              key: ValueKey(checked),
              style: context.text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// One operator and its grids (one row per operation).
class _OperatorCard extends StatelessWidget {
  const _OperatorCard({required this.grids, required this.summaries});

  final List<Provider> grids;
  final Map<String, GridSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final first = grids.first;
    final host = grids
        .map((g) => GridLabels.host(g.sourceUrl))
        .whereType<String>()
        .firstOrNull;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.md,
            ),
            child: Row(
              children: [
                ProviderAvatar(
                  name: first.name,
                  iconName: first.iconName,
                  size: 40,
                ),
                Space.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(first.name, style: context.text.titleMedium),
                      Text(
                        [
                          l10n.gridCount(grids.length),
                          host ?? l10n.customGrids,
                        ].join('  ·  '),
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final grid in grids) ...[
            const Divider(indent: Space.lg, endIndent: Space.lg),
            _GridRow(grid: grid, summary: summaries[grid.id]),
          ],
        ],
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({required this.grid, required this.summary});

  final Provider grid;
  final GridSummary? summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = summary?.count ?? 0;
    final minFee = summary?.minFee;
    return Pressable(
      onTap: () => NavigationUtil.openProvider(context, grid),
      borderRadius: 0,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.lg,
          Space.md,
          Space.md,
          Space.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    GridLabels.operation(l10n, grid.operation),
                    style: context.text.titleSmall,
                  ),
                  Text(
                    [
                      l10n.tierCount(count),
                      if (minFee != null) l10n.feesFrom(context.money(minFee)),
                      if (grid.sourceType == Provider.editedSource)
                        l10n.editedTag,
                    ].join('  ·  '),
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
