import '../data/app_database.dart';
import '../util/constant_util.dart';
import '../util/money.dart';

/// Type of fee calculation.
enum FeeType { fixed, percentage }

/// Fee applied to transactions whose amount is in `[minAmount, maxAmount]`.
///
/// A percentage fee is stored as a number between 0 and 100.
class FeeInterval {
  FeeInterval({
    this.id,
    this.minAmount,
    this.maxAmount,
    this.fee,
    this.feeType = FeeType.fixed,
    DateTime? creationDateTime,
  }) : creationDatetime = creationDateTime ?? DateTime.now();

  /// Database id, `null` before insertion.
  final String? id;
  final double? minAmount;
  final double? maxAmount;
  final double? fee;
  final FeeType feeType;
  final DateTime creationDatetime;

  bool get isPercentage => feeType == FeeType.percentage;

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

  /// Complete and coherent interval.
  bool get isValid {
    final min = minAmount;
    final max = maxAmount;
    final value = fee;
    if (min == null || max == null || value == null) return false;
    if (min < 0 || max <= min || value < 0) return false;
    return !isPercentage || value <= 100;
  }

  /// Whether this interval shares at least one amount with [other]
  /// (bounds are inclusive: 0-1000 and 1000-2000 overlap on 1000).
  bool overlaps(FeeInterval other) {
    if (!isValid || !other.isValid) return false;
    return minAmount! <= other.maxAmount! && other.minAmount! <= maxAmount!;
  }

  /// Fee of one transaction of [amount].
  double feeFor(double amount) =>
      isPercentage ? amount * (fee ?? 0) / 100 : (fee ?? 0);

  /// `min – max` formatted as money (used in messages).
  String get formattedRange =>
      '${Money.format(minAmount ?? 0)} – ${Money.format(maxAmount ?? 0)}';

  static FeeInterval fromMap(Map<String, dynamic> map) {
    final typeIndex = (map[Db.feeType] as num?)?.toInt() ?? 0;
    return FeeInterval(
      id: map[Db.id]?.toString(),
      minAmount: (map[Db.minAmount] as num?)?.toDouble(),
      maxAmount: (map[Db.maxAmount] as num?)?.toDouble(),
      fee: (map[Db.fee] as num?)?.toDouble(),
      feeType: typeIndex >= 0 && typeIndex < FeeType.values.length
          ? FeeType.values[typeIndex]
          : FeeType.fixed,
      creationDateTime: ConstantUtil.parseDateTime(map[Db.creationDatetime]),
    );
  }

  /// Database row. The id is omitted when unknown so SQLite assigns one.
  static Map<String, dynamic> toMap(FeeInterval interval, String providerId) {
    final id = interval.id == null ? null : int.tryParse(interval.id!);
    return {
      if (id != null) Db.id: id,
      Db.providerId: int.tryParse(providerId),
      Db.minAmount: interval.minAmount,
      Db.maxAmount: interval.maxAmount,
      Db.fee: interval.fee,
      Db.feeType: interval.feeType.index,
      Db.creationDatetime: interval.creationDatetime.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeInterval &&
          (id != null
              ? id == other.id
              : other.id == null &&
                    minAmount == other.minAmount &&
                    maxAmount == other.maxAmount &&
                    fee == other.fee &&
                    feeType == other.feeType);

  @override
  int get hashCode => id != null
      ? id.hashCode
      : Object.hash(minAmount, maxAmount, fee, feeType);

  @override
  String toString() =>
      'FeeInterval(id: $id, [$minAmount, $maxAmount], fee: $fee, $feeType)';
}
