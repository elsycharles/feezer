import 'package:decimal/decimal.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ConstantUtil {
  // App Information
  static const String appName = 'Feezer';

  // Get localized app title
  static String getAppTitle(BuildContext context) {
    return AppLocalizations.of(context).appTitle;
  }

  /// Parse a number string that may contain comma as decimal separator (French format)
  static double? parseLocalizedNumber(String value) {
    if (value.trim().isEmpty) return null;

    // Replace comma with dot for parsing
    final normalizedValue = value.trim().replaceAll(',', '.');
    return double.tryParse(normalizedValue);
  }

  /// Format a number for display with intelligent rounding
  /// Rounds to appropriate decimal places based on amount size and precision needs
  static String formatCurrencyAmount(double amount, {int? decimals}) {
    final amountDecimal = Decimal.parse(amount.toString());

    // Handle very small amounts (less than 0.01)
    if (amountDecimal.abs() < Decimal.parse('0.01') &&
        amountDecimal != Decimal.zero) {
      // For amounts < 1 centime, display with maximum precision
      final str = amountDecimal.toString();

      // If scientific notation would be clearer
      if (str.length > 10) {
        return amountDecimal.toStringAsExponential(6);
      }

      // Otherwise, display with all significant decimals
      return str;
    } else if (amountDecimal.abs() < Decimal.parse('1')) {
      // For amounts < 1, display 4-6 decimals
      return amountDecimal.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } else {
      // Normal amounts: 2 decimals
      return amountDecimal.toStringAsFixed(decimals ?? 2);
    }
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
}
