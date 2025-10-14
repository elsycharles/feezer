import 'package:decimal/decimal.dart';
import 'constant_util.dart';

/// Utility class for high-precision decimal operations
/// Provides safe conversions and calculations with unlimited precision
class DecimalUtil {
  /// Convert double to Decimal with maximum precision
  static Decimal toDecimal(double value) {
    return Decimal.parse(value.toString());
  }

  /// Convert Decimal to double (may lose precision, use only for final display)
  static double toDouble(Decimal value) {
    return value.toDouble();
  }

  /// Calculate fee with full precision
  static Decimal calculateFee({
    required Decimal amount,
    required Decimal feeValue,
    required bool isPercentage,
  }) {
    if (isPercentage) {
      final hundred = Decimal.fromInt(100);
      final result = (amount * feeValue) / hundred;
      return result.toDecimal(scaleOnInfinitePrecision: ConstantUtil.maxDecimalScale);
    } else {
      return feeValue;
    }
  }

  /// Calculate net amount from budget with full precision
  static Decimal calculateNetAmount({
    required Decimal budget,
    required Decimal feeValue,
    required bool isPercentage,
  }) {
    if (isPercentage) {
      final hundred = Decimal.fromInt(100);
      final one = Decimal.fromInt(1);
      final feeRatio = (feeValue / hundred).toDecimal(scaleOnInfinitePrecision: ConstantUtil.maxDecimalScale);
      final denominator = one + feeRatio;
      final result = budget / denominator;
      return result.toDecimal(scaleOnInfinitePrecision: ConstantUtil.maxDecimalScale);
    } else {
      return budget - feeValue;
    }
  }

  /// Calculate total cost with full precision
  static Decimal calculateTotalCost({
    required Decimal amount,
    required Decimal fee,
  }) {
    return amount + fee;
  }

  /// Safe comparison: check if a <= b with tolerance
  static bool isLessOrEqual(Decimal a, Decimal b, {Decimal? tolerance}) {
    final tol = tolerance ?? ConstantUtil.calculateTolerance(b);
    return a <= b + tol;
  }
}