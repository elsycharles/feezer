/// Data class for fee optimization results
class OptimizationResult {
  const OptimizationResult({
    required this.interval,
    required this.fee,
    required this.count,
    required this.total,
  });

  final String interval;
  final String fee;
  final int count;
  final String total;

  /// Creates a copy with updated values
  OptimizationResult copyWith({
    String? interval,
    String? fee,
    int? count,
    String? total,
  }) => OptimizationResult(
    interval: interval ?? this.interval,
    fee: fee ?? this.fee,
    count: count ?? this.count,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimizationResult &&
          runtimeType == other.runtimeType &&
          interval == other.interval &&
          fee == other.fee &&
          count == other.count &&
          total == other.total;

  @override
  int get hashCode => Object.hash(interval, fee, count, total);

  @override
  String toString() => 'OptimizationResult(interval: $interval, fee: $fee, count: $count, total: $total)';
}