import 'package:flutter/material.dart';

import '../../model/provider_model.dart';
import '../../model/optimization_result_model.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import '../../util/theme_util.dart';
import '../../util/extensions_util.dart';
import '../../widget/app_toast.dart';
import '../../widget/app_bar.dart' as custom;
import 'widget/amount_input_widget.dart';
import 'widget/transaction_input_widget.dart';

import '../../widget/loading_button.dart';
import '../../widget/surface_card.dart';

/// Screen for optimizing fees based on transaction amounts and ranges
class OptimizeFeeScreen extends StatefulWidget {
  const OptimizeFeeScreen({super.key});

  @override
  State<OptimizeFeeScreen> createState() => _State();
}

class _State extends State<OptimizeFeeScreen> {
  // Sample providers - replace with actual data
  final _providers = [
    Provider(
      id: '1',
      name: 'Kuda Bank',
      description: 'Traditional banking',
      iconName: 'account_balance',
    ),
    Provider(
      id: '2',
      name: 'MVola',
      description: 'Mobile money',
      iconName: 'phone_android',
    ),
    Provider(
      id: '3',
      name: 'Orange Money',
      description: 'Mobile financial services',
      iconName: 'mobile_friendly',
    ),
  ];

  Provider? _selectedProvider;
  int _amount = 10000;
  int _minTransactions = 1;
  int _maxTransactions = 10;
  List<OptimizationResult> _results = [];
  bool _hasOptimized = false;
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    _selectedProvider = _providers.first;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.theme.scaffoldBackgroundColor,
    appBar: custom.AppBar(
      title: AppLocalizations.of(context).optimizeFee,
      leading: IconButton(
        onPressed: context.pop,
        icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                  SizedBox(height: 80), // Bottom padding for button
                ],
              ),
            ),
          ),
          _buildOptimizeButton(),
        ],
      ),
    ),
  );

  Widget _buildProviderSection() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: 18,
                color: context.colorScheme.primary,
              ),
              Global.gapSm,
              Text(
                AppLocalizations.of(context).financialProvider,
                style: ThemeUtil.titleMedium.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Global.gapSm,
          Text(
            AppLocalizations.of(context).chooseProviderToAnalyze,
            style: ThemeUtil.bodyMedium.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Global.gapMd,
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: Global.borderMd,
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Provider>(
                value: _selectedProvider,
                isExpanded: true,
                padding: Global.padMd,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                items: _providers
                    .map(
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
                                Icons.business,
                                color: context.colorScheme.primary,
                                size: 20,
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
                                  Text(
                                    provider.description,
                                    style: ThemeUtil.bodySmall.copyWith(
                                      color:
                                          context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (provider) {
                  setState(() {
                    _selectedProvider = provider;
                    _hasOptimized = false;
                    _results.clear();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAmountSection() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).amountToOptimize,
            style: ThemeUtil.titleMedium.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Global.gapSm,
          Text(
            AppLocalizations.of(context).enterTransactionAmountToOptimize,
            style: ThemeUtil.bodyMedium.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Global.gapLg,
          AmountInputWidget(
            value: _amount,
            onChanged: (value) {
              setState(() {
                _amount = value;
                _hasOptimized = false;
                _results.clear();
              });
            },
            label: AppLocalizations.of(context).amount,
            min: 1,
            max: 9999999,
          ),
          Global.gapLg,
        ],
      ),
    ),
  );

  Widget _buildTransactionSection() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).transactionRange,
            style: ThemeUtil.titleMedium.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Global.gapSm,
          Text(
            AppLocalizations.of(context).defineMinMaxTransactions,
            style: ThemeUtil.bodyMedium.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Global.gapLg,
          Row(
            children: [
              Expanded(
                child: TransactionInputWidget(
                  value: _minTransactions,
                  onChanged: (value) =>
                      setState(() => _minTransactions = value),
                  label: AppLocalizations.of(context).minTransactions,
                  min: 1,
                  max: 999,
                ),
              ),
              Global.gapLg,
              Expanded(
                child: TransactionInputWidget(
                  value: _maxTransactions,
                  onChanged: (value) =>
                      setState(() => _maxTransactions = value),
                  label: AppLocalizations.of(context).maxTransactions,
                  min: 1,
                  max: 999,
                ),
              ),
            ],
          ),
          Global.gapMd,
        ],
      ),
    ),
  );

  Widget _buildResultsSection() {
    if (!_hasOptimized) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: SurfaceCard(
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
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
      child: SurfaceCard(
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
                const Spacer(),
                Text(
                  '${_results.length} results',
                  style: ThemeUtil.bodyMedium.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Global.gapMd,
            if (_results.isEmpty)
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
                      size: 20,
                    ),
                    Global.gapSm,
                    Expanded(
                      child: Text(
                        'No optimization results found. Please check your input parameters.',
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: context.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildResultsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable() => Column(
    children: [
      // Header row
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: Global.borderMd,
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildHeaderCell(AppLocalizations.of(context).interval),
            ),
            Expanded(child: _buildHeaderCell(AppLocalizations.of(context).fee)),
            Expanded(
              child: _buildHeaderCell(AppLocalizations.of(context).count),
            ),
            Expanded(
              child: _buildHeaderCell(AppLocalizations.of(context).total),
            ),
          ],
        ),
      ),
      // Data rows
      ..._results.map(
        (result) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: Global.padMd,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: Global.borderMd,
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildTableCell(result.interval)),
              Expanded(child: _buildTableCell(result.fee, isGreen: true)),
              Expanded(child: _buildTableCell(result.count.toString())),
              Expanded(child: _buildTableCell(result.total, isGreen: true)),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildHeaderCell(String text) => Text(
    text,
    style: ThemeUtil.labelMedium.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    textAlign: TextAlign.center,
  );

  Widget _buildTableCell(String text, {bool isGreen = false}) => Text(
    text,
    style: ThemeUtil.bodyMedium.copyWith(
      color: isGreen ? ThemeUtil.success : context.colorScheme.onSurface,
      fontWeight: isGreen ? FontWeight.w600 : FontWeight.normal,
    ),
    textAlign: TextAlign.center,
  );

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

  void _generateResults() {
    // Enhanced optimization logic
    if (_selectedProvider == null ||
        _amount <= 0 ||
        _minTransactions > _maxTransactions) {
      setState(() {
        _results = [];
        _hasOptimized = true;
      });
      return;
    }

    // Simulate optimization calculation
    final baseRate = _amount * 0.02; // 2% base rate
    final optimizedFee = (baseRate * _minTransactions).round();
    final totalCost = optimizedFee * _maxTransactions;

    setState(() {
      _hasOptimized = true;
      _results = [
        OptimizationResult(
          interval: '${(_amount * 0.2).round()} - ${(_amount * 1.5).round()}',
          fee: '${optimizedFee.toString()} Ar',
          count: _maxTransactions,
          total: '${totalCost.toString()} Ar',
        ),
        OptimizationResult(
          interval: '${(_amount * 0.5).round()} - ${(_amount * 2).round()}',
          fee: '${(optimizedFee * 1.2).round().toString()} Ar',
          count: (_maxTransactions * 0.8).round(),
          total: '${(totalCost * 0.9).round().toString()} Ar',
        ),
      ];
    });
  }

  void _optimize() async {
    // Validation
    if (_amount <= 0) {
      AppToast.error(
        context,
        AppLocalizations.of(context).pleaseEnterValidAmount,
      );
      return;
    }
    if (_minTransactions > _maxTransactions) {
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

    // Simulate optimization process
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      _generateResults();
      setState(() => _isOptimizing = false);
    }
  }
}
