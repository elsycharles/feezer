import 'withdrawal_detail_model.dart';

/// Result of withdrawal optimization
class OptimalWithdrawalResult {
  final double totalAmount;
  final double netAmount;
  final double totalFees;
  final double remaining;
  final List<WithdrawalDetail> withdrawals;
  final double efficiency;

  const OptimalWithdrawalResult({
    required this.totalAmount,
    required this.netAmount,
    required this.totalFees,
    required this.remaining,
    required this.withdrawals,
    required this.efficiency,
  });

  /// Total number of withdrawals
  int get totalWithdrawals =>
      withdrawals.fold(0, (sum, withdrawal) => sum + withdrawal.count);

  /// Check if the result is valid (no errors)
  bool get isValid => netAmount > 0 && totalWithdrawals > 0;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('OptimalWithdrawalResult:');
    buffer.writeln('  Total amount: ${totalAmount.toStringAsFixed(2)}');
    buffer.writeln('  Net amount: ${netAmount.toStringAsFixed(2)}');
    buffer.writeln('  Total fees: ${totalFees.toStringAsFixed(2)}');
    buffer.writeln('  Remaining: ${remaining.toStringAsFixed(2)}');
    buffer.writeln('  Efficiency: ${(efficiency * 100).toStringAsFixed(2)}%');
    buffer.writeln('  Number of withdrawals: $totalWithdrawals');
    buffer.writeln('  Withdrawal details:');
    for (final withdrawal in withdrawals) {
      buffer.writeln('    - ${withdrawal.count}x ${withdrawal.amount} (fee: ${withdrawal.fee})');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimalWithdrawalResult &&
          runtimeType == other.runtimeType &&
          totalAmount == other.totalAmount &&
          netAmount == other.netAmount &&
          totalFees == other.totalFees &&
          remaining == other.remaining &&
          efficiency == other.efficiency;

  @override
  int get hashCode =>
      totalAmount.hashCode ^
      netAmount.hashCode ^
      totalFees.hashCode ^
      remaining.hashCode ^
      efficiency.hashCode;
}