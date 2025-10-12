import 'fee_minimizer_detail_model.dart';

/// Result model for fee optimization calculations
class FeeOptimizerResult {
  const FeeOptimizerResult({
    required this.totalAmount,
    required this.netAmount,
    required this.totalFees,
    required this.remaining,
    required this.details,
  });

  final double totalAmount;
  final double netAmount;
  final double totalFees;
  final double remaining;
  final List<FeeOptimizerDetail> details;

  /// Gets the total number of operations
  int get totalOperations => details
      .map((detail) => detail.count)
      .fold(0, (sum, count) => sum + count);

  /// Gets the efficiency percentage
  double get efficiency =>
      totalAmount > 0 ? (netAmount / totalAmount) * 100 : 0;

  /// Creates a copy with updated values
  FeeOptimizerResult copyWith({
    double? totalAmount,
    double? netAmount,
    double? totalFees,
    double? remaining,
    List<FeeOptimizerDetail>? details,
  }) => FeeOptimizerResult(
    totalAmount: totalAmount ?? this.totalAmount,
    netAmount: netAmount ?? this.netAmount,
    totalFees: totalFees ?? this.totalFees,
    remaining: remaining ?? this.remaining,
    details: details ?? this.details,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeOptimizerResult &&
          runtimeType == other.runtimeType &&
          totalAmount == other.totalAmount &&
          netAmount == other.netAmount &&
          totalFees == other.totalFees &&
          remaining == other.remaining &&
          details == other.details;

  @override
  int get hashCode =>
      Object.hash(totalAmount, netAmount, totalFees, remaining, details);

  @override
  String toString() =>
      'FeeOptimizerResult(totalAmount: $totalAmount, netAmount: $netAmount, totalFees: $totalFees, remaining: $remaining, operations: $totalOperations)';
}
