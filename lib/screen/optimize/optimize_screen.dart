import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  const _Request(
    this.budget,
    this.intervals,
    this.minOps,
    this.maxOps,
    this.step,
  );

  final double budget;
  final List<FeeInterval> intervals;
  final int minOps;
  final int maxOps;
  final double step;
}

/// Rounded amounts are multiples of this step: 10 000, never 10 040.
const int roundingStep = 100;

/// Everything displayed after an optimization.
class OptimizationOutcome {
  const OptimizationOutcome({
    required this.comparison,
    required this.minOps,
    required this.maxOps,
    this.step = 0,
    this.operation,
    this.unconstrained,
  });

  final FeeComparison comparison;
  final int minOps;
  final int maxOps;

  /// Every amount is a multiple of [step] (0: any amount).
  final double step;
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
    step: step,
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
    step: request.step,
  );
  final hasLimits = request.minOps > 0 || request.maxOps > 0;
  return OptimizationOutcome(
    comparison: FeeComparison.compute(
      result,
      request.intervals,
      step: request.step,
    ),
    minOps: request.minOps,
    maxOps: request.maxOps,
    step: request.step,
    unconstrained: hasLimits
        ? FeeOptimizer.optimize(
            request.budget,
            request.intervals,
            step: request.step,
          )
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
  int _withdrawalStep = PreferenceUtil.defaultWithdrawalStep;
  int _transferStep = 0;
  bool _limitsExpanded = false;
  bool _running = false;
  OptimizationOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    AppDatabase.changes.addListener(_onDataChanged);
    _load();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    final withdrawal = await PreferenceUtil.amountStep(withdrawal: true);
    final transfer = await PreferenceUtil.amountStep(withdrawal: false);
    if (!mounted) return;
    setState(() {
      _withdrawalStep = withdrawal > 0 ? roundingStep : 0;
      _transferStep = transfer > 0 ? roundingStep : 0;
    });
  }

  bool get _isWithdrawal => _selected?.operation == FeeOperation.withdrawal;

  /// Step of the amounts for the selected operation (0: any amount).
  int get _step => _isWithdrawal ? _withdrawalStep : _transferStep;

  void _setRounded(bool rounded) {
    final step = rounded ? roundingStep : 0;
    final withdrawal = _isWithdrawal;
    _invalidate(() {
      if (withdrawal) {
        _withdrawalStep = step;
      } else {
        _transferStep = step;
      }
    });
    PreferenceUtil.setAmountStep(step, withdrawal: withdrawal);
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
      final request = _Request(
        amount,
        intervals,
        _minOps,
        _maxOps,
        _step.toDouble(),
      );
      final outcome = (await compute(
        _run,
        request,
      )).withOperation(grid.operation);
      if (!mounted) return;
      final stale =
          grid.id != _selectedId ||
          amount != _amount ||
          request.minOps != _minOps ||
          request.maxOps != _maxOps ||
          request.step != _step;
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
                      // Always shown, even with a single operation, so the
                      // kind of transaction is never implicit.
                      child: operatorGrids.isNotEmpty
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
                                  if (operatorGrids.length == 1) ...[
                                    Space.gapSm,
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Space.xs,
                                      ),
                                      child: Text(
                                        l10n.onlyOperation(
                                          GridLabels.operation(
                                            l10n,
                                            operatorGrids.single.operation,
                                          ),
                                          operatorGrids.single.name,
                                        ),
                                        style: context.text.bodySmall,
                                      ),
                                    ),
                                  ],
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
                    Space.gapMd,
                    _RoundingCard(
                      withdrawal: _isWithdrawal,
                      rounded: _step > 0,
                      onChanged: _setRounded,
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
    // Wraps onto several lines: every operator stays visible, whatever the
    // screen width or the number of operators.
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final MapEntry(:key, :value) in map.entries)
          ChoicePill(
            label: value.first.name,
            selected: key == selectedKey,
            onTap: () => onSelected(key),
            leading: ProviderAvatar(
              name: value.first.name,
              iconName: value.first.iconName,
              size: 30,
            ),
          ),
        ChoicePill(
          label: map.isEmpty ? l10n.addNewProvider : l10n.add,
          selected: false,
          onTap: onAdd,
          // Same height as the operator avatars.
          leading: SizedBox.square(
            dimension: 30,
            child: Icon(
              Icons.add_rounded,
              size: 20,
              color: context.colors.primary,
            ),
          ),
        ),
      ],
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

/// Card with a title and a summary, which expands to show [child].
class _CollapsibleCard extends StatelessWidget {
  const _CollapsibleCard({
    required this.title,
    required this.summary,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.summaryIsError = false,
  });

  final String title;
  final String summary;
  final bool summaryIsError;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
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
                      Text(title, style: context.text.titleSmall),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: Motion.medium,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...previous, ?current],
                        ),
                        child: Text(
                          summary,
                          key: ValueKey(summary),
                          style: context.text.bodySmall?.copyWith(
                            color: summaryIsError ? context.colors.error : null,
                          ),
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
                  child: child,
                ),
        ),
      ],
    ),
  );
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
    return _CollapsibleCard(
      title: withdrawal ? l10n.withdrawalCount : l10n.transferCount,
      summary: transferLimitSummary(l10n, minOps, maxOps),
      summaryIsError: invalid,
      expanded: expanded,
      onToggle: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            withdrawal ? l10n.withdrawalCountHelp : l10n.transferCountHelp,
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
    );
  }
}

/// Switch rounding every amount to the hundred (cash points only hand out
/// notes: 10 000, never 10 040).
class _RoundingCard extends StatelessWidget {
  const _RoundingCard({
    required this.withdrawal,
    required this.rounded,
    required this.onChanged,
  });

  final bool withdrawal;
  final bool rounded;
  final ValueChanged<bool> onChanged;

  void _toggle(bool value) {
    HapticFeedback.selectionClick();
    onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final example = context.money(10000);
    final wrong = context.money(10040);
    final summary = !rounded
        ? l10n.roundToHundredOff
        : withdrawal
        ? l10n.roundToHundredOnWithdrawal(example, wrong)
        : l10n.roundToHundredOnTransfer(example, wrong);
    return Pressable(
      onTap: () => _toggle(!rounded),
      color: context.colors.surfaceContainerLow,
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
                  Text(l10n.roundToHundred, style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: Motion.medium,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previous, ?current],
                    ),
                    child: Text(
                      summary,
                      key: ValueKey(summary),
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Space.gapMd,
            Switch(value: rounded, onChanged: _toggle),
          ],
        ),
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
