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

  static FeeInterval fromMap(Map<String, dynamic> map) {
    return FeeInterval(
      id: map['id'].toString(),
      minAmount: map['min_amount']?.toDouble(),
      maxAmount: map['max_amount']?.toDouble(),
      fee: map['fee']?.toDouble(),
      creationDateTime: DateTime.fromMillisecondsSinceEpoch(
        map['creation_datetime'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static Map<String, dynamic> toMap(FeeInterval interval, String providerId) {
    return {
      'id': interval.id != null ? int.tryParse(interval.id!) : null,
      'provider_id': int.tryParse(providerId),
      'min_amount': interval.minAmount,
      'max_amount': interval.maxAmount,
      'fee': interval.fee,
      'creation_datetime': interval.creationDatetime.millisecondsSinceEpoch,
    };
  }

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
