/// Detail model for individual fee optimization operations
class FeeOptimizerDetail {
  const FeeOptimizerDetail({
    required this.amount,
    required this.fee,
    required this.count,
  });

  final double amount;
  final double fee;
  final int count;

  /// Gets the total cost for this operation type
  double get totalCost => (amount + fee) * count;

  /// Gets the total net amount for this operation type
  double get totalNet => amount * count;

  /// Gets the total fees for this operation type
  double get totalFees => fee * count;

  /// Creates a copy with updated values
  FeeOptimizerDetail copyWith({
    double? amount,
    double? fee,
    int? count,
  }) => FeeOptimizerDetail(
    amount: amount ?? this.amount,
    fee: fee ?? this.fee,
    count: count ?? this.count,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeOptimizerDetail &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          fee == other.fee &&
          count == other.count;

  @override
  int get hashCode => Object.hash(amount, fee, count);

  @override
  String toString() =>
      'FeeOptimizerDetail(amount: $amount, fee: $fee, count: $count)';
}