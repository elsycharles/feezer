import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/fee_minimizer_detail_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import '../../theme/app_theme.dart';
import '../../util/money.dart';
import '../../widget/common.dart';
import 'optimize_screen.dart';

/// Placeholder shown while the optimizer runs.
class ResultSkeleton extends StatelessWidget {
  const ResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Skeleton(height: 168, radius: Space.radiusLg),
      Space.gapMd,
      Skeleton(height: 60, radius: Space.radiusMd),
      Space.gapXl,
      Skeleton(height: 176, radius: Space.radiusLg),
    ],
  );
}

/// Wording that depends on the operation: withdrawals or transfers.
class _Words {
  const _Words(this.l10n, this.withdrawal);

  final AppLocalizations l10n;
  final bool withdrawal;

  String get receives =>
      withdrawal ? l10n.cashYouReceive : l10n.recipientReceives;
  String count(int n) =>
      withdrawal ? l10n.withdrawalCountLabel(n) : l10n.transferCountLabel(n);
  String get countColumn =>
      withdrawal ? l10n.withdrawalsLabel : l10n.transfersLabel;
  String action(String amount) =>
      withdrawal ? l10n.withdrawAmount(amount) : l10n.sendAmount(amount);
  String fee(String amount) =>
      withdrawal ? l10n.feePerWithdrawal(amount) : l10n.feePerTransfer(amount);
  String get classic =>
      withdrawal ? l10n.classicExplanationWithdrawal : l10n.classicExplanation;
  String get plan => withdrawal ? l10n.planTitleWithdrawal : l10n.planTitle;
}

/// Result of an optimization.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.outcome});

  final OptimizationOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final words = _Words(l10n, outcome.isWithdrawal);
    final result = outcome.result;
    if (!result.isSuccess) {
      final message = switch (result.status) {
        OptimizationStatus.noFeeIntervals => l10n.noFeeIntervalsFound,
        OptimizationStatus.budgetTooSmall => l10n.optimizationBudgetTooSmall,
        OptimizationStatus.constraintsUnsatisfiable =>
          l10n.optimizationConstraintsUnsatisfiable,
        OptimizationStatus.stepTooLarge => l10n.optimizationStepTooLarge,
        OptimizationStatus.success => l10n.noOptimizationResultsFound,
      };
      return FadeSlideIn(
        child: SectionCard(
          child: EmptyState(icon: Icons.info_outline_rounded, title: message),
        ),
      );
    }

    final comparison = outcome.comparison;
    final extra = comparison.extraNetAmount;
    final saved = comparison.feesSavedForSameNet ?? 0;
    final tolerance = 1e-6 * (result.budget + 1);

    final notes = <Widget>[
      if (extra > tolerance)
        _Note(
          tone: _Tone.success,
          title: l10n.gainTitle(context.money(extra)),
          message: l10n.vsUsualWay,
        )
      else if (saved > tolerance)
        _Note(
          tone: _Tone.success,
          title: l10n.feesSavedTitle(context.money(saved)),
          message: l10n.vsUsualWay,
        )
      else if (extra >= -tolerance)
        _Note(tone: _Tone.neutral, title: l10n.alreadyOptimalTitle),
      if (outcome.limitCost > 0)
        _Note(
          tone: _Tone.warning,
          title: l10n.limitCost(context.money(outcome.limitCost)),
        ),
    ];

    // Sections appear one after the other.
    var step = 0;
    Widget appear(Widget child) => FadeSlideIn(index: step++, child: child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        appear(_Highlight(result: result, words: words)),
        for (final note in notes) ...[Space.gapMd, appear(note)],
        Space.gapXl,
        appear(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionLabel(words.plan),
              _PlanCard(result: result, words: words),
            ],
          ),
        ),
        Space.gapXl,
        appear(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionLabel(l10n.compareTitle),
              _ComparisonCard(outcome: outcome, words: words),
            ],
          ),
        ),
      ],
    );
  }
}

/// Main figure: what is actually received.
class _Highlight extends StatelessWidget {
  const _Highlight({required this.result, required this.words});

  final FeeOptimizerResult result;
  final _Words words;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final on = palette.onHighlight;
    final muted = on.withValues(alpha: 0.78);

    Widget stat(String label, double value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.labelSmall?.copyWith(color: muted)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              context.money(value),
              style: context.text.titleMedium?.copyWith(
                color: on,
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(Space.xl),
      decoration: BoxDecoration(
        color: palette.highlight,
        borderRadius: BorderRadius.circular(Space.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  words.receives,
                  style: context.text.titleSmall?.copyWith(color: muted),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: on.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  result.isProvenOptimal ? l10n.bestSplit : l10n.goodSplit,
                  style: context.text.labelSmall?.copyWith(color: on),
                ),
              ),
            ],
          ),
          Space.gapSm,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedMoney(
              result.netAmount,
              style: context.text.displayMedium?.copyWith(color: on),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            words.count(result.totalOperations),
            style: context.text.bodyMedium?.copyWith(color: muted),
          ),
          Space.gapLg,
          Container(height: 1, color: on.withValues(alpha: 0.2)),
          Space.gapLg,
          Row(
            children: [
              stat(l10n.feesLabel, result.totalFees),
              stat(l10n.debitedLabel, result.totalSpent),
              stat(l10n.leftLabel, result.remaining),
            ],
          ),
        ],
      ),
    );
  }
}

