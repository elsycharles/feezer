import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/provider_model.dart' as model;
import '../../model/fee_minimizer_result_model.dart';
import '../../model/fee_minimizer_detail_model.dart';
import '../../model/fee_interval_model.dart';
import '../../model/currency_model.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import '../../util/constant_util.dart';
import '../../util/theme_util.dart';
import '../../util/navigation_util.dart';
import '../../util/extensions_util.dart';
import '../../widget/app_toast.dart';
import '../../widget/app_bar.dart' as custom;
import 'widget/amount_input_widget.dart';
import 'widget/transaction_input_widget.dart';

import '../../widget/collapsible_card.dart';
import '../../widget/loading_button.dart';
import '../../widget/surface_card.dart';
import '../../util/database_util.dart';
import '../../provider/currency_provider.dart';
import '../../util/fee_minimizer_util.dart';
import '../../util/icon_util.dart';

/// Screen for optimizing fees based on transaction amounts and ranges
class OptimizeFeeScreen extends StatefulWidget {
  const OptimizeFeeScreen({super.key, this.defaultProvider});

  final model.Provider? defaultProvider;

  @override
  State<OptimizeFeeScreen> createState() => _State();
}

class _State extends State<OptimizeFeeScreen> {
  DateTime? _lastBackPressed;

  final _providers = <model.Provider>[];

  model.Provider? _selectedProvider;
  double _amount = 10000.0;
  int _minTransactions = 0;
  int _maxTransactions = 0;
  FeeOptimizerResult? _result;
  bool _hasOptimized = false;
  bool _isOptimizing = false;

  Currency? _previousCurrency;

  // For comparison without optimization
  Map<String, dynamic>? _nonOptimizedComparison;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload providers when screen becomes visible again (e.g., after adding provider via menu)
    _loadProviders();

