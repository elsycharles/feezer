/// Detail of a withdrawal in the optimal solution
class WithdrawalDetail {
  final double amount;
  final double fee;
  final double netAmount;
  final int count;

  const WithdrawalDetail({
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.count,
  });

  /// Total gross amount (amount * count)
  double get totalGross => amount * count;

  /// Total fees (fee * count)
  double get totalFees => fee * count;

  /// Total net amount (netAmount * count)
  double get totalNet => netAmount * count;

  @override
  String toString() {
    return 'WithdrawalDetail(amount: $amount, fee: $fee, count: $count, totalNet: ${totalNet.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalDetail &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          fee == other.fee &&
          netAmount == other.netAmount &&
          count == other.count;

  @override
  int get hashCode =>
      amount.hashCode ^ fee.hashCode ^ netAmount.hashCode ^ count.hashCode;
}