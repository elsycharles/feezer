/// Model to represent a withdrawal option with its constraints
class Withdrawal {
  final double? min;
  final double? max;
  final double? fee;

  const Withdrawal({
    this.min,
    this.max,
    this.fee,
  });

  @override
  String toString() {
    return 'Withdrawal(min: $min, max: $max, fee: $fee)';
  }
}