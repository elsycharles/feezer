/// Normalized withdrawal option model
class WithdrawalOption {
  final double min;
  final double max;
  final double fee;

  const WithdrawalOption({
    required this.min,
    required this.max,
    required this.fee,
  });

  /// Calculate the option's efficiency (max/fee ratio)
  double get efficiency => max / fee;

  @override
  String toString() {
    return 'WithdrawalOption(min: $min, max: $max, fee: $fee, efficiency: ${efficiency.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalOption &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max &&
          fee == other.fee;

  @override
  int get hashCode => min.hashCode ^ max.hashCode ^ fee.hashCode;
}