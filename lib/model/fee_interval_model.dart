/// Comprehensive FeeInterval model with validation and serialization
class FeeInterval {
  FeeInterval({
    this.id,
    this.minAmount,
    this.maxAmount,
    this.fee,
    DateTime? creationDateTime,
  }) : creationDatetime = creationDateTime ?? DateTime.now();

  final String? id;
  final double? minAmount;
  final double? maxAmount;
  final double? fee;
  final DateTime creationDatetime;

  /// Creates a copy with updated values
  FeeInterval copyWith({
    String? id,
    double? minAmount,
    double? maxAmount,
    double? fee,
    DateTime? creationDateTime,
  }) => FeeInterval(
    id: id ?? this.id,
    minAmount: minAmount ?? this.minAmount,
    maxAmount: maxAmount ?? this.maxAmount,
    fee: fee ?? this.fee,
    creationDateTime: creationDateTime ?? creationDatetime,
  );

  /// Validates the fee interval
  bool get isValid =>
      (minAmount ?? 0) >= 0 &&
      (maxAmount ?? 0) > (minAmount ?? 0) &&
      (fee ?? 0) >= 0;

  /// Gets formatted amount range
  String get formattedRange {
    final min = (minAmount ?? 0).toInt();
    final max = (maxAmount ?? 0).toInt();
    return '$min - $max Ar';
  }

  /// Gets formatted fee
  String get formattedFee => '${(fee ?? 0).toInt()} Ar';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeInterval &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FeeInterval(id: $id, range: $formattedRange, fee: $formattedFee)';
}