enum _Tone { success, warning, neutral }

/// Short message with a colored edge.
class _Note extends StatelessWidget {
  const _Note({required this.tone, required this.title, this.message});

  final _Tone tone;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    final (background, foreground, accent) = switch (tone) {
      _Tone.success => (
        palette.successContainer,
        palette.onSuccessContainer,
        palette.success,
      ),
      _Tone.warning => (
        palette.warningContainer,
        palette.onWarningContainer,
        palette.warning,
      ),
      _Tone.neutral => (
        colors.surfaceContainerLow,
        colors.onSurface,
        colors.outline,
      ),
    };
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Space.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.md,
                  Space.md,
                  Space.lg,
                  Space.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleSmall?.copyWith(
                        color: foreground,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        message!,
                        style: context.text.bodySmall?.copyWith(
                          color: foreground.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step-by-step list of the transactions to make.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.result, required this.words});

  final FeeOptimizerResult result;
  final _Words words;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = result.details;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const Divider(indent: Space.lg, endIndent: Space.lg),
            _PlanRow(detail: details[i], words: words),
          ],
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.lg,
              vertical: Space.md,
            ),
            color: context.colors.surfaceContainer,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    words.count(result.totalOperations),
                    style: context.text.titleSmall,
                  ),
                ),
                Text(
                  '${l10n.feesLabel} ${context.money(result.totalFees)}',
                  style: context.text.titleSmall?.copyWith(
                    fontFeatures: AppTheme.tabular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.detail, required this.words});

  final FeeOptimizerDetail detail;
  final _Words words;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 46),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(Space.radiusSm),
            ),
            child: Text(
              '${detail.count}×',
              textAlign: TextAlign.center,
              style: context.text.titleSmall?.copyWith(
                color: colors.onPrimaryContainer,
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ),
          Space.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  words.action(context.money(detail.amount)),
                  style: context.text.titleMedium?.copyWith(
                    fontFeatures: AppTheme.tabular,
                  ),
                ),
                Text(
                  words.fee(context.money(detail.fee)),
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          if (detail.count > 1)
            Text(
              context.money(detail.totalCost),
              style: context.text.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontFeatures: AppTheme.tabular,
              ),
            ),
        ],
      ),
    );
  }
}

/// Optimized plan next to the "as much as possible each time" habit.
class _ComparisonCard extends StatefulWidget {
  const _ComparisonCard({required this.outcome, required this.words});

  final OptimizationOutcome outcome;
  final _Words words;

  @override
  State<_ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends State<_ComparisonCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final words = widget.words;
    final comparison = widget.outcome.comparison;
    final optimized = comparison.optimized;
    final classic = comparison.withoutOptimization;

    TableRow row(String label, String a, String b, {bool header = false}) {
      final style = header
          ? context.text.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            )
          : context.text.bodyMedium?.copyWith(fontFeatures: AppTheme.tabular);
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(label, style: header ? style : context.text.bodySmall),
          ),
          Text(
            a,
            textAlign: TextAlign.end,
            style: style?.copyWith(fontWeight: header ? null : FontWeight.w700),
          ),
          Text(b, textAlign: TextAlign.end, style: style),
        ],
      );
    }

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Space.gapLg,
        const Divider(),
        Space.gapLg,
        Text(l10n.classicPlan, style: context.text.titleSmall),
        Space.gapSm,
        for (final d in classic.details)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${d.count}× ${context.money(d.amount)}  ·  '
              '${words.fee(context.money(d.fee))}',
              style: context.text.bodySmall?.copyWith(
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ),
      ],
    );

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.3),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              row('', l10n.optimizedColumn, l10n.classicColumn, header: true),
              row(
                l10n.receivedLabel,
                context.money(optimized.netAmount),
                context.money(classic.netAmount),
              ),
              row(
                l10n.feesLabel,
                context.money(optimized.totalFees),
                context.money(classic.totalFees),
              ),
              row(
                words.countColumn,
                '${optimized.totalOperations}',
                '${classic.totalOperations}',
              ),
            ],
          ),
          Space.gapSm,
          Text(words.classic, style: context.text.bodySmall),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: _showDetails
                ? details
                : const SizedBox(width: double.infinity),
          ),
          Space.gapSm,
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showDetails = !_showDetails),
              icon: AnimatedRotation(
                turns: _showDetails ? 0.5 : 0,
                duration: Motion.medium,
                curve: Motion.curve,
                child: const Icon(Icons.expand_more_rounded),
              ),
              label: Text(_showDetails ? l10n.showLess : l10n.showDetails),
            ),
          ),
        ],
      ),
    );
  }
}
