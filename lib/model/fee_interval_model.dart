import '../util/constant_util.dart';

/// Type of fee calculation
enum FeeType { fixed, percentage }

/// Comprehensive FeeInterval model with validation and serialization
class FeeInterval {
  FeeInterval({
    this.id,
    this.minAmount,
    this.maxAmount,
    this.fee,
    this.feeType = FeeType.fixed,
    DateTime? creationDateTime,
  }) : creationDatetime = creationDateTime ?? DateTime.now();

  final String? id;
  final double? minAmount;
  final double? maxAmount;
  final double? fee;
  final FeeType feeType;
  final DateTime creationDatetime;

  /// Creates a copy with updated values
  FeeInterval copyWith({
    String? id,
    double? minAmount,
    double? maxAmount,
    double? fee,
    FeeType? feeType,
    DateTime? creationDateTime,
  }) => FeeInterval(
    id: id ?? this.id,
    minAmount: minAmount ?? this.minAmount,
    maxAmount: maxAmount ?? this.maxAmount,
    fee: fee ?? this.fee,
    feeType: feeType ?? this.feeType,
    creationDateTime: creationDateTime ?? creationDatetime,
  );

  /// Validates the fee interval
  bool get isValid {
    if ((minAmount ?? 0) < 0 || (maxAmount ?? 0) <= (minAmount ?? 0)) {
      return false;
    }

    final feeValue = fee ?? 0;
    if (feeType == FeeType.percentage) {
      return feeValue >= 0 && feeValue <= 100;
    } else {
      return feeValue >= 0;
    }
  }

  /// Gets formatted amount range with currency symbol and exchange rate conversion
  String formattedRangeWithSymbol(
    String currencySymbol, [
    double exchangeRate = 1.0,
  ]) {
    final min = (minAmount ?? 0) / exchangeRate;
    final max = (maxAmount ?? 0) / exchangeRate;
    return '${ConstantUtil.formatCurrencyAmount(min)} - ${ConstantUtil.formatCurrencyAmount(max)} $currencySymbol';
  }

  /// Gets formatted fee with currency symbol and exchange rate conversion
  String formattedFeeWithSymbol(
    String currencySymbol, [
    double exchangeRate = 1.0,
  ]) {
    final feeValue = fee ?? 0;
    if (feeType == FeeType.percentage) {
      return '${feeValue.toStringAsFixed(2)}%';
    } else {
      return '${ConstantUtil.formatCurrencyAmount(feeValue / exchangeRate)} $currencySymbol';
    }
  }

  static FeeInterval fromMap(Map<String, dynamic> map) {
    return FeeInterval(
      id: map['id'].toString(),
      minAmount: map['min_amount']?.toDouble(),
      maxAmount: map['max_amount']?.toDouble(),
      fee: map['fee']?.toDouble(),
      feeType: map['fee_type'] != null
          ? FeeType.values[map['fee_type'] as int]
          : FeeType.fixed, // Default to fixed for backward compatibility
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
      'fee_type': interval.feeType.index,
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
      'FeeInterval(id: $id, range: ${formattedRangeWithSymbol('Ar')}, fee: ${formattedFeeWithSymbol('Ar')}, type: $feeType)';
}
