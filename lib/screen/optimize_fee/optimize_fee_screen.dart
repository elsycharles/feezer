import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/optimizer/fee_comparison.dart';
import '../../core/optimizer/fee_optimizer.dart';
import '../../data/fee_interval_repository.dart';
import '../../data/provider_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../model/fee_interval_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import '../../model/provider_model.dart' as model;
import '../../provider/currency_provider.dart';
import '../../styles/global.dart';
import '../../util/constant_util.dart';
import '../../util/extensions_util.dart';
import '../../util/icon_util.dart';
import '../../util/navigation_util.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/app_toast.dart';
import '../../widget/bottom_sheet.dart' as custom_bottom_sheet;
import '../../widget/collapsible_card.dart';
import '../../widget/loading_button.dart';
import 'widget/amount_input_widget.dart';
import 'widget/optimization_results.dart';
import 'widget/transaction_input_widget.dart';

/// Input of a background optimization.
class _OptimizationRequest {
  const _OptimizationRequest(
    this.budget,
    this.intervals,
    this.minOps,
    this.maxOps,
  );

  final double budget;
  final List<FeeInterval> intervals;
  final int minOps;
  final int maxOps;
}

/// Runs in a background isolate.
FeeComparison _runOptimization(_OptimizationRequest request) {
  final result = FeeOptimizer.optimize(
    request.budget,
    request.intervals,
    minOperations: request.minOps,
    maxOperations: request.maxOps,
  );
  return FeeComparison.compute(result, request.intervals);
}

/// Main screen: splits an amount into the transactions that send the most
/// money for the least fees.
class OptimizeFeeScreen extends StatefulWidget {
  const OptimizeFeeScreen({super.key, this.defaultProvider});

  final model.Provider? defaultProvider;

  @override
  State<OptimizeFeeScreen> createState() => _OptimizeFeeScreenState();
}

class _OptimizeFeeScreenState extends State<OptimizeFeeScreen> with RouteAware {
  final _providerRepository = ProviderRepository();
  final _intervalRepository = FeeIntervalRepository();

  List<model.Provider> _providers = const [];
  model.Provider? _selectedProvider;

  /// Amount to optimize, always in Ariary (independent of the display
  /// currency, so switching currency never corrupts it).
  double _amountInBase = 10000;
  int _minTransactions = 0;
  int _maxTransactions = 0;

  /// Last optimization (amounts in Ariary), `null` before the first one.
  FeeComparison? _comparison;
  bool _isOptimizing = false;
  DateTime? _lastBackPressed;
  ModalRoute<void>? _route;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route && route != null) {
      if (_route != null) NavigationUtil.routeObserver.unsubscribe(this);
      _route = route;
      NavigationUtil.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    NavigationUtil.routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Back on this screen (providers may have been edited elsewhere).
  @override
  void didPopNext() => _loadProviders();

  Future<void> _loadProviders({String? selectId}) async {
    try {
      final providers = await _providerRepository.getAll();
      if (!mounted) return;
      setState(() {
        _providers = providers;
        model.Provider? find(String? id) =>
            id == null ? null : providers.where((p) => p.id == id).firstOrNull;
        final previous = _selectedProvider;
        _selectedProvider =
            find(selectId) ??
            find(previous?.id) ??
            find(widget.defaultProvider?.id) ??
            providers.firstOrNull;
        if (_selectedProvider != previous) _comparison = null;
      });
    } catch (_) {
      if (mounted) {
        AppToast.error(context, AppLocalizations.of(context).failedToLoadData);
      }
    }
  }

  void _invalidate(VoidCallback change) => setState(() {
    change();
    _comparison = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.watch<CurrencyProvider>();
    final canPop = Navigator.of(context).canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !canPop) _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: custom.AppBar(
          title: l10n.optimizeFee,
          automaticallyImplyLeading: canPop,
          menuExcludeRoutes: const [NavigationUtil.homeRoute],
          menuIconColor: context.colorScheme.onSurface,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Global.gapMd,
                      _buildProviderSection(l10n),
                      Global.gapLg,
                      _buildAmountSection(l10n, currency),
                      Global.gapLg,
                      _buildTransactionSection(l10n),
                      Global.gapLg,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildResults(l10n, currency),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            _buildOptimizeButton(l10n),
          ],
        ),
      ),
    );
  }

  void _handleBackPress() {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      AppToast.info(context, AppLocalizations.of(context).pressAgainToExit);
    } else {
      SystemNavigator.pop();
    }
  }

  // ---------------------------------------------------------------------------
  // Inputs
  // ---------------------------------------------------------------------------

  Widget _buildProviderSection(AppLocalizations l10n) => CollapsibleCard(
    title: l10n.financialProvider,
    subtitle: l10n.chooseProviderToAnalyze,
    icon: Icons.business,
    iconColor: context.colorScheme.primary,
    titleStyle: ThemeUtil.titleMedium.copyWith(
      color: context.colorScheme.primary,
      fontWeight: FontWeight.w600,
    ),
    children: [
      Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: Global.borderMd,
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<model.Provider?>(
            value: _selectedProvider,
            isExpanded: true,
            padding: Global.padMd,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: context.colorScheme.onSurfaceVariant,
            ),
            items: [
              for (final provider in _providers)
                DropdownMenuItem(
                  value: provider,
                  child: _ProviderItem(
                    icon: IconUtil.getIcon(provider.iconName),
                    title: provider.name,
                    subtitle: provider.description,
                  ),
                ),
              DropdownMenuItem(
                value: null,
                child: _ProviderItem(
                  icon: Icons.add,
                  title: l10n.addNewProvider,
                  highlighted: true,
                ),
              ),
            ],
            onChanged: (provider) async {
              if (provider != null) {
                _invalidate(() => _selectedProvider = provider);
                return;
              }
              final created = await NavigationUtil.pushTo<model.Provider>(
                context,
                NavigationUtil.newProviderRoute,
              );
              await _loadProviders(selectId: created?.id);
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildAmountSection(
    AppLocalizations l10n,
    CurrencyProvider currency,
  ) => CollapsibleCard(
    title: l10n.amountToOptimize,
    subtitle: l10n.enterTransactionAmountToOptimize,
    titleStyle: ThemeUtil.titleMedium.copyWith(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    ),
    children: [
      AmountInputWidget(
        value: currency.convertFromAriary(_amountInBase),
        currencySymbol: currency.currencySymbol,
        label: l10n.amount,
        onChanged: (value) =>
            _invalidate(() => _amountInBase = currency.convertToAriary(value)),
      ),
    ],
  );

  Widget _buildTransactionSection(AppLocalizations l10n) => CollapsibleCard(
    title: l10n.transactionRange,
    subtitle: l10n.defineMinMaxTransactions,
    titleStyle: ThemeUtil.titleMedium.copyWith(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    ),
    isInitiallyExpanded: false,
    children: [
      Row(
        children: [
          Expanded(
            child: TransactionInputWidget(
              value: _minTransactions,
              label: l10n.minTransactions,
              max: ConstantUtil.maxTransactionsInput,
              onChanged: (value) => _invalidate(() => _minTransactions = value),
            ),
          ),
          Global.gapLg,
          Expanded(
            child: TransactionInputWidget(
              value: _maxTransactions,
              label: l10n.maxTransactions,
              max: ConstantUtil.maxTransactionsInput,
              onChanged: (value) => _invalidate(() => _maxTransactions = value),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildOptimizeButton(AppLocalizations l10n) => Container(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      context.mediaQuery.padding.bottom + 20,
    ),
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      boxShadow: Global.shadowMd,
    ),
    child: LoadingButton(
      text: l10n.optimize,
      onPressed: _isOptimizing ? null : _optimize,
      isLoading: _isOptimizing,
    ),
  );

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  Widget _buildResults(AppLocalizations l10n, CurrencyProvider currency) {
    final comparison = _comparison;
    if (comparison == null) return const ResultsPlaceholder();

    // Results are kept in Ariary and converted for display.
    final factor = 1 / currency.exchangeRate;
    final shown = comparison.scaled(factor);
    final symbol = currency.currencySymbol;
    final result = shown.optimized;
    return Column(
      children: [
        OptimizationResultsCard(
          result: result,
          currencySymbol: symbol,
          message: _statusMessage(l10n, result.status),
        ),
        if (result.isSuccess) ...[
          Global.gapLg,
          ComparisonCard(
            comparison: shown,
            currencySymbol: symbol,
            onShowWithoutOptimization: () => _showPlan(
              l10n.withoutOptimizationMaxAmount,
              shown.withoutOptimization,
              symbol,
            ),
            onShowSameNet: () => _showPlan(
              l10n.withoutOptimizationSameNet,
              shown.sameNetWithoutOptimization,
              symbol,
            ),
          ),
        ],
      ],
    );
  }

  String? _statusMessage(AppLocalizations l10n, OptimizationStatus status) =>
      switch (status) {
        OptimizationStatus.success => null,
        OptimizationStatus.noFeeIntervals => l10n.noFeeIntervalsFound,
        OptimizationStatus.budgetTooSmall => l10n.optimizationBudgetTooSmall,
        OptimizationStatus.constraintsUnsatisfiable =>
          l10n.optimizationConstraintsUnsatisfiable,
      };

  void _showPlan(String title, FeeOptimizerResult? plan, String symbol) {
    final l10n = AppLocalizations.of(context);
    custom_bottom_sheet.BottomSheet.show(
      context,
      title,
      plan == null || plan.details.isEmpty
          ? Padding(
              padding: Global.padSm,
              child: Text(
                l10n.noValidIntervalForComparison,
                style: ThemeUtil.bodySmall.copyWith(color: ThemeUtil.warning),
              ),
            )
          : TransactionDetailsTable(
              details: plan.details,
              currencySymbol: symbol,
            ),
    );
  }

  Future<void> _optimize() async {
    final l10n = AppLocalizations.of(context);
    final currency = context.read<CurrencyProvider>();
    final provider = _selectedProvider;

    if (provider == null) {
      AppToast.error(context, l10n.pleaseSelectProvider);
      return;
    }
    if (!(_amountInBase > 0)) {
      AppToast.error(context, l10n.pleaseEnterValidAmount);
      return;
    }
    if (_minTransactions > 0 &&
        _maxTransactions > 0 &&
        _minTransactions > _maxTransactions) {
      AppToast.error(context, l10n.minTransactionsCannotBeGreaterThanMax);
      return;
    }
    if (_amountInBase > FeeOptimizer.maxSupportedAmount) {
      AppToast.error(
        context,
        l10n.amountExceedsMaximumLimit(
          ConstantUtil.formatCurrencyAmount(
            currency.convertFromAriary(FeeOptimizer.maxSupportedAmount),
          ),
          currency.currencySymbol,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isOptimizing = true);
    try {
      final intervals = await _intervalRepository.getByProvider(provider.id);
      final request = _OptimizationRequest(
        _amountInBase,
        intervals,
        _minTransactions,
        _maxTransactions,
      );
      final comparison = await compute(_runOptimization, request);
      if (!mounted) return;
      // Ignore results of an outdated request (inputs changed meanwhile).
      if (provider != _selectedProvider || request.budget != _amountInBase) {
        return;
      }
      setState(() => _comparison = comparison);

      final result = comparison.optimized;
      if (result.isSuccess) {
        final coverage = result.netAmount / result.budget * 100;
        if (coverage < 80) {
          AppToast.warning(
            context,
            l10n.optimizationIncomplete(coverage.toStringAsFixed(1)),
          );
        }
      } else {
        AppToast.info(
          context,
          _statusMessage(l10n, result.status) ??
              l10n.noOptimizationResultsFound,
        );
      }
    } catch (e) {
      debugPrint('Optimization failed: $e');
      if (mounted) AppToast.error(context, l10n.failedToCalculateOptimization);
    } finally {
      if (mounted) setState(() => _isOptimizing = false);
    }
  }
}

class _ProviderItem extends StatelessWidget {
  const _ProviderItem({
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18),
        ),
        Global.gapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: ThemeUtil.bodyLarge.copyWith(
                  color: highlighted
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: ThemeUtil.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
