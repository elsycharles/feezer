import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../model/provider_model.dart';
import '../../model/optimization_result_model.dart';
import '../../model/fee_interval_model.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import '../../util/theme_util.dart';
import '../../util/extensions_util.dart';
import '../../util/route_util.dart';
import '../../widget/app_toast.dart';
import '../../widget/app_bar.dart' as custom;
import 'widget/amount_input_widget.dart';
import 'widget/transaction_input_widget.dart';

import '../../widget/collapsible_card.dart';
import '../../widget/loading_button.dart';
import '../../widget/surface_card.dart';
import '../../sandbox/util/database_util.dart';
import '../../sandbox/util/constant_util.dart';
import '../../sandbox/util/fee_minimizer_util.dart';

/// Screen for optimizing fees based on transaction amounts and ranges
class OptimizeFeeScreen extends StatefulWidget {
  const OptimizeFeeScreen({super.key});

  @override
  State<OptimizeFeeScreen> createState() => _State();
}

class _State extends State<OptimizeFeeScreen> {
  DateTime? _lastBackPressed;
  
  final _providers = <Provider>[];

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
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final db = DatabaseUtil();
    final providerMaps = await db.query(ConstantUtil.tableProviders);
    final loadedProviders = providerMaps.map((map) => Provider.fromMap(map)).toList();
    if (mounted) {
      setState(() {
        _providers
          ..clear()
          ..addAll(loadedProviders);
        _selectedProvider = _providers.isNotEmpty ? _providers.first : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canNavigateBack = GoRouter.of(context).canPop();

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
          leading: null, // Home screen - no back button needed
          menuExcludeRoutes: const [AppRouter.homeRoute],
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
                  horizontal: MediaQuery.of(context).textScaler.scale(1.0) > 1.3 ? 12 : 0,
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
            SafeArea(
              top: false,
              child: _buildOptimizeButton(),
            ),
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
          child: DropdownButton<Provider>(
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
                          Icons.business,
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
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Add new provider option
              DropdownMenuItem<Provider>(
                value: null, // Special value to indicate "add new"
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
                final result = await GoRouter.of(context).push<Provider>(AppRouter.newProviderRoute);
                // If a new provider was created (returned as result), add it to the list
                if (result != null) {
                  setState(() {
                    _providers.add(result);
                    _selectedProvider = result;
                    _hasOptimized = false;
                    _results.clear();
                  });
                  
                  // Automatically redirect to Provider Details to complete the setup
                  if (mounted) {
                    await GoRouter.of(context).push(
                      '${AppRouter.providerDetailRoute}/${result.id}',
                      extra: result,
                    );
                  }
                }
              } else {
                setState(() {
                  _selectedProvider = provider;
                  _hasOptimized = false;
                  _results.clear();
                });
              }
            },
          ),
        ),
      ),
    ],
  );  Widget _buildAmountSection() => CollapsibleCard(
    title: AppLocalizations.of(context).amountToOptimize,
    subtitle: AppLocalizations.of(context).enterTransactionAmountToOptimize,
    titleStyle: ThemeUtil.titleMedium.copyWith(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    ),
    children: [
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
    ],
  );

  Widget _buildTransactionSection() => CollapsibleCard(
    title: AppLocalizations.of(context).transactionRange,
    subtitle: AppLocalizations.of(context).defineMinMaxTransactions,
    titleStyle: ThemeUtil.titleMedium.copyWith(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    ),
    children: [
      Row(
        children: [
          Expanded(
            child: TransactionInputWidget(
              value: _minTransactions,
              onChanged: (value) => setState(() => _minTransactions = value),
              label: AppLocalizations.of(context).minTransactions,
              min: 1,
              max: 999,
            ),
          ),
          Global.gapLg,
          Expanded(
            child: TransactionInputWidget(
              value: _maxTransactions,
              onChanged: (value) => setState(() => _maxTransactions = value),
              label: AppLocalizations.of(context).maxTransactions,
              min: 1,
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
                      size: 18,
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
    mainAxisSize: MainAxisSize.min,
    children: [
      // Header row
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: Global.padMd,
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
      // Data rows - display all results without scroll
      Column(
        children: _results.map((result) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: Global.padMd,
            // Add minimum height for accessibility
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: Global.borderMd,
              // Add subtle border for better visual separation
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildTableCell(result.interval)),
                Expanded(child: _buildTableCell(result.fee, isGreen: true)),
                Expanded(child: _buildTableCell(result.count.toString())),
                Expanded(child: _buildTableCell(result.total, isGreen: true)),
              ],
            ),
          );
        }).toList(),
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

  void _generateResults() async {
    // Validation
    if (_selectedProvider == null ||
        _amount <= 0 ||
        _minTransactions > _maxTransactions) {
      setState(() {
        _results = [];
        _hasOptimized = true;
      });
      return;
    }

    try {
      // Load fee intervals for the selected provider
      final db = DatabaseUtil();
      final feeIntervalMaps = await db.query(
        ConstantUtil.tableFeeIntervals,
        where: '${ConstantUtil.columnProviderId} = ?',
        whereArgs: [int.tryParse(_selectedProvider!.id)],
      );
      final intervals = feeIntervalMaps.map((map) => FeeInterval.fromMap(map)).toList();

      if (intervals.isEmpty) {
        setState(() {
          _results = [];
          _hasOptimized = true;
        });
        if (mounted) {
          AppToast.info(context, AppLocalizations.of(context).noProvidersFound);
        }
        return;
      }

      // Calculate optimal operations
      final optimizationResult = FeeOptimizerUtil.calculateOptimalOperations(
        _amount.toDouble(),
        intervals,
        maxOperations: _maxTransactions,
        minOperations: _minTransactions,
      );

      // Convert to OptimizationResult format for display
      final results = optimizationResult.details.map((detail) {
        final interval = intervals.firstWhere(
          (interval) => interval.minAmount == detail.amount && interval.fee == detail.fee,
          orElse: () => FeeInterval(
            id: '',
            minAmount: detail.amount,
            maxAmount: detail.amount,
            fee: detail.fee,
          ),
        );

        return OptimizationResult(
          interval: interval.id!.isEmpty ? '${detail.amount.toInt()} Ar' : interval.formattedRange,
          fee: '${detail.fee.toInt()} Ar',
          count: detail.count,
          total: '${(detail.amount * detail.count).toInt()} Ar',
        );
      }).toList();

      setState(() {
        _results = results;
        _hasOptimized = true;
      });
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to calculate optimization');
      }
      setState(() {
        _results = [];
        _hasOptimized = true;
      });
    }
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
