import 'package:flutter/material.dart';

import '../../../core/optimizer/fee_comparison.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/fee_minimizer_detail_model.dart';
import '../../../model/fee_minimizer_result_model.dart';
import '../../../styles/global.dart';
import '../../../util/constant_util.dart';
import '../../../util/theme_util.dart';
import '../../../widget/surface_card.dart';

String _money(double value, String symbol) =>
    '${ConstantUtil.formatCurrencyAmount(value)} $symbol';

/// Shown before the first optimization.
class ResultsPlaceholder extends StatelessWidget {
  const ResultsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return SurfaceCard(
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          Global.gapMd,
          Text(
            l10n.readyToOptimize,
            style: ThemeUtil.titleMedium.copyWith(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          Global.gapSm,
          Text(
            l10n.clickOptimizeButtonToAnalyze,
            style: ThemeUtil.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Colored banner with an icon and a message.
class ResultBanner extends StatelessWidget {
  const ResultBanner({
    super.key,
    required this.message,
    this.color,
    this.icon = Icons.warning_outlined,
  });

  final String message;
  final Color? color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.error;
    return Container(
      padding: Global.padMd,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: Global.borderMd,
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: tint, size: 18),
          Global.gapSm,
          Expanded(
            child: Text(
              message,
              style: ThemeUtil.bodyMedium.copyWith(color: tint),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary metrics and transaction list of an optimized plan.
class OptimizationResultsCard extends StatelessWidget {
  const OptimizationResultsCard({
    super.key,
    required this.result,
    required this.currencySymbol,
    this.message,
  });

  /// Plan expressed in the display currency.
  final FeeOptimizerResult result;
  final String currencySymbol;

  /// Optional message shown when there is no plan.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.analytics, title: l10n.optimizationResults),
          Global.gapMd,
          if (!result.isSuccess)
            ResultBanner(message: message ?? l10n.noOptimizationResultsFound)
          else ...[
            _MetricsGrid(result: result, currencySymbol: currencySymbol),
            if (!result.isProvenOptimal) ...[
              Global.gapMd,
              ResultBanner(
                message: l10n.optimizationNotProven,
                color: colorScheme.tertiary,
                icon: Icons.info_outline,
              ),
            ],
            Global.gapMd,
            TransactionDetailsTable(
              details: result.details,
              currencySymbol: currencySymbol,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.result, required this.currencySymbol});

  final FeeOptimizerResult result;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final efficiency = result.efficiency;
    final metrics = [
      (
        l10n.totalAmount,
        _money(result.totalSpent, currencySymbol),
        Icons.account_balance_wallet,
        colorScheme.primary,
      ),
      (
        l10n.netAmount,
        _money(result.netAmount, currencySymbol),
        Icons.savings,
        ThemeUtil.success,
      ),
      (
        l10n.totalFees,
        _money(result.totalFees, currencySymbol),
        Icons.money_off,
        ThemeUtil.error,
      ),
      (
        l10n.efficiency,
        '${efficiency.toStringAsFixed(2)}%',
        Icons.trending_up,
        efficiency >= 95
            ? ThemeUtil.success
            : (efficiency >= 90 ? ThemeUtil.warning : ThemeUtil.error),
      ),
      (
        l10n.operations,
        '${result.totalOperations}',
        Icons.repeat,
        colorScheme.secondary,
      ),
      (
        l10n.remaining,
        _money(result.remaining, currencySymbol),
        Icons.pending,
        colorScheme.tertiary,
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < metrics.length; i += 2) ...[
          if (i > 0) Global.gapMd,
          Row(
            children: [
              Expanded(child: _MetricCard(metric: metrics[i])),
              Global.gapMd,
              Expanded(child: _MetricCard(metric: metrics[i + 1])),
            ],
          ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final (String, String, IconData, Color) metric;

  @override
  Widget build(BuildContext context) {
    final (title, value, icon, color) = metric;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: Global.padMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: Global.borderMd,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
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
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Global.gapSm,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: ThemeUtil.bodyLarge.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Table of transaction groups (amount, fee, count, total cost).
class TransactionDetailsTable extends StatelessWidget {
  const TransactionDetailsTable({
    super.key,
    required this.details,
    required this.currencySymbol,
  });

  final List<FeeOptimizerDetail> details;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.list_alt, title: l10n.transactionDetails),
          Global.gapMd,
          _row(context, [
            l10n.amount,
            l10n.fee,
            l10n.count,
            l10n.total,
          ], header: true),
          for (final detail in details)
            _row(context, [
              _money(detail.amount, currencySymbol),
              _money(detail.fee, currencySymbol),
              '${detail.count}',
              _money(detail.totalCost, currencySymbol),
            ]),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, List<String> cells, {bool header = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    TextStyle style(int index) => header
        ? ThemeUtil.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          )
        : ThemeUtil.bodyMedium.copyWith(
            color: index == 3 ? ThemeUtil.success : colorScheme.onSurface,
            fontWeight: index == 3 ? FontWeight.w600 : FontWeight.normal,
          );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: Global.padMd,
      constraints: BoxConstraints(minHeight: header ? 0 : 56),
      decoration: BoxDecoration(
        color: header
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surface,
        borderRadius: Global.borderMd,
        border: header
            ? null
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: i == 0 ? 2 : 1,
              child: Text(
                cells[i],
                style: style(i),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

/// "With / without optimization" comparison.
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({
    super.key,
    required this.comparison,
    required this.currencySymbol,
    required this.onShowWithoutOptimization,
    required this.onShowSameNet,
  });

  /// Comparison expressed in the display currency.
  final FeeComparison comparison;
  final String currencySymbol;
  final VoidCallback onShowWithoutOptimization;
  final VoidCallback onShowSameNet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final optimized = comparison.optimized;
    final naive = comparison.withoutOptimization;
    final sameNet = comparison.sameNetWithoutOptimization;
    final tolerance = 1e-6 * (optimized.budget.abs() + 1);

    final extraNet = comparison.extraNetAmount;
    final saved = comparison.feesSavedForSameNet;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.compare_arrows,
            title: l10n.comparisonWithWithoutOptimization,
          ),
          Global.gapLg,
          _ComparisonBlock(
            title: l10n.withOptimization,
            tone: _Tone.good,
            rows: [
              (l10n.enteredAmount, _money(optimized.budget, currencySymbol)),
              (l10n.netAmountSent, _money(optimized.netAmount, currencySymbol)),
              (l10n.totalFees, _money(optimized.totalFees, currencySymbol)),
              (l10n.totalSpent, _money(optimized.totalSpent, currencySymbol)),
              (l10n.numberOfOperations, '${optimized.totalOperations}'),
            ],
          ),
          Global.gapMd,
          _ComparisonBlock(
            title: l10n.withoutOptimizationMaxAmount,
            tone: _toneFor(extraNet, tolerance),
            onTap: onShowWithoutOptimization,
            rows: [
              (l10n.enteredAmount, _money(naive.budget, currencySymbol)),
              (l10n.netAmountSent, _money(naive.netAmount, currencySymbol)),
              (l10n.totalFees, _money(naive.totalFees, currencySymbol)),
              (l10n.numberOfOperations, '${naive.totalOperations}'),
            ],
            footer: _differenceText(l10n, extraNet, tolerance),
          ),
          Global.gapMd,
          if (sameNet == null)
            _ComparisonBlock(
              title: l10n.withoutOptimizationSameNet,
              tone: _Tone.warning,
              rows: const [],
              footer: l10n.noValidIntervalForComparison,
            )
          else
            _ComparisonBlock(
              title: l10n.withoutOptimizationSameNet,
              tone: _toneFor(saved!, tolerance),
              onTap: onShowSameNet,
              rows: [
                (l10n.netAmountSent, _money(sameNet.netAmount, currencySymbol)),
                (l10n.totalFees, _money(sameNet.totalFees, currencySymbol)),
                (l10n.totalSpent, _money(sameNet.totalSpent, currencySymbol)),
                (l10n.numberOfOperations, '${sameNet.totalOperations}'),
              ],
              footer: _differenceText(l10n, saved, tolerance),
              warning: comparison.sameNetExceedsBudget
                  ? l10n.exceedsEnteredAmount
                  : null,
            ),
        ],
      ),
    );
  }

  /// [advantage] > 0 means the optimization is better by that amount.
  _Tone _toneFor(double advantage, double tolerance) => advantage > tolerance
      ? _Tone.bad
      : (advantage < -tolerance ? _Tone.good : _Tone.neutral);

  String _differenceText(
    AppLocalizations l10n,
    double advantage,
    double tolerance,
  ) {
    final amount = ConstantUtil.formatCurrencyAmount(advantage.abs());
    if (advantage > tolerance) {
      return l10n.transactionLosesVsOptimized(amount, currencySymbol);
    }
    if (advantage < -tolerance) {
      return l10n.transactionGainsVsOptimized(amount, currencySymbol);
    }
    return l10n.transactionSameResultAsOptimized;
  }
}

enum _Tone { good, bad, neutral, warning }

class _ComparisonBlock extends StatelessWidget {
  const _ComparisonBlock({
    required this.title,
    required this.tone,
    required this.rows,
    this.footer,
    this.warning,
    this.onTap,
  });

  final String title;
  final _Tone tone;
  final List<(String, String)> rows;
  final String? footer;
  final String? warning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (color, icon) = switch (tone) {
      _Tone.good => (ThemeUtil.success, Icons.check_circle),
      _Tone.bad => (ThemeUtil.error, Icons.trending_down),
      _Tone.neutral => (colorScheme.onSurfaceVariant, Icons.balance),
      _Tone.warning => (ThemeUtil.warning, Icons.warning_amber),
    };
    return InkWell(
      onTap: onTap,
      borderRadius: Global.borderMd,
      child: Container(
        padding: Global.padMd,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: Global.borderMd,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                Global.gapSm,
                Expanded(
                  child: Text(
                    title,
                    style: ThemeUtil.titleSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, size: 18, color: color),
              ],
            ),
            Global.gapSm,
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: ThemeUtil.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: ThemeUtil.bodySmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (footer != null) ...[
              if (rows.isNotEmpty) Divider(color: color.withValues(alpha: 0.3)),
              Text(
                footer!,
                style: ThemeUtil.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (warning != null) ...[
              Global.gapXs,
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 14,
                    color: ThemeUtil.error,
                  ),
                  Global.gapXs,
                  Expanded(
                    child: Text(
                      warning!,
                      style: ThemeUtil.bodySmall.copyWith(
                        color: ThemeUtil.error,
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        Global.gapSm,
        Expanded(
          child: Text(
            title,
            style: ThemeUtil.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
