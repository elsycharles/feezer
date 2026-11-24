/// A group of identical transactions in an optimization plan.
class FeeOptimizerDetail {
  const FeeOptimizerDetail({
    required this.amount,
    required this.fee,
    required this.count,
  });

  /// Amount received by the recipient for one transaction.
  final double amount;

  /// Fee paid for one transaction.
  final double fee;

  /// Number of identical transactions.
  final int count;

  /// Money spent for the whole group (amount + fee) * count.
  double get totalCost => (amount + fee) * count;

  /// Net amount of the whole group.
  double get totalNet => amount * count;

  /// Fees of the whole group.
  double get totalFees => fee * count;

  FeeOptimizerDetail copyWith({double? amount, double? fee, int? count}) =>
      FeeOptimizerDetail(
        amount: amount ?? this.amount,
        fee: fee ?? this.fee,
        count: count ?? this.count,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeOptimizerDetail &&
          amount == other.amount &&
          fee == other.fee &&
          count == other.count;

  @override
  int get hashCode => Object.hash(amount, fee, count);

  @override
  String toString() =>
      'FeeOptimizerDetail(amount: $amount, fee: $fee, count: $count)';
}