    // Convert amount when currency changes
    _convertAmountForNewCurrency();
  }

  void _convertAmountForNewCurrency() {
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    // If we have a previous currency and it changed, convert the amount
    if (_previousCurrency != null &&
        _previousCurrency != currencyProvider.selectedCurrency) {
      // Convert from previous currency to new currency - NO ROUNDING
      final amountInAriary = _previousCurrency!.rate * _amount;
      final newAmount =
          amountInAriary /
          currencyProvider
              .selectedCurrency!
              .rate; // REMOVED: * 100).round() / 100

      // Update amount but keep optimization results (they will be converted via _convertedResult)
      setState(() {
        _amount = newAmount;
      });
    }

    _previousCurrency = currencyProvider.selectedCurrency;
  }

  FeeOptimizerResult? get _convertedResult {
    if (_result == null) return null;

    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    // If the result is already in the current currency, return as is
    // For now, assume all results are in Ariary and need conversion
    return FeeOptimizerResult(
      totalAmount: currencyProvider.convertFromAriary(_result!.totalAmount),
      netAmount: currencyProvider.convertFromAriary(_result!.netAmount),
      totalFees: currencyProvider.convertFromAriary(_result!.totalFees),
      remaining: currencyProvider.convertFromAriary(_result!.remaining),
      details: _result!.details
          .map(
            (detail) => FeeOptimizerDetail(
              amount: currencyProvider.convertFromAriary(detail.amount),
              fee: currencyProvider.convertFromAriary(detail.fee),
              count: detail.count,
            ),
          )
          .toList(),
    );
  }

  Future<void> _loadProviders() async {
    final db = DatabaseUtil();
    final providerMaps = await db.query(ConstantUtil.tableProviders);
    final loadedProviders = providerMaps
        .map((map) => model.Provider.fromMap(map))
        .toList();
    if (mounted) {
      setState(() {
        _providers
          ..clear()
          ..addAll(loadedProviders);
        // Only set default provider if none is currently selected or if selected provider no longer exists
        if (_selectedProvider == null ||
            !_providers.contains(_selectedProvider)) {
          _selectedProvider = _providers.isNotEmpty
              ? (widget.defaultProvider != null &&
                        _providers.contains(widget.defaultProvider)
                    ? widget.defaultProvider
                    : _providers.first)
              : null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canNavigateBack = Navigator.of(context).canPop();

    return PopScope(
      canPop: canNavigateBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !canNavigateBack) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: custom.AppBar(
          title: AppLocalizations.of(context).optimizeFee,
          leading: null, // Will be handled by automaticallyImplyLeading
          automaticallyImplyLeading:
              ModalRoute.of(context)?.canPop ??
              false, // Show back button only when can pop
          menuExcludeRoutes: [NavigationUtil.homeRoute],
          menuIconColor: context.colorScheme.onSurface,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Use BouncingScrollPhysics for better UX and international standards
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                // Add proper padding for RTL support and accessibility
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).textScaler.scale(1.0) > 1.3
                      ? 12
                      : 0,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Global.gapMd,
                      _buildProviderSection(),
                      Global.gapLg,
                      _buildAmountSection(),
                      Global.gapLg,
                      _buildTransactionSection(),
                      Global.gapLg,
                      _buildResultsSection(),
                      Global.gapXl,
                      // Increased bottom padding for better accessibility
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(top: false, child: _buildOptimizeButton()),
          ],
        ),
      ),
    );
  }

  void _handleBackPress() {
    // Double back logic to exit the app
    final now = DateTime.now();
    const exitTimeLimit = Duration(seconds: 2);

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > exitTimeLimit) {
      _lastBackPressed = now;
      AppToast.info(context, AppLocalizations.of(context).pressAgainToExit);
    } else {
      SystemNavigator.pop();
    }
  }

  Widget _buildProviderSection() => CollapsibleCard(
    title: AppLocalizations.of(context).financialProvider,
    subtitle: AppLocalizations.of(context).chooseProviderToAnalyze,
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
          child: DropdownButton<model.Provider>(
            value: _selectedProvider,
            isExpanded: true,
            padding: Global.padMd,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: context.colorScheme.onSurfaceVariant,
            ),
            items: [
              // Regular provider items
              ..._providers.map(
                (provider) => DropdownMenuItem(
                  value: provider,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          IconUtil.getIcon(provider.iconName),
                          color: context.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      Global.gapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              provider.name,
                              style: ThemeUtil.bodyLarge.copyWith(
                                color: context.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (provider.description.isNotEmpty)
                              Text(
                                provider.description,
                                style: ThemeUtil.bodySmall.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DropdownMenuItem<model.Provider>(
                value: null,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: context.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    Global.gapMd,
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).addNewProvider,
                        style: ThemeUtil.bodyLarge.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onChanged: (provider) async {
              if (provider == null) {
                // Navigate to NewProviderScreen when "Add new provider" is selected
                await NavigationUtil.pushTo(
                  context,
                  NavigationUtil.newProviderRoute,
                );
                // Reload providers list after returning from new provider screen
                await _loadProviders();
              } else {
                setState(() {
                  _selectedProvider = provider;
                  _hasOptimized = false;
                  _result = null;
                  _nonOptimizedComparison = null;
                });
              }
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildAmountSection() => CollapsibleCard(
    title: AppLocalizations.of(context).amountToOptimize,
    subtitle: AppLocalizations.of(context).enterTransactionAmountToOptimize,
    titleStyle: ThemeUtil.titleMedium.copyWith(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    ),
    children: [
      Consumer<CurrencyProvider>(
        builder: (context, currencyProvider, child) => AmountInputWidget(
          value: _amount,
          onChanged: (value) {
            setState(() {
              _amount = value;
              _hasOptimized = false;
              _result = null;
              _nonOptimizedComparison = null;
            });
          },
          label: AppLocalizations.of(context).amount,
          min: 0.01,
          max: 99999999999.0,
        ),
      ),
    ],
  );

  Widget _buildTransactionSection() => CollapsibleCard(
    title: AppLocalizations.of(context).transactionRange,
    subtitle: AppLocalizations.of(context).defineMinMaxTransactions,
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
              onChanged: (value) => setState(() => _minTransactions = value),
              label: AppLocalizations.of(context).minTransactions,
              min: 0,
              max: 999,
            ),
          ),
          Global.gapLg,
          Expanded(
            child: TransactionInputWidget(
              value: _maxTransactions,
              onChanged: (value) => setState(() => _maxTransactions = value),
              label: AppLocalizations.of(context).maxTransactions,
              min: 0,
              max: 999,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildResultsSection() {
    if (!_hasOptimized) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: SurfaceCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 40,
                color: context.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
              Global.gapMd,
              Text(
                AppLocalizations.of(context).readyToOptimize,
                style: ThemeUtil.titleMedium.copyWith(
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              Global.gapSm,
              Text(
                AppLocalizations.of(context).clickOptimizeButtonToAnalyze,
                style: ThemeUtil.bodyMedium.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 18,
                      color: context.colorScheme.primary,
                    ),
                    Global.gapSm,
                    Text(
                      AppLocalizations.of(context).optimizationResults,
                      style: ThemeUtil.titleMedium.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Global.gapMd,
                if (_convertedResult == null || _convertedResult!.details.isEmpty)
                  Container(
                    padding: Global.padMd,
                    decoration: BoxDecoration(
                      color: context.colorScheme.errorContainer.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: Global.borderMd,
                      border: Border.all(
                        color: context.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: context.colorScheme.error,
                          size: 18,
                        ),
                        Global.gapSm,
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).noOptimizationResultsFound,
                            style: ThemeUtil.bodyMedium.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _buildResultsDisplay(),
              ],
            ),
          ),
          if (_hasOptimized && _convertedResult != null && _convertedResult!.details.isNotEmpty && _nonOptimizedComparison != null) ...[
            Global.gapLg,
            _buildComparisonSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsDisplay() {
    if (_convertedResult == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildGlobalMetricsCards(),
        Global.gapMd,
        _buildOperationsDetails(),
      ],
    );
  }

  Widget _buildGlobalMetricsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: AppLocalizations.of(context).totalAmount,
                value:
                    '${ConstantUtil.formatCurrencyAmount(_convertedResult!.totalAmount)} ${context.read<CurrencyProvider>().currencySymbol}',
                icon: Icons.account_balance_wallet,
                color: context.colorScheme.primary,
              ),
            ),
            Global.gapMd,
            Expanded(
              child: _buildMetricCard(
                title: AppLocalizations.of(context).netAmount,
                value:
                    '${ConstantUtil.formatCurrencyAmount(_convertedResult!.netAmount)} ${context.read<CurrencyProvider>().currencySymbol}',
                icon: Icons.savings,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Global.gapMd,
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: AppLocalizations.of(context).totalFees,
                value:
                    '${ConstantUtil.formatCurrencyAmount(_convertedResult!.totalFees)} ${context.read<CurrencyProvider>().currencySymbol}',
                icon: Icons.money_off,
                color: Colors.red,
              ),
            ),
            Global.gapMd,
            Expanded(
              child: _buildMetricCard(
                title: AppLocalizations.of(context).efficiency,
                value: '${_convertedResult!.efficiency.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: _convertedResult!.efficiency >= 95
                    ? Colors.green
                    : _convertedResult!.efficiency >= 90
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ],
        ),
        Global.gapMd,
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: AppLocalizations.of(context).operations,
                value: '${_convertedResult!.totalOperations}',
                icon: Icons.repeat,
                color: context.colorScheme.secondary,
              ),
            ),
            Global.gapMd,
            Expanded(
              child: _buildMetricCard(
                title: AppLocalizations.of(context).remaining,
                value:
                    '${ConstantUtil.formatCurrencyAmount(_convertedResult!.remaining)} ${context.read<CurrencyProvider>().currencySymbol}',
                icon: Icons.pending,
                color: context.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: Global.padMd,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: Global.borderMd,
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              Global.gapSm,
              Expanded(
                child: Text(
                  title,
                  style: ThemeUtil.labelMedium.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Global.gapSm,
          Text(
            value,
            style: ThemeUtil.bodyLarge.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsDetails() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                size: 18,
                color: context.colorScheme.primary,
              ),
              Global.gapSm,
              Flexible(
                child: Text(
                  AppLocalizations.of(context).transactionDetails,
                  style: ThemeUtil.titleMedium.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Global.gapMd,
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: Global.padMd,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: Global.borderMd,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(AppLocalizations.of(context).amount),
                ),
                Expanded(
                  child: _buildHeaderCell(AppLocalizations.of(context).fee),
                ),
                Expanded(
                  child: _buildHeaderCell(AppLocalizations.of(context).count),
                ),
                Expanded(
                  child: _buildHeaderCell(AppLocalizations.of(context).total),
                ),
              ],
            ),
          ),
          Column(
            children: _convertedResult!.details.map((detail) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: Global.padMd,
                constraints: const BoxConstraints(minHeight: 56),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: Global.borderMd,
                  border: Border.all(
                    color: context.colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTableCell(
                        '${ConstantUtil.formatCurrencyAmount(detail.amount)} ${context.read<CurrencyProvider>().currencySymbol}',
                      ),
                    ),
                    Expanded(
                      child: _buildTableCell(
                        '${ConstantUtil.formatCurrencyAmount(detail.fee)} ${context.read<CurrencyProvider>().currencySymbol}',
                        isGreen: false,
                      ),
                    ),
                    Expanded(child: _buildTableCell(detail.count.toString())),
                    Expanded(
                      child: _buildTableCell(
                        '${ConstantUtil.formatCurrencyAmount(detail.totalCost)} ${context.read<CurrencyProvider>().currencySymbol}',
                        isGreen: true,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) => Text(
    text,
    style: ThemeUtil.labelMedium.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    textAlign: TextAlign.center,
    softWrap: true,
    overflow: TextOverflow.visible,
  );

  Widget _buildTableCell(String text, {bool isGreen = false}) => Text(
    text,
    style: ThemeUtil.bodyMedium.copyWith(
      color: isGreen ? ThemeUtil.success : context.colorScheme.onSurface,
      fontWeight: isGreen ? FontWeight.w600 : FontWeight.normal,
    ),
    textAlign: TextAlign.center,
    softWrap: true,
    overflow: TextOverflow.visible,
  );

  Widget _buildComparisonSection() {
    if (_nonOptimizedComparison == null) return const SizedBox.shrink();

    final currencyProvider = context.read<CurrencyProvider>();
    final currencySymbol = currencyProvider.currencySymbol;

    // The total amount is always the one entered by the user
    final userAmount = _amount;

    // Data with optimization
    final optimizedNetAmount = _convertedResult!.netAmount;
    final optimizedTotalFees = _convertedResult!.totalFees;
    final optimizedTotalAmount = _convertedResult!.totalAmount; // Total amount spent

    // Data without optimization (maximum direct amount)
    final nonOptMaxNetAmount = currencyProvider.convertFromAriary(_nonOptimizedComparison!['maxNetAmount']);
    final nonOptMaxFee = currencyProvider.convertFromAriary(_nonOptimizedComparison!['maxFee']);

    // Data without optimization (if we send the same net amount with ONE single operation)
    final nonOptSameNetTotalAmount = currencyProvider.convertFromAriary(_nonOptimizedComparison!['sameNetTotalAmount']);
    final nonOptSameFee = currencyProvider.convertFromAriary(_nonOptimizedComparison!['sameNetFee']);

    // The net amount is the same as optimization by definition
    final nonOptSingleOpNetAmount = optimizedNetAmount;

    // Gains vs maximum amount (1 single operation max)
    final netGainVsMax = optimizedNetAmount - nonOptMaxNetAmount; // Net amount gain
    final feeSavingsVsMax = nonOptMaxFee - optimizedTotalFees; // Fee savings
    final totalGainVsMax = netGainVsMax + feeSavingsVsMax; // Total gain

    // DEBUG: Add debug logs to verify calculations
    print('DEBUG Comparison:');
    print('  Optimized net: ${optimizedNetAmount}');
    print('  Non-opt max net: ${nonOptMaxNetAmount}');
    print('  Net gain: ${netGainVsMax}');
    print('  Fee savings: ${feeSavingsVsMax}');
    print('  Total gain: ${totalGainVsMax}');
    print('  Should show: ${totalGainVsMax > 0.01 ? "GAIN (green)" : totalGainVsMax < -0.01 ? "LOSS (red)" : "EQUAL (grey)"}');

    // For the comparison "same net amount"
    final feeDifferenceVsSameNet = optimizedTotalFees - nonOptSameFee; // Fee difference (negative = savings)
    final exceedsBudget = nonOptSameNetTotalAmount > userAmount;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                size: 18,
                color: context.colorScheme.secondary,
              ),
              Global.gapSm,
              Flexible(
                child: Text(
                  AppLocalizations.of(context).comparisonWithWithoutOptimization,
                  style: ThemeUtil.titleMedium.copyWith(
                    color: context.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Global.gapLg,

          // Section 1: With optimization
          Container(
            padding: Global.padMd,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: Global.borderMd,
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    Global.gapSm,
                    Text(
                      AppLocalizations.of(context).withOptimization,
                      style: ThemeUtil.titleSmall.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Global.gapSm,
                _buildComparisonRow(
                  AppLocalizations.of(context).availableBudget,
                  '${ConstantUtil.formatCurrencyAmount(userAmount)} $currencySymbol',
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).netAmountSent,
                  '${ConstantUtil.formatCurrencyAmount(optimizedNetAmount)} $currencySymbol',
                  valueColor: Colors.green.shade700,
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).totalFees,
                  '${ConstantUtil.formatCurrencyAmount(optimizedTotalFees)} $currencySymbol',
                  valueColor: Colors.red.shade700,
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).totalSpent,
                  '${ConstantUtil.formatCurrencyAmount(optimizedTotalAmount)} $currencySymbol',
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).numberOfOperations,
                  '${_convertedResult!.totalOperations}',
                ),
              ],
            ),
          ),

          Global.gapMd,

          // ============ SECTION 2: Without optimization (maximum amount) ============
          Container(
            padding: Global.padMd,
            decoration: BoxDecoration(
              // ✅ CORRECTION: Inverser les conditions de couleur
              color: totalGainVsMax > 0.01
                  ? Colors.green.withValues(alpha: 0.1)  // Optimisation GAGNE (vert)
                  : totalGainVsMax < -0.01
                      ? Colors.red.withValues(alpha: 0.1)  // Optimisation PERD (rouge)
                      : Colors.grey.withValues(alpha: 0.1),
              borderRadius: Global.borderMd,
              border: Border.all(
                color: totalGainVsMax > 0.01
                    ? Colors.green.withValues(alpha: 0.3)
                    : totalGainVsMax < -0.01
                        ? Colors.red.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      totalGainVsMax > 0.01
                          ? Icons.check_circle  // ✅ Optimisation meilleure
                          : totalGainVsMax < -0.01
                              ? Icons.trending_down  // Optimisation moins bonne
                              : Icons.balance,
                      size: 16,
                      color: totalGainVsMax > 0.01
                          ? Colors.green.shade700
                          : totalGainVsMax < -0.01
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                    ),
                    Global.gapSm,
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context).withoutOptimizationMaxAmount,
                        style: ThemeUtil.titleSmall.copyWith(
                          color: totalGainVsMax > 0.01
                              ? Colors.green.shade700
                              : totalGainVsMax < -0.01
                                  ? Colors.red.shade700
                                  : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Global.gapSm,
                _buildComparisonRow(
                  AppLocalizations.of(context).availableBudget,
                  '${ConstantUtil.formatCurrencyAmount(userAmount)} $currencySymbol',
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).netAmountSent,
                  '${ConstantUtil.formatCurrencyAmount(nonOptMaxNetAmount)} $currencySymbol',
                  valueColor: totalGainVsMax > 0.01
                      ? Colors.green.shade700
                      : totalGainVsMax < -0.01
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).totalFees,
                  '${ConstantUtil.formatCurrencyAmount(nonOptMaxFee)} $currencySymbol',
                  valueColor: Colors.red.shade700,
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).numberOfOperations,
                  '1',
                ),

                // ✅ CORRECTION: Message de comparaison
                Global.gapSm,
                Divider(
                  color: totalGainVsMax > 0.01
                      ? Colors.green.withValues(alpha: 0.3)
                      : totalGainVsMax < -0.01
                          ? Colors.red.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                ),
                Global.gapSm,
                if (totalGainVsMax.abs() > 0.01) ...[
                  Row(
                    children: [
                      Icon(
                        // ✅ CORRECTION: Inverser les icônes
                        totalGainVsMax > 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: totalGainVsMax > 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      Global.gapSm,
                      Expanded(
                        child: Text(
                          // ✅ CORRECTION: Inverser les messages
                          totalGainVsMax > 0
                              ? AppLocalizations.of(context).transactionGainsVsOptimized(
                                  ConstantUtil.formatCurrencyAmount(totalGainVsMax.abs()),
                                  currencySymbol,
                                )
                              : AppLocalizations.of(context).transactionLosesVsOptimized(
                                  ConstantUtil.formatCurrencyAmount(totalGainVsMax.abs()),
                                  currencySymbol,
                                ),
                          style: ThemeUtil.bodySmall.copyWith(
                            color: totalGainVsMax > 0 ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.balance,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      Global.gapSm,
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).transactionSameResultAsOptimized,
                          style: ThemeUtil.bodySmall.copyWith(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Global.gapMd,

          // ============ SECTION 3: Without optimization (same net amount) ============
          Container(
            padding: Global.padMd,
            decoration: BoxDecoration(
              color: feeDifferenceVsSameNet > 0.01
                  ? Colors.red.withValues(alpha: 0.1)
                  : feeDifferenceVsSameNet < -0.01
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
              borderRadius: Global.borderMd,
              border: Border.all(
                color: feeDifferenceVsSameNet > 0.01
                    ? Colors.red.withValues(alpha: 0.3)
                    : feeDifferenceVsSameNet < -0.01
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      feeDifferenceVsSameNet > 0.01
                          ? Icons.trending_down
                          : feeDifferenceVsSameNet < -0.01
                              ? Icons.check_circle
                              : Icons.balance,
                      size: 16,
                      color: feeDifferenceVsSameNet > 0.01
                          ? Colors.red.shade700
                          : feeDifferenceVsSameNet < -0.01
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                    ),
                    Global.gapSm,
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context).withoutOptimizationSameNet,
                        style: ThemeUtil.titleSmall.copyWith(
                          color: feeDifferenceVsSameNet > 0.01
                              ? Colors.red.shade700
                              : feeDifferenceVsSameNet < -0.01
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Global.gapSm,
                _buildComparisonRow(
                  AppLocalizations.of(context).availableBudget,
                  '${ConstantUtil.formatCurrencyAmount(userAmount)} $currencySymbol',
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).netAmountSent,
                  '${ConstantUtil.formatCurrencyAmount(nonOptSingleOpNetAmount)} $currencySymbol',
                  valueColor: feeDifferenceVsSameNet > 0.01
                      ? Colors.red.shade700
                      : feeDifferenceVsSameNet < -0.01
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).totalFees,
                  '${ConstantUtil.formatCurrencyAmount(nonOptSameFee)} $currencySymbol',
                  valueColor: Colors.red.shade700,
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).totalSpent,
                  '${ConstantUtil.formatCurrencyAmount(nonOptSameNetTotalAmount)} $currencySymbol',
                ),
                _buildComparisonRow(
                  AppLocalizations.of(context).numberOfOperations,
                  '1',
                ),

                // Message de comparaison ou d'égalité
                Global.gapSm,
                Divider(
                  color: feeDifferenceVsSameNet > 0.01
                      ? Colors.red.withValues(alpha: 0.3)
                      : feeDifferenceVsSameNet < -0.01
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                ),
                Global.gapSm,
                if (feeDifferenceVsSameNet.abs() > 0.01) ...[
                  // Message sur les frais
                  Row(
                    children: [
                      Icon(
                        feeDifferenceVsSameNet < 0 ? Icons.check_circle : Icons.trending_down,
                        size: 14,
                        color: feeDifferenceVsSameNet < 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                      Global.gapSm,
                      Expanded(
                        child: Text(
                          feeDifferenceVsSameNet < 0
                              ? AppLocalizations.of(context).transactionLosesVsOptimized(
                                  ConstantUtil.formatCurrencyAmount(feeDifferenceVsSameNet.abs()),
                                  currencySymbol,
                                )
                              : AppLocalizations.of(context).transactionGainsVsOptimized(
                                  ConstantUtil.formatCurrencyAmount(feeDifferenceVsSameNet.abs()),
                                  currencySymbol,
                                ),
                          style: ThemeUtil.bodySmall.copyWith(
                            color: feeDifferenceVsSameNet < 0 ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.balance,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      Global.gapSm,
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).transactionSameResultAsOptimized,
                          style: ThemeUtil.bodySmall.copyWith(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (exceedsBudget) ...[
                  Global.gapXs,
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 14,
                        color: Colors.red.shade700,
                      ),
                      Global.gapXs,
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).exceedsAvailableBudget,
                          style: ThemeUtil.bodySmall.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: ThemeUtil.bodySmall.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: ThemeUtil.bodySmall.copyWith(
              color: valueColor ?? context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateNonOptimizedComparison(
    double amountInAriary,
    List<FeeInterval> intervals,
    FeeOptimizerResult optimizedResult,
  ) {
    // Trouver le montant net maximum avec le budget disponible
    double maxNetAmount = 0;
    double maxFee = 0;

    for (final interval in intervals) {
      final minAmount = interval.minAmount ?? 0;
      final maxAmount = interval.maxAmount ?? double.infinity;
      
      // Calculer le montant net maximum possible dans cet intervalle
      double netAmount;
      
      if (interval.feeType == FeeType.percentage) {
        // budget = netAmount + netAmount * (fee/100)
        // budget = netAmount * (1 + fee/100)
        // netAmount = budget / (1 + fee/100)
        netAmount = amountInAriary / (1 + (interval.fee ?? 0) / 100.0);
      } else {
        netAmount = amountInAriary - (interval.fee ?? 0);
      }
      
      // Limiter au max de l'intervalle
      netAmount = min(netAmount, maxAmount);
      
      // Vérifier si valide
      if (netAmount >= minAmount && netAmount <= maxAmount && netAmount > 0) {
        final fee = interval.feeType == FeeType.percentage
            ? netAmount * ((interval.fee ?? 0) / 100.0)
            : (interval.fee ?? 0);
        
        final totalCost = netAmount + fee;
        
        // Vérifier que ça ne dépasse pas le budget (avec tolérance)
        if (totalCost <= amountInAriary + 0.01) {
          if (netAmount > maxNetAmount) {
            maxNetAmount = netAmount;
            maxFee = fee;
          }
        }
      }
    }

    // Calculer si on prend le même montant net que l'optimisation
    double sameNetFee = 0;
    double sameNetTotalAmount = 0;
    final optimizedNetAmount = optimizedResult.netAmount;

    for (final interval in intervals) {
      final minAmount = interval.minAmount ?? 0;
      final maxAmount = interval.maxAmount ?? double.infinity;
      
      if (optimizedNetAmount >= minAmount && optimizedNetAmount <= maxAmount) {
        sameNetFee = interval.feeType == FeeType.percentage
            ? optimizedNetAmount * ((interval.fee ?? 0) / 100.0)
            : (interval.fee ?? 0);
        sameNetTotalAmount = optimizedNetAmount + sameNetFee;
        break;
      }
    }

    return {
      'maxNetAmount': maxNetAmount,
      'maxFee': maxFee,
      'sameNetFee': sameNetFee,
      'sameNetTotalAmount': sameNetTotalAmount,
    };
  }

  Widget _buildOptimizeButton() => Container(
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
      text: AppLocalizations.of(context).optimize,
      onPressed: _optimize,
      isLoading: _isOptimizing,
    ),
  );

  void _generateResults() async {
    if (_selectedProvider == null || _amount <= 0) {
      setState(() {
        _result = null;
        _hasOptimized = true;
        _nonOptimizedComparison = null;
      });
      return;
    }

    if (_minTransactions > 0 &&
        _maxTransactions > 0 &&
        _minTransactions > _maxTransactions) {
      setState(() {
        _result = null;
        _hasOptimized = true;
        _nonOptimizedComparison = null;
      });
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            AppToast.error(
              context,
              AppLocalizations.of(context).minTransactionsCannotBeGreaterThanMax,
            );
          }
        });
      }
      return;
    }

    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );
    final localizations = AppLocalizations.of(context);

    try {
      final db = DatabaseUtil();
      final feeIntervalMaps = await db.query(
        ConstantUtil.tableFeeIntervals,
        where: '${ConstantUtil.columnProviderId} = ?',
        whereArgs: [int.tryParse(_selectedProvider!.id)],
      );
      final intervals = feeIntervalMaps
          .map((map) => FeeInterval.fromMap(map))
          .toList();

      if (intervals.isEmpty) {
        setState(() {
          _result = null;
          _hasOptimized = true;
          _nonOptimizedComparison = null;
        });
        // Use mounted check and avoid using context after await
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppToast.info(
                context,
                AppLocalizations.of(context).noFeeIntervalsFound,
              );
            }
          });
        }
        return;
      }

      final amountInAriary = currencyProvider.convertToAriary(_amount);

      const maxSafeAmount = 1e15;
      if (amountInAriary > maxSafeAmount) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppToast.error(
                context,
                AppLocalizations.of(context).amountExceedsMaximumLimit(
                  ConstantUtil.formatCurrencyAmount(
                    currencyProvider.convertFromAriary(maxSafeAmount),
                  ),
                  currencyProvider.currencySymbol,
                ),
              );
            }
          });
        }
        setState(() {
          _result = null;
          _hasOptimized = true;
          _nonOptimizedComparison = null;
        });
        return;
      }

      // Optimization calculation
      final optimizationResult = FeeOptimizerUtil.calculateOptimalOperations(
        amountInAriary,
        intervals,
        maxOperations: _maxTransactions,
        minOperations: _minTransactions,
        localizations: localizations,
      );

      // Calculation without optimization
      final nonOptimizedData = _calculateNonOptimizedComparison(
        amountInAriary,
        intervals,
        optimizationResult,
      );

      final coveragePercentage =
          (optimizationResult.netAmount / amountInAriary) * 100;
      final hasLowCoverage = coveragePercentage < 80.0;

      if (optimizationResult.details.isEmpty && amountInAriary > 0) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppToast.error(
                context,
                AppLocalizations.of(context).optimizationFailedNoValidSolution,
              );
            }
          });
        }
      } else if (hasLowCoverage && optimizationResult.details.isNotEmpty) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppToast.warning(
                context,
                AppLocalizations.of(context).optimizationIncomplete(coveragePercentage.toStringAsFixed(1)),
              );
            }
          });
        }
      }

      setState(() {
        _result = optimizationResult;
        _hasOptimized = true;
        _nonOptimizedComparison = nonOptimizedData;
      });
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            String errorMessage = AppLocalizations.of(context).failedToCalculateOptimization;

            if (e.toString().contains('Montant trop élevé')) {
              errorMessage = AppLocalizations.of(context).amountExceedsMaximumAllowedLimit;
            } else if (e.toString().contains('minOperations')) {
              errorMessage = AppLocalizations.of(context).invalidTransactionRangeConstraints;
            } else if (e.toString().contains('Aucune option')) {
              errorMessage = AppLocalizations.of(context).noValidFeeIntervalsAvailable;
            }

            AppToast.error(context, errorMessage);
          }
        });
      }
      setState(() {
        _result = null;
        _hasOptimized = true;
        _nonOptimizedComparison = null;
      });
    }
  }

  void _optimize() async {
    if (_amount <= 0) {
      AppToast.error(
        context,
        AppLocalizations.of(context).pleaseEnterValidAmount,
      );
      return;
    }
    if (_minTransactions > _maxTransactions &&
        _minTransactions > 0 &&
        _maxTransactions > 0) {
      AppToast.error(
        context,
        AppLocalizations.of(context).minTransactionsCannotBeGreaterThanMax,
      );
      return;
    }
    if (_selectedProvider == null) {
      AppToast.error(
        context,
        AppLocalizations.of(context).pleaseSelectProvider,
      );
      return;
    }

    setState(() => _isOptimizing = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      _generateResults();
      setState(() => _isOptimizing = false);
    }
  }
}
