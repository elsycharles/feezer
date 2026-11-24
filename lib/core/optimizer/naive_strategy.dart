import 'fee_tier.dart';

/// One step of a naive plan: [count] transactions of [amount] in tier
/// number [tierIndex].
class NaiveStep {
  const NaiveStep(this.tierIndex, this.amount, this.count);

  final int tierIndex;
  final double amount;
  final int count;
}

/// "Without optimization" strategies: what a user typically does by hand,
/// i.e. always sending the biggest transaction possible.
///
/// They are used as a baseline for the comparison screen and as a starting
/// point for the exact optimizer.
class NaiveStrategy {
  const NaiveStrategy._();

  static const int _maxSteps = 10000;

  /// Repeatedly sends the largest affordable amount until the remaining
  /// budget cannot pay for any transaction. With a positive [step], amounts
  /// are multiples of [step] ([tiers] must then be built with the same step).
  static List<NaiveStep> maxNetPlan(
    double budget,
    List<FeeTier> tiers, {
    double step = 0,
  }) {
    final steps = <NaiveStep>[];
    if (tiers.isEmpty || !(budget > 0)) return steps;
    final eps = _eps(budget);
    final topIndex = _largestTier(tiers);
    final top = tiers[topIndex];

    var remaining = budget;
    for (var i = 0; i < _maxSteps; i++) {
      var bestIndex = -1;
      var bestAmount = 0.0;
      for (var t = 0; t < tiers.length; t++) {
        final tier = tiers[t];
        var amount = tier.netForCost(remaining);
        if (amount > tier.maxAmount) amount = tier.maxAmount;
        amount = FeeTier.floorToStep(amount, step);
        if (amount < tier.minAmount - eps) continue;
        if (amount < tier.minAmount) amount = tier.minAmount;
        if (amount > bestAmount + eps ||
            (bestIndex >= 0 &&
                (amount - bestAmount).abs() <= eps &&
                tier.feeFor(amount) < tiers[bestIndex].feeFor(bestAmount))) {
          bestIndex = t;
          bestAmount = amount;
        }
      }
      if (bestIndex < 0) break;

      var count = 1;
      if (bestIndex == topIndex && bestAmount >= top.maxAmount) {
        count = (remaining / top.maxCost + eps / top.maxCost).floor();
        if (count < 1) count = 1;
      }
      steps.add(NaiveStep(bestIndex, bestAmount, count));
      remaining -= tiers[bestIndex].costFor(bestAmount) * count;
      if (remaining <= eps) break;
    }
    return steps;
  }

  /// Sends exactly [net] by always using the largest possible transaction.
  /// Returns `null` when [net] cannot be split into valid transactions.
  static List<NaiveStep>? sameNetPlan(double net, List<FeeTier> tiers) {
    if (tiers.isEmpty || !(net > 0)) return null;
    final steps = <NaiveStep>[];
    final eps = _eps(net);
    final topIndex = _largestTier(tiers);
    final top = tiers[topIndex];

    var remaining = net;
    for (var i = 0; i < _maxSteps && remaining > eps; i++) {
      var bestIndex = -1;
      var bestAmount = 0.0;
      for (var t = 0; t < tiers.length; t++) {
        final tier = tiers[t];
        if (remaining < tier.minAmount - eps) continue;
        final amount = remaining < tier.maxAmount ? remaining : tier.maxAmount;
        if (amount > bestAmount + eps ||
            (bestIndex >= 0 &&
                (amount - bestAmount).abs() <= eps &&
                tier.feeFor(amount) < tiers[bestIndex].feeFor(bestAmount))) {
          bestIndex = t;
          bestAmount = amount;
        }
      }
      if (bestIndex < 0) return null;

      var count = 1;
      if (bestIndex == topIndex && bestAmount >= top.maxAmount) {
        count = (remaining / top.maxAmount + eps / top.maxAmount).floor();
        if (count < 1) count = 1;
      }
      steps.add(NaiveStep(bestIndex, bestAmount, count));
      remaining -= bestAmount * count;
    }
    return remaining <= eps ? steps : null;
  }

  /// Tier allowing the biggest single transaction (cheapest on ties).
  static int _largestTier(List<FeeTier> tiers) {
    var index = 0;
    for (var t = 1; t < tiers.length; t++) {
      final tier = tiers[t];
      final best = tiers[index];
      if (tier.maxAmount > best.maxAmount ||
          (tier.maxAmount == best.maxAmount && tier.maxCost < best.maxCost)) {
        index = t;
      }
    }
    return index;
  }

  static double _eps(double scale) => 1e-9 * (scale.abs() + 1);
}
