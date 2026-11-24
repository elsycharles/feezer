import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/optimizer/fee_comparison.dart';
import '../../core/optimizer/fee_optimizer.dart';
import '../../data/app_database.dart';
import '../../data/fee_interval_repository.dart';
import '../../data/provider_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../model/fee_interval_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import '../../model/fee_operation.dart';
import '../../model/provider_model.dart';
import '../../theme/app_theme.dart';
import '../../util/constant_util.dart';
import '../../util/grid_labels.dart';
import '../../util/money.dart';
import '../../util/navigation_util.dart';
import '../../util/preference_util.dart';
import '../../widget/amount_input_formatter.dart';
import '../../widget/app_toast.dart';
import '../../widget/common.dart';
import 'result_view.dart';

/// Inputs of a background optimization.
class _Request {
  const _Request(this.budget, this.intervals, this.minOps, this.maxOps);

  final double budget;
  final List<FeeInterval> intervals;
  final int minOps;
  final int maxOps;
}

/// Everything displayed after an optimization.
class OptimizationOutcome {
  const OptimizationOutcome({
    required this.comparison,
    required this.minOps,
    required this.maxOps,
    this.operation,
    this.unconstrained,
  });

  final FeeComparison comparison;
  final int minOps;
  final int maxOps;
  final FeeOperation? operation;

  /// Best plan without the transfer limits (only when limits were set).
  final FeeOptimizerResult? unconstrained;

  FeeOptimizerResult get result => comparison.optimized;

  bool get hasLimits => minOps > 0 || maxOps > 0;

  bool get isWithdrawal => operation == FeeOperation.withdrawal;

  /// What the limits cost (0 when they cost nothing).
  double get limitCost {
    final free = unconstrained;
    if (free == null || !free.isSuccess) return 0;
    final cost = free.netAmount - result.netAmount;
    return cost > 1e-6 ? cost : 0;
  }

  OptimizationOutcome withOperation(FeeOperation? value) => OptimizationOutcome(
    comparison: comparison,
    minOps: minOps,
    maxOps: maxOps,
    operation: value,
    unconstrained: unconstrained,
  );
}

/// Runs in a background isolate.
OptimizationOutcome _run(_Request request) {
  final result = FeeOptimizer.optimize(
    request.budget,
    request.intervals,
    minOperations: request.minOps,
    maxOperations: request.maxOps,
  );
  final hasLimits = request.minOps > 0 || request.maxOps > 0;
  return OptimizationOutcome(
    comparison: FeeComparison.compute(result, request.intervals),
    minOps: request.minOps,
    maxOps: request.maxOps,
    unconstrained: hasLimits
        ? FeeOptimizer.optimize(request.budget, request.intervals)
        : null,
  );
}

/// Main tab: splits an amount into the transactions that cost the least fees.
class OptimizeScreen extends StatefulWidget {
  const OptimizeScreen({super.key});

  @override
  State<OptimizeScreen> createState() => OptimizeScreenState();
}

class OptimizeScreenState extends State<OptimizeScreen> {
  final _providerRepository = ProviderRepository();
  final _intervalRepository = FeeIntervalRepository();
  final _amountController = TextEditingController();
  final _resultKey = GlobalKey();

