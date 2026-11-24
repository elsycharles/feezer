import '../../model/fee_interval_model.dart';

/// Normalized, immutable view of a [FeeInterval] used by the optimizer.
///
/// A transaction sending `amount` (in `[minAmount, maxAmount]`) costs
/// `amount + fee(amount)`, where the fee is either fixed or a percentage of
/// the amount sent.
class FeeTier {
  const FeeTier({
    required this.minAmount,
    required this.maxAmount,
    required this.type,
    required this.value,
  });

  /// Smallest amount considered for a transaction when a tier starts at 0
  /// (a transaction of 0 is meaningless).
  static const double smallestAmount = 1;

  final double minAmount;
  final double maxAmount;
  final FeeType type;

  /// Fixed fee, or percentage (0-100) depending on [type].
  final double value;

  bool get isPercentage => type == FeeType.percentage;

  /// Fixed part of the fee.
  double get fixedFee => isPercentage ? 0 : value;

  /// Proportional part of the fee (0.02 for 2%).
  double get rate => isPercentage ? value / 100 : 0;

  double feeFor(double amount) => fixedFee + amount * rate;

  double costFor(double amount) => amount + feeFor(amount);

  /// Net amount obtained when spending exactly [cost] in this tier.
  double netForCost(double cost) => (cost - fixedFee) / (1 + rate);

  /// Cheapest transaction of this tier.
  double get minCost => costFor(minAmount);

  /// Most expensive transaction of this tier.
  double get maxCost => costFor(maxAmount);

  /// Best ratio net / cost reachable in this tier (at the maximum amount).
  double get efficiency => maxAmount / maxCost;

  bool contains(double amount, [double tolerance = 0]) =>
      amount >= minAmount - tolerance && amount <= maxAmount + tolerance;

  /// Converts user intervals into sorted, deduplicated tiers, ignoring
  /// incomplete or invalid intervals.
  static List<FeeTier> fromIntervals(Iterable<FeeInterval> intervals) {
    final tiers = <FeeTier>[];
    for (final interval in intervals) {
      final min = interval.minAmount;
      final max = interval.maxAmount;
      final fee = interval.fee;
      if (min == null || max == null || fee == null || !interval.isValid) {
        continue;
      }
      if (!min.isFinite || !max.isFinite || !fee.isFinite) continue;
      final effectiveMin = min > 0
          ? min
          : (max < smallestAmount ? max : smallestAmount);
      final tier = FeeTier(
        minAmount: effectiveMin,
        maxAmount: max,
        type: interval.feeType,
        value: fee,
      );
      if (!tiers.contains(tier)) tiers.add(tier);
    }
    tiers.sort((a, b) {
      final byMin = a.minAmount.compareTo(b.minAmount);
      return byMin != 0 ? byMin : a.maxAmount.compareTo(b.maxAmount);
    });
    return tiers;
  }

  @override
  bool operator ==(Object other) =>
      other is FeeTier &&
      other.minAmount == minAmount &&
      other.maxAmount == maxAmount &&
      other.type == type &&
      other.value == value;

  @override
  int get hashCode => Object.hash(minAmount, maxAmount, type, value);

  @override
  String toString() =>
      'FeeTier([$minAmount, $maxAmount], ${isPercentage ? '$value%' : value})';
}
