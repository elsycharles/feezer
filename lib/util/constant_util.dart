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
  static String formatCurrencyAmount(double amount) {
    // Handle very small amounts (less than 0.01)
    if (amount.abs() < 0.01) {
      return amount.toStringAsFixed(4);
    }

    // Handle small amounts (0.01 to 1)
    if (amount.abs() < 1) {
      return amount.toStringAsFixed(3);
    }

    // Handle medium amounts (1 to 100)
    if (amount.abs() < 100) {
      return amount.toStringAsFixed(2);
    }

    // Handle large amounts (100+)
    if (amount.abs() < 1000) {
      // Check if it's very close to a whole number (within 0.01)
      if ((amount - amount.round()).abs() < 0.01) {
        return amount.round().toString();
      }
      return amount.toStringAsFixed(2);
    }

    // Handle very large amounts (1000+)
    if (amount.abs() < 10000) {
      // Check if it's very close to a whole number (within 0.1)
      if ((amount - amount.round()).abs() < 0.1) {
        return amount.round().toString();
      }
      return amount.toStringAsFixed(1);
    }

    // Handle extremely large amounts (10000+)
    // Check if it's very close to a whole number (within 1)
    if ((amount - amount.round()).abs() < 1) {
      return amount.round().toString();
    }

    // For very large amounts, round to nearest 10, 100, etc. based on size
    if (amount.abs() < 100000) {
      return ((amount / 10).round() * 10).toString();
    }
    if (amount.abs() < 1000000) {
      return ((amount / 100).round() * 100).toString();
    }
    if (amount.abs() < 10000000) {
      return ((amount / 1000).round() * 1000).toString();
    }

    // For extremely large amounts, use scientific notation or round significantly
    return amount.toStringAsExponential(2);
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