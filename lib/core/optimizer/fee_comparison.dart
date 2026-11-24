import '../../model/fee_interval_model.dart';
import '../../model/fee_minimizer_detail_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import 'fee_tier.dart';
import 'naive_strategy.dart';

/// Comparison between an optimized plan and what a user would do by hand.
class FeeComparison {
  const FeeComparison({
    required this.optimized,
    required this.withoutOptimization,
    required this.sameNetWithoutOptimization,
  });

  /// Computes the baselines for [optimized], with the same amount [step].
  factory FeeComparison.compute(
    FeeOptimizerResult optimized,
    Iterable<FeeInterval> intervals, {
    double step = 0,
  }) {
    final tiers = FeeTier.fromIntervals(intervals, step: step);
    final naive = _toResult(
      optimized.budget,
      tiers,
      NaiveStrategy.maxNetPlan(optimized.budget, tiers, step: step),
    );
    final sameNetPlan = NaiveStrategy.sameNetPlan(optimized.netAmount, tiers);
    return FeeComparison(
      optimized: optimized,
      withoutOptimization: naive,
      sameNetWithoutOptimization: sameNetPlan == null
          ? null
          : _toResult(optimized.budget, tiers, sameNetPlan),
    );
  }

  final FeeOptimizerResult optimized;

  /// Same budget, always sending the largest possible transaction.
  final FeeOptimizerResult withoutOptimization;

  /// Cost of sending the optimized net amount by hand, or `null` when that
  /// amount cannot be split into valid transactions this way.
  final FeeOptimizerResult? sameNetWithoutOptimization;

  /// Extra net amount received thanks to the optimization (>= 0).
  double get extraNetAmount =>
      optimized.netAmount - withoutOptimization.netAmount;

  /// Fees saved for the same net amount (>= 0), or `null` when unknown.
  double? get feesSavedForSameNet => sameNetWithoutOptimization == null
      ? null
      : sameNetWithoutOptimization!.totalFees - optimized.totalFees;

  /// Whether sending the optimized net amount by hand would exceed the budget.
  bool get sameNetExceedsBudget {
    final sameNet = sameNetWithoutOptimization;
    if (sameNet == null) return false;
    return sameNet.totalSpent >
        optimized.budget + 1e-9 * (optimized.budget + 1);
  }

  static FeeOptimizerResult _toResult(
    double budget,
    List<FeeTier> tiers,
    List<NaiveStep> steps,
  ) {
    final details = <FeeOptimizerDetail>[];
    for (final step in steps) {
      final fee = tiers[step.tierIndex].feeFor(step.amount);
      final index = details.indexWhere(
        (d) => d.amount == step.amount && d.fee == fee,
      );
      if (index >= 0) {
        details[index] = details[index].copyWith(
          count: details[index].count + step.count,
        );
      } else {
        details.add(
          FeeOptimizerDetail(amount: step.amount, fee: fee, count: step.count),
        );
      }
    }
    return FeeOptimizerResult.fromDetails(budget: budget, details: details);
  }
}