  List<Provider>? _grids;
  String? _selectedId;
  int _minOps = 0;
  int _maxOps = 0;
  bool _limitsExpanded = false;
  bool _running = false;
  OptimizationOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    AppDatabase.changes.addListener(_onDataChanged);
    _load();
  }

  @override
  void dispose() {
    AppDatabase.changes.removeListener(_onDataChanged);
    _amountController.dispose();
    super.dispose();
  }

  /// Preselects [provider] (from its detail screen).
  void selectProvider(Provider provider) {
    PreferenceUtil.setLastGridId(provider.id);
    _load(selectId: provider.id);
  }

  void _onDataChanged() => _load(clearResult: true);

  Provider? get _selected =>
      _grids?.where((g) => g.id == _selectedId).firstOrNull;

  /// Grids grouped by operator, in display order.
  Map<String, List<Provider>> get _operators {
    final groups = <String, List<Provider>>{};
    for (final grid in _grids ?? const <Provider>[]) {
      groups.putIfAbsent(grid.operatorKey, () => []).add(grid);
    }
    for (final grids in groups.values) {
      grids.sort(
        (a, b) =>
            (a.operation?.index ?? 99).compareTo(b.operation?.index ?? 99),
      );
    }
    return groups;
  }

  Future<void> _load({String? selectId, bool clearResult = false}) async {
    try {
      final grids = await _providerRepository.getAll();
      grids.sort((a, b) => a.operatorKey.compareTo(b.operatorKey));
      final saved = _grids == null ? await PreferenceUtil.lastGridId() : null;
      if (!mounted) return;
      setState(() {
        _grids = grids;
        final wanted = selectId ?? _selectedId ?? saved;
        final previous = _selectedId;
        _selectedId = grids.any((g) => g.id == wanted)
            ? wanted
            : _preferredDefault(grids)?.id;
        if (clearResult || _selectedId != previous) _outcome = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _grids = const []);
      AppToast.error(context, AppLocalizations.of(context).failedToLoadData);
    }
  }

  /// First run: the first operator (alphabetically) with a transfer grid.
  static Provider? _preferredDefault(List<Provider> grids) =>
      grids
          .where((g) => g.operation == FeeOperation.transferSame)
          .firstOrNull ??
      grids.firstOrNull;

  void _select(String id) {
    _invalidate(() => _selectedId = id);
    PreferenceUtil.setLastGridId(id);
  }

  void _selectOperator(String operatorKey) {
    final grids = _operators[operatorKey] ?? const <Provider>[];
    if (grids.isEmpty) return;
    final current = _selected?.operation;
    final same = grids.where((g) => g.operation == current).firstOrNull;
    _select((same ?? grids.first).id);
  }

  double get _amount =>
      ConstantUtil.parseLocalizedNumber(_amountController.text) ?? 0;

  void _invalidate(VoidCallback change) => setState(() {
    change();
    _outcome = null;
  });

  Future<void> _optimize() async {
    final l10n = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    final grid = _selected;
    if (grid == null) {
      AppToast.warning(context, l10n.pleaseSelectProvider);
      return;
    }
    final amount = _amount;
    if (!(amount > 0)) {
      AppToast.warning(context, l10n.pleaseEnterValidAmount);
      return;
    }
    if (_minOps > 0 && _maxOps > 0 && _minOps > _maxOps) {
      AppToast.warning(context, l10n.minTransactionsCannotBeGreaterThanMax);
      return;
    }

    setState(() {
      _running = true;
      _outcome = null;
    });
    _reveal();
    try {
      final intervals = await _intervalRepository.getByProvider(grid.id);
      final request = _Request(amount, intervals, _minOps, _maxOps);
      final outcome = (await compute(
        _run,
        request,
      )).withOperation(grid.operation);
      if (!mounted) return;
      final stale =
          grid.id != _selectedId ||
          amount != _amount ||
          request.minOps != _minOps ||
          request.maxOps != _maxOps;
      setState(() {
        _running = false;
        if (!stale) _outcome = outcome;
      });
    } catch (e) {
      debugPrint('Optimization failed: $e');
      if (!mounted) return;
      setState(() => _running = false);
      AppToast.error(context, l10n.failedToCalculateOptimization);
    }
  }

  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _resultKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected;
    final operators = _operators;
    final operatorGrids = selected == null
        ? const <Provider>[]
        : (operators[selected.operatorKey] ?? const <Provider>[]);
    final source = selected == null
        ? null
        : GridLabels.source(context, selected);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Space.page,
                  Space.lg,
                  Space.page,
                  0,
                ),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 28,
                          height: 28,
                        ),
                        Space.gapSm,
                        Text('Feezer', style: context.text.titleLarge),
                      ],
                    ),
                    Space.gapXl,
                    Text(
                      l10n.optimizeTitle,
                      style: context.text.headlineMedium,
                    ),
                    Space.gapXs,
                    Text(
                      l10n.optimizeSubtitle,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    Space.gapXl,
                    SectionLabel(l10n.operatorLabel),
                    _OperatorPicker(
                      operators: _grids == null ? null : operators,
                      selectedKey: selected?.operatorKey,
                      onSelected: _selectOperator,
                      onAdd: () => NavigationUtil.openNewProvider(context),
                    ),
                    AnimatedSize(
                      duration: Motion.medium,
                      curve: Motion.curve,
                      alignment: Alignment.topCenter,
                      child: operatorGrids.length > 1
                          ? Padding(
                              padding: const EdgeInsets.only(top: Space.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SectionLabel(l10n.operationLabel),
                                  Wrap(
                                    spacing: Space.sm,
                                    runSpacing: Space.sm,
                                    children: [
                                      for (final grid in operatorGrids)
                                        ChoicePill(
                                          label: GridLabels.operation(
                                            l10n,
                                            grid.operation,
                                          ),
                                          selected: grid.id == _selectedId,
                                          onTap: () => _select(grid.id),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    if (source != null) ...[
                      Space.gapSm,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.xs,
                        ),
                        child: AnimatedSwitcher(
                          duration: Motion.medium,
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.centerLeft,
                            children: [...previous, ?current],
                          ),
                          child: Text(
                            source,
                            key: ValueKey(source),
                            style: context.text.bodySmall,
                          ),
                        ),
                      ),
                    ],
                    Space.gapXl,
                    SectionLabel(l10n.amountAvailable),
                    _AmountCard(
                      controller: _amountController,
                      onChanged: () => _invalidate(() {}),
                      onSubmitted: _optimize,
                    ),
                    Space.gapMd,
                    _LimitsCard(
                      withdrawal:
                          selected?.operation == FeeOperation.withdrawal,
                      expanded: _limitsExpanded,
                      minOps: _minOps,
                      maxOps: _maxOps,
                      onToggle: () =>
                          setState(() => _limitsExpanded = !_limitsExpanded),
                      onMinChanged: (v) => _invalidate(() => _minOps = v),
                      onMaxChanged: (v) => _invalidate(() => _maxOps = v),
                    ),
                    Space.gapXl,
                    AppButton(
                      label: l10n.optimize,
                      loading: _running,
                      onPressed: _optimize,
                    ),
                    Space.gapSm,
                  ],
                ),
              ),
              SliverPadding(
                // The top padding stays visible when the result is revealed.
                key: _resultKey,
                padding: const EdgeInsets.fromLTRB(
                  Space.page,
                  Space.lg,
                  Space.page,
                  Space.xxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: Motion.slow,
                    switchInCurve: Motion.curve,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _running
                        ? const ResultSkeleton(key: ValueKey('loading'))
                        : (_outcome == null
                              ? const SizedBox.shrink(key: ValueKey('empty'))
                              : ResultView(
                                  key: ObjectKey(_outcome),
                                  outcome: _outcome!,
                                )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperatorPicker extends StatelessWidget {
  const _OperatorPicker({
    required this.operators,
    required this.selectedKey,
    required this.onSelected,
    required this.onAdd,
  });

  final Map<String, List<Provider>>? operators;
  final String? selectedKey;
  final ValueChanged<String> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final map = operators;
    if (map == null) {
      return const Row(
        children: [
          Expanded(child: Skeleton(height: 50, radius: Space.radiusMd)),
          Space.gapSm,
          Expanded(child: Skeleton(height: 50, radius: Space.radiusMd)),
          Space.gapSm,
          Expanded(child: Skeleton(height: 50, radius: Space.radiusMd)),
        ],
      );
    }
    final entries = map.entries.toList();
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: entries.length + 1,
        separatorBuilder: (_, _) => Space.gapSm,
        itemBuilder: (context, index) {
          if (index == entries.length) {
            return ChoicePill(
              label: entries.isEmpty ? l10n.addNewProvider : l10n.add,
              selected: false,
              onTap: onAdd,
              leading: Icon(
                Icons.add_rounded,
                size: 20,
                color: context.colors.primary,
              ),
            );
          }
          final grid = entries[index].value.first;
          return ChoicePill(
            label: grid.name,
            selected: entries[index].key == selectedKey,
            onTap: () => onSelected(entries[index].key),
            leading: ProviderAvatar(
              name: grid.name,
              iconName: grid.iconName,
              size: 30,
            ),
          );
        },
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decimal = Money.decimalSeparatorOf(Localizations.localeOf(context));
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        Space.lg,
        Space.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              AmountInputFormatter(
                max: ConstantUtil.maxInputAmount,
                decimalSeparator: decimal,
              ),
            ],
            style: context.text.displaySmall?.copyWith(
              fontFeatures: AppTheme.tabular,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: context.text.displaySmall?.copyWith(
                color: context.colors.outline,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onSubmitted(),
          ),
          Space.gapXs,
          Text(l10n.amountHelper, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class _LimitsCard extends StatelessWidget {
  const _LimitsCard({
    required this.withdrawal,
    required this.expanded,
    required this.minOps,
    required this.maxOps,
    required this.onToggle,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  final bool withdrawal;
  final bool expanded;
  final int minOps;
  final int maxOps;
  final VoidCallback onToggle;
  final ValueChanged<int> onMinChanged;
  final ValueChanged<int> onMaxChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final invalid = minOps > 0 && maxOps > 0 && minOps > maxOps;
    final summary = transferLimitSummary(l10n, minOps, maxOps);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Pressable(
            onTap: onToggle,
            borderRadius: 0,
            scale: 0.99,
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          withdrawal
                              ? l10n.withdrawalCount
                              : l10n.transferCount,
                          style: context.text.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          style: context.text.bodySmall?.copyWith(
                            color: invalid ? context.colors.error : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: Motion.medium,
                    curve: Motion.curve,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: !expanded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.lg,
                      0,
                      Space.lg,
                      Space.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          withdrawal
                              ? l10n.withdrawalCountHelp
                              : l10n.transferCountHelp,
                          style: context.text.bodySmall,
                        ),
                        Space.gapMd,
                        Row(
                          children: [
                            Expanded(
                              child: CountStepper(
                                label: l10n.minimumShort,
                                value: minOps,
                                zeroLabel: l10n.anyCount,
                                max: ConstantUtil.maxTransactionsInput,
                                onChanged: onMinChanged,
                              ),
                            ),
                            Space.gapMd,
                            Expanded(
                              child: CountStepper(
                                label: l10n.maximumShort,
                                value: maxOps,
                                zeroLabel: l10n.anyCount,
                                max: ConstantUtil.maxTransactionsInput,
                                onChanged: onMaxChanged,
                              ),
                            ),
                          ],
                        ),
                        if (invalid) ...[
                          Space.gapSm,
                          Text(
                            l10n.minTransactionsCannotBeGreaterThanMax,
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// "No limit", "At least 2", "Between 2 and 5"...
String transferLimitSummary(AppLocalizations l10n, int minOps, int maxOps) {
  if (minOps > 0 && maxOps > 0) {
    return minOps == maxOps
        ? l10n.transferCountExactly(minOps)
        : l10n.transferCountRange(minOps, maxOps);
  }
  if (minOps > 0) return l10n.transferCountAtLeast(minOps);
  if (maxOps > 0) return l10n.transferCountAtMost(maxOps);
  return l10n.transferCountFree;
}
