import 'package:decimal/decimal.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Utility class for application constants and number formatting with arbitrary precision
class ConstantUtil {
  // App Information
  static const String appName = 'Feezer';

  /// Get localized app title
  static String getAppTitle(BuildContext context) {
    return AppLocalizations.of(context).appTitle;
  }

  /// Parse a number string that may contain comma as decimal separator (French format)
  /// Returns null if parsing fails
  static Decimal? parseLocalizedNumber(String value) {
    if (value.trim().isEmpty) return null;

    try {
      // Replace comma with dot for parsing
      final normalizedValue = value.trim().replaceAll(',', '.');
      return Decimal.parse(normalizedValue);
    } catch (e) {
      return null;
    }
  }

  /// Format a Decimal number for display with intelligent precision
  /// Handles arbitrary precision including extremely small values like 0.0000000001
  ///
  /// Rules:
  /// - Scientific notation for values < 1e-6 or very long representations
  /// - Up to 10 significant decimals for small amounts (< 1)
  /// - 2-4 decimals for normal amounts (≥ 1)
  /// - Removes trailing zeros
  /// - Adds spaces as thousand separators for amounts ≥ 1000
  static String formatCurrencyAmount(dynamic amount, {int? decimals}) {
    // Convert to Decimal for precise calculations
    final Decimal amountDecimal;
    if (amount is Decimal) {
      amountDecimal = amount;
    } else if (amount is num) {
      amountDecimal = Decimal.parse(amount.toString());
    } else if (amount is String) {
      amountDecimal = Decimal.parse(amount);
    } else {
      return '0';
    }

    // Handle zero
    if (amountDecimal == Decimal.zero) {
      return decimals != null ? '0.${'0' * decimals}' : '0';
    }

    final absValue = amountDecimal.abs();

    // For extremely small values (< 0.000001), use scientific notation
    if (absValue < Decimal.parse('0.000001')) {
      return _formatScientific(amountDecimal);
    }

    // For values < 1, show up to 10 significant decimals
    if (absValue < Decimal.fromInt(1)) {
      return _formatSmallAmount(amountDecimal, decimals);
    }

    // For normal amounts (≥ 1), use 2-4 decimals and add thousand separators
    return _addThousandSeparators(_formatNormalAmount(amountDecimal, decimals));
  }

  /// Format extremely small numbers in scientific notation
  static String _formatScientific(Decimal value) {
    // Convert to double for scientific notation (acceptable for display only)
    final double doubleValue = value.toDouble();

    // Determine number of significant figures based on magnitude
    int precision = 6;
    if (doubleValue.abs() < 1e-10) precision = 8;
    if (doubleValue.abs() < 1e-15) precision = 10;

    return doubleValue.toStringAsExponential(precision);
  }

  /// Format small amounts (< 1) with appropriate decimal places
  static String _formatSmallAmount(Decimal value, int? decimals) {
    if (decimals != null) {
      return _removeTrailingZeros(
        value.toStringAsFixed(decimals)
      );
    }

    // Auto-detect required precision (up to 10 decimals)
    String result = value.toStringAsFixed(10);
    return _removeTrailingZeros(result);
  }

  /// Format normal amounts (≥ 1) with 2-4 decimals
  static String _formatNormalAmount(Decimal value, int? decimals) {
    final int defaultDecimals = decimals ?? 2;

    // Check if we need more precision
    final rounded = value.toStringAsFixed(defaultDecimals);
    final parsed = Decimal.parse(rounded);

    // If rounding caused significant loss, use more decimals
    final difference = (value - parsed).abs();
    final threshold = Decimal.parse('0.01');

    if (difference > threshold && decimals == null) {
      // Try with 4 decimals
      return _removeTrailingZeros(value.toStringAsFixed(4));
    }

    return _removeTrailingZeros(rounded);
  }

  /// Remove trailing zeros and decimal point if unnecessary
  static String _removeTrailingZeros(String value) {
    if (!value.contains('.')) return value;

    // Remove trailing zeros
    String result = value.replaceAll(RegExp(r'0+$'), '');

    // Remove decimal point if no decimals remain
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }

