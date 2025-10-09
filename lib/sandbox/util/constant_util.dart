class ConstantUtil {
  // Configuration base de données
  static const String databaseName = 'fee_optimizer.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableFeeIntervals = 'fee_intervals';
  static const String tableProviders = 'providers';
  static const String tableOptimizationResults = 'optimization_results';
  static const String tableOptimizationDetails = 'optimization_details';

  // Colonnes communes
  static const String columnId = 'id';
  static const String columnCreationDatetime = 'creation_datetime';

  // FeeInterval columns
  static const String columnMinAmount = 'min_amount';
  static const String columnMaxAmount = 'max_amount';
  static const String columnFee = 'fee';
  static const String columnProviderId = 'provider_id';

  // Provider columns
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnIconName = 'icon_name';

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