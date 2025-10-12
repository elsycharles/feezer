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

  /// Format a number for display with proper decimal places
  static String formatCurrencyAmount(double amount) {
    // For currency amounts, always show 2 decimal places for precision
    // This ensures proper display of converted amounts (e.g., 4.81 instead of 4.8)
    if (amount < 1) {
      return amount.toStringAsFixed(2);
    }
    // For amounts between 1 and 100, show 2 decimal places for currency precision
    else if (amount < 100) {
      return amount.toStringAsFixed(2);
    }
    // For larger amounts, show as integer (but keep decimal precision internally)
    else {
      // Check if it's a whole number
      if (amount == amount.toInt()) {
        return amount.toInt().toString();
      } else {
        return amount.toStringAsFixed(2);
      }
    }
  }
  // Configuration base de données
  static const String databaseName = 'fee_optimizer.db';
  static const int databaseVersion = 3;

  // Tables
  static const String tableFeeIntervals = 'fee_intervals';
  static const String tableProviders = 'providers';
  static const String tableCurrencies = 'currencies';
  static const String tableOptimizationResults = 'optimization_results';
  static const String tableOptimizationDetails = 'optimization_details';

  // Colonnes communes
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