    return result;
  }

  /// Add spaces as thousand separators to a formatted number string
  static String _addThousandSeparators(String value) {
    if (!value.contains('.')) {
      // No decimal part, format integer part only
      return _formatIntegerPart(value);
    }

    // Split into integer and decimal parts
    final parts = value.split('.');
    final integerPart = _formatIntegerPart(parts[0]);
    final decimalPart = parts.length > 1 ? parts[1] : '';

    return decimalPart.isNotEmpty ? '$integerPart.$decimalPart' : integerPart;
  }

  /// Format the integer part of a number with spaces as thousand separators
  static String _formatIntegerPart(String integerPart) {
    if (integerPart.length <= 3) {
      return integerPart;
    }

    String result = '';
    int count = 0;

    // Process from right to left
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = ' $result';
      }
      result = integerPart[i] + result;
      count++;
    }

    return result;
  }

  /// Parse and format a localized number string
  /// Combines parseLocalizedNumber and formatCurrencyAmount
  static String? formatLocalizedNumber(String value, {int? decimals}) {
    final parsed = parseLocalizedNumber(value);
    if (parsed == null) return null;
    return formatCurrencyAmount(parsed, decimals: decimals);
  }

  // Database configuration
  static const String databaseName = 'fee_optimizer.db';
  static const int databaseVersion = 3;

  // Tables
  static const String tableFeeIntervals = 'fee_intervals';
  static const String tableProviders = 'providers';
  static const String tableCurrencies = 'currencies';
  static const String tableOptimizationResults = 'optimization_results';
  static const String tableOptimizationDetails = 'optimization_details';

  // Common columns
  static const String columnId = 'id';
  static const String columnCreationDatetime = 'creation_datetime';

  // FeeInterval columns
  static const String columnMinAmount = 'min_amount';
  static const String columnMaxAmount = 'max_amount';
  static const String columnFee = 'fee';
  static const String columnFeeType = 'fee_type';
  static const String columnProviderId = 'provider_id';

  // Provider columns
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnIconName = 'icon_name';

  // Currency columns
  static const String columnCode = 'code';
  static const String columnSymbol = 'symbol';
  static const String columnRate = 'rate';

  // Optimization columns
  static const String columnTotalAmount = 'total_amount';
  static const String columnNetAmount = 'net_amount';
  static const String columnTotalFees = 'total_fees';
  static const String columnRemaining = 'remaining';
  static const String columnEfficiency = 'efficiency';
  static const String columnResultId = 'result_id';
  static const String columnAmount = 'amount';
  static const String columnCount = 'count';

  // Algorithm constants
  static const double threshold = 500000.0;
  static const double defaultPrecision = 1.0;

  /// Precision constants for Decimal calculations
  static const int maxDecimalScale = 18; // Maximum scale for Decimal operations
  static const int displayDecimalScale = 10; // Maximum decimals for display

  /// Calculate dynamic tolerance based on amount magnitude
  /// For amounts near zero, use very small tolerance
  /// For large amounts, use proportional tolerance
  static Decimal calculateTolerance(Decimal amount) {
    final absAmount = amount.abs();

    if (absAmount == Decimal.zero) {
      return Decimal.parse('1e-18');
    }

    // Use relative tolerance: 0.01% of amount or 1e-10, whichever is larger
    final relativeTolerance = absAmount * Decimal.parse('0.0001');
    final minTolerance = Decimal.parse('1e-10');

    return relativeTolerance > minTolerance ? relativeTolerance : minTolerance;
  }

  /// Compare two Decimal values with appropriate tolerance
  static bool areDecimalsEqual(Decimal a, Decimal b, {Decimal? tolerance}) {
    final tol = tolerance ?? calculateTolerance(a);
    return (a - b).abs() <= tol;
  }

  /// Check if Decimal a is greater than b with tolerance
  static bool isDecimalGreater(Decimal a, Decimal b, {Decimal? tolerance}) {
    final tol = tolerance ?? calculateTolerance(b);
    return a > b + tol;
  }

  /// Check if Decimal a is less than b with tolerance
  static bool isDecimalLess(Decimal a, Decimal b, {Decimal? tolerance}) {
    final tol = tolerance ?? calculateTolerance(b);
    return a < b - tol;
  }
}
