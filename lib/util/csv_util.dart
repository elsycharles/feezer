import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../model/provider_model.dart' as model;
import '../model/fee_interval_model.dart';
import '../util/database_util.dart';
import '../util/constant_util.dart';
import '../provider/currency_provider.dart';

class CsvResult {
  const CsvResult({
    required this.success,
    this.message,
    this.providersCount = 0,
    this.feeIntervalsCount = 0,
    this.errors = const [],
  });

  final bool success;
  final String? message;
  final int providersCount;
  final int feeIntervalsCount;
  final List<String> errors;
}

// Configuration centralisée des mappings de colonnes
class _ColumnMapping {
  static const providerName = [
    'provider_name', 'name', 'nom', 'nom_fournisseur', 
    'provider', 'fournisseur', 'anarany_mpanome'
  ];
  
  static const description = [
    'provider_description', 'description', 'desc', 'famaritana'
  ];
  
  static const icon = [
    'provider_icon', 'icon', 'icone', 'sary'
  ];
  
  static const minAmount = [
    'min_amount', 'min', 'minimum', 'montant_min', 'vola_farany_kely'
  ];
  
  static const maxAmount = [
    'max_amount', 'max', 'maximum', 'montant_max', 'vola_farany_lehibe'
  ];
  
  static const fee = [
    'fee', 'fees', 'frais', 'commission', 'sara'
  ];
}

class CsvUtil {
  static int _idCounter = 0;

  static String _generateUniqueId() {
    return '${DateTime.now().millisecondsSinceEpoch}${++_idCounter}';
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    return value is int ? value : int.tryParse(value.toString());
  }

  // ============================================================================
  // IMPORT METHODS
  // ============================================================================

  static Future<CsvResult> importFromCsv(String csvContent, CurrencyProvider currencyProvider) async {
    try {
      final rows = const CsvToListConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvContent);

      if (rows.isEmpty) {
        return const CsvResult(success: false, message: 'CSV file is empty');
      }

      final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
      final dataRows = rows.skip(1).where(_isValidRow).toList();

      if (dataRows.isEmpty) {
        return const CsvResult(success: false, message: 'No data rows found');
      }

      return await _processImport(headers, dataRows, currencyProvider);
    } catch (e) {
      return CsvResult(success: false, message: 'Import failed: ${e.toString()}');
    }
  }

  static bool _isValidRow(List<dynamic> row) {
    return row.any((cell) => cell.toString().trim().isNotEmpty);
  }

  static Future<CsvResult> _processImport(
    List<String> headers,
    List<List<dynamic>> dataRows,
    CurrencyProvider currencyProvider,
  ) async {
    final hasColumn = (List<String> mapping) =>
      headers.any((h) => mapping.contains(h));

    final hasProviderName = hasColumn(_ColumnMapping.providerName);
    final hasFeeFields = hasColumn(_ColumnMapping.minAmount) && 
                        hasColumn(_ColumnMapping.maxAmount) && 
                        hasColumn(_ColumnMapping.fee);
    final hasProviderFields = hasColumn(_ColumnMapping.description) || 
                             hasColumn(_ColumnMapping.icon);

    if (!hasProviderName) {
      return const CsvResult(
        success: false,
        message: 'Provider name column not found',
      );
    }

    // Déterminer le type d'import
    if (hasFeeFields && hasProviderFields) {
      return await _importCombined(headers, dataRows, currencyProvider);
    } else if (hasProviderFields && !hasFeeFields) {
      return await _importProviders(headers, dataRows);
    } else if (hasFeeFields) {
      return await _importFeeIntervals(headers, dataRows, currencyProvider);
    }

    return await _importCombined(headers, dataRows, currencyProvider);
  }

  static Future<CsvResult> _importProviders(
    List<String> headers,
    List<List<dynamic>> dataRows,
  ) async {
    final db = DatabaseUtil();
    final indices = _HeaderIndices(headers);
    
    if (indices.providerName == -1) {
      return const CsvResult(
        success: false,
        message: 'Provider name column not found',
      );
    }

    int successCount = 0;
    final errors = <String>[];

    for (int i = 0; i < dataRows.length; i++) {
      final result = await _processProviderRow(
        db, dataRows[i], indices, i + 2
      );
      
      if (result.success) {
        successCount++;
      } else if (result.error != null) {
        errors.add(result.error!);
      }
    }

    return CsvResult(
      success: successCount > 0,
      message: 'Imported $successCount provider(s)',
      providersCount: successCount,
      errors: errors,
    );
  }

  static Future<_RowResult> _processProviderRow(
    DatabaseUtil db,
    List<dynamic> row,
    _HeaderIndices indices,
    int rowNumber,
  ) async {
    try {
      final name = _getCellValue(row, indices.providerName)?.trim();

      if (name == null || name.isEmpty) {
        return _RowResult(error: 'Row $rowNumber: Provider name is required');
      }

      final existing = await db.query(
        ConstantUtil.tableProviders,
        where: '${ConstantUtil.columnName} = ?',
        whereArgs: [name],
      );

      if (existing.isNotEmpty) {
        return _RowResult(error: 'Row $rowNumber: Provider "$name" already exists');
      }

      final provider = model.Provider(
        id: _generateUniqueId(),
        name: name,
        description: _getCellValue(row, indices.description)?.trim() ?? '',
        iconName: _getCellValue(row, indices.icon)?.trim() ?? 'business',
      );

      await db.insert(ConstantUtil.tableProviders, model.Provider.toMap(provider));
      return _RowResult(success: true);
    } catch (e) {
      return _RowResult(error: 'Row $rowNumber: ${e.toString()}');
    }
  }

  static Future<CsvResult> _importFeeIntervals(
    List<String> headers,
    List<List<dynamic>> dataRows,
    CurrencyProvider currencyProvider,
  ) async {
    final db = DatabaseUtil();
    final indices = _HeaderIndices(headers);

    if (!indices.hasValidFeeColumns) {
      return const CsvResult(
        success: false,
        message: 'Required columns not found: min_amount, max_amount, and fee',
      );
    }

    int successCount = 0;
    final errors = <String>[];

    for (int i = 0; i < dataRows.length; i++) {
      final result = await _processFeeIntervalRow(
        db, dataRows[i], indices, i + 2, currencyProvider
      );
      
      if (result.success) {
        successCount++;
      } else if (result.error != null) {
        errors.add(result.error!);
      }
    }

    return CsvResult(
      success: successCount > 0,
      message: 'Imported $successCount fee interval(s)',
      feeIntervalsCount: successCount,
      errors: errors,
    );
  }

  static Future<_RowResult> _processFeeIntervalRow(
    DatabaseUtil db,
    List<dynamic> row,
    _HeaderIndices indices,
    int rowNumber,
    CurrencyProvider currencyProvider,
  ) async {
    try {
      final providerName = _getCellValue(row, indices.providerName)?.trim();
      
      if (providerName == null || providerName.isEmpty) {
        return _RowResult(error: 'Row $rowNumber: Provider name is required');
      }

      final providerId = await _getProviderId(db, providerName);
      if (providerId == null) {
        return _RowResult(error: 'Row $rowNumber: Provider "$providerName" not found');
      }

      final amounts = _parseRowAmounts(row, indices);
      final validation = _validateAmounts(amounts, rowNumber);
      
      if (validation != null) {
        return _RowResult(error: validation);
      }

      // Convert amounts to Ariary (base currency) before storing
      final minAmountInAriary = currencyProvider.convertToAriary(amounts.min!);
      final maxAmountInAriary = currencyProvider.convertToAriary(amounts.max!);
      final feeInAriary = currencyProvider.convertToAriary(amounts.fee!);

      final overlap = await _checkIntervalOverlap(
        db, providerId, minAmountInAriary, maxAmountInAriary
      );
      
      if (overlap != null) {
        return _RowResult(
          error: 'Row $rowNumber: Interval overlaps with existing interval ($overlap)'
        );
      }

      final feeInterval = FeeInterval(
        id: _generateUniqueId(),
        minAmount: minAmountInAriary,
        maxAmount: maxAmountInAriary,
        fee: feeInAriary,
      );

      await db.insert(
        ConstantUtil.tableFeeIntervals,
        FeeInterval.toMap(feeInterval, providerId.toString())
      );
      
      return _RowResult(success: true);
    } catch (e) {
      return _RowResult(error: 'Row $rowNumber: ${e.toString()}');
    }
  }

  static Future<int?> _getProviderId(DatabaseUtil db, String providerName) async {
    final providers = await db.query(
      ConstantUtil.tableProviders,
      where: '${ConstantUtil.columnName} = ?',
      whereArgs: [providerName],
    );

    if (providers.isEmpty) return null;
    return _parseId(providers.first[ConstantUtil.columnId]);
  }

  static _AmountData _parseRowAmounts(List<dynamic> row, _HeaderIndices indices) {
    return _AmountData(
      min: _parseAmount(_getCellValue(row, indices.minAmount)),
      max: _parseAmount(_getCellValue(row, indices.maxAmount)),
      fee: _parseAmount(_getCellValue(row, indices.fee)),
      minStr: _getCellValue(row, indices.minAmount),
      maxStr: _getCellValue(row, indices.maxAmount),
      feeStr: _getCellValue(row, indices.fee),
    );
  }

  static String? _validateAmounts(_AmountData amounts, int rowNumber) {
    if (amounts.min == null || amounts.max == null || amounts.fee == null) {
      return 'Row $rowNumber: Invalid amounts (min: ${amounts.minStr}, max: ${amounts.maxStr}, fee: ${amounts.feeStr})';
    }

    if (amounts.min! >= amounts.max!) {
      return 'Row $rowNumber: Min amount (${amounts.min}) must be less than max amount (${amounts.max})';
    }

    if (amounts.fee! < 0) {
      return 'Row $rowNumber: Fee must be positive';
    }

    return null;
  }

  static Future<String?> _checkIntervalOverlap(
    DatabaseUtil db,
    int providerId,
    double min,
    double max,
  ) async {
    final existing = await db.query(
      ConstantUtil.tableFeeIntervals,
      where: '${ConstantUtil.columnProviderId} = ?',
      whereArgs: [providerId],
    );

    for (final interval in existing) {
      final existingMin = (interval[ConstantUtil.columnMinAmount] as num).toDouble();
      final existingMax = (interval[ConstantUtil.columnMaxAmount] as num).toDouble();

      if (_hasOverlap(min, max, existingMin, existingMax)) {
        return '$existingMin - $existingMax';
      }
    }

    return null;
  }

  static bool _hasOverlap(double min, double max, double existingMin, double existingMax) {
    return (min >= existingMin && min < existingMax) ||
           (max > existingMin && max <= existingMax) ||
           (min <= existingMin && max >= existingMax);
  }

  static Future<CsvResult> _importCombined(
    List<String> headers,
    List<List<dynamic>> dataRows,
    CurrencyProvider currencyProvider,
  ) async {
    final db = DatabaseUtil();
    final indices = _HeaderIndices(headers);
    int providersCount = 0;
    int feesCount = 0;
    final errors = <String>[];

    final providerGroups = _groupRowsByProvider(dataRows, indices);

    for (final entry in providerGroups.entries) {
      final result = await _processProviderGroup(
        db, entry.key, entry.value, dataRows, indices, currencyProvider
      );
      
      providersCount += result.providersAdded;
      feesCount += result.feesAdded;
      errors.addAll(result.errors);
    }

    return CsvResult(
      success: providersCount > 0 || feesCount > 0,
      message: 'Imported $providersCount provider(s) and $feesCount fee interval(s)',
      providersCount: providersCount,
      feeIntervalsCount: feesCount,
      errors: errors,
    );
  }

  static Map<String, List<int>> _groupRowsByProvider(
    List<List<dynamic>> dataRows,
    _HeaderIndices indices,
  ) {
    final groups = <String, List<int>>{};
    
    for (int i = 0; i < dataRows.length; i++) {
      final providerName = _getCellValue(dataRows[i], indices.providerName)?.trim();
      if (providerName != null && providerName.isNotEmpty) {
        groups.putIfAbsent(providerName, () => []).add(i);
      }
    }
    
    return groups;
  }

  static Future<_GroupResult> _processProviderGroup(
    DatabaseUtil db,
    String providerName,
    List<int> rowIndices,
    List<List<dynamic>> dataRows,
    _HeaderIndices indices,
    CurrencyProvider currencyProvider,
  ) async {
    try {
      final providerId = await _ensureProviderExists(
        db, providerName, rowIndices, dataRows, indices
      );

      if (providerId == null) {
        return _GroupResult(
          errors: ['Provider "$providerName": Invalid provider ID']
        );
      }

      final result = await _importGroupFeeIntervals(
        db, providerId, rowIndices, dataRows, indices, providerName, currencyProvider
      );

      return result;
    } catch (e) {
      return _GroupResult(
        errors: ['Provider "$providerName": ${e.toString()}']
      );
    }
  }

  static Future<int?> _ensureProviderExists(
    DatabaseUtil db,
    String providerName,
    List<int> rowIndices,
    List<List<dynamic>> dataRows,
    _HeaderIndices indices,
  ) async {
    var providers = await db.query(
      ConstantUtil.tableProviders,
      where: '${ConstantUtil.columnName} = ?',
      whereArgs: [providerName],
    );

    if (providers.isNotEmpty) {
      return _parseId(providers.first[ConstantUtil.columnId]);
    }

    // Créer le provider avec les infos de la première ligne valide
    final providerData = _extractProviderData(rowIndices, dataRows, indices);
    
    final provider = model.Provider(
      id: _generateUniqueId(),
      name: providerName,
      description: providerData.description,
      iconName: providerData.iconName,
    );

    await db.insert(ConstantUtil.tableProviders, model.Provider.toMap(provider));
    return _parseId(provider.id);
  }

  static _ProviderData _extractProviderData(
    List<int> rowIndices,
    List<List<dynamic>> dataRows,
    _HeaderIndices indices,
  ) {
    String? description;
    String? iconName;

    for (final rowIndex in rowIndices) {
      final row = dataRows[rowIndex];
      description ??= _getCellValue(row, indices.description)?.trim();
      iconName ??= _getCellValue(row, indices.icon)?.trim();
      
      if (description != null && iconName != null) break;
    }

    return _ProviderData(
      description: description ?? '',
      iconName: iconName ?? 'business',
    );
  }

  static Future<_GroupResult> _importGroupFeeIntervals(
    DatabaseUtil db,
    int providerId,
    List<int> rowIndices,
    List<List<dynamic>> dataRows,
    _HeaderIndices indices,
    String providerName,
    CurrencyProvider currencyProvider,
  ) async {
    int providersAdded = rowIndices.isEmpty ? 0 : 1;
    int feesAdded = 0;
    final errors = <String>[];

    for (final rowIndex in rowIndices) {
      final row = dataRows[rowIndex];
      final amounts = _parseRowAmounts(row, indices);

      if (_isEmptyFeeRow(amounts)) continue;

      final validation = _validateAmounts(amounts, rowIndex + 2);
      if (validation != null) {
        errors.add(validation);
        continue;
      }

      // Convert amounts to Ariary (base currency) before storing
      final minAmountInAriary = currencyProvider.convertToAriary(amounts.min!);
      final maxAmountInAriary = currencyProvider.convertToAriary(amounts.max!);
      final feeInAriary = currencyProvider.convertToAriary(amounts.fee!);

      final overlap = await _checkIntervalOverlap(
        db, providerId, minAmountInAriary, maxAmountInAriary
      );
      
      if (overlap != null) {
        errors.add('Row ${rowIndex + 2}: Interval overlaps with existing interval ($overlap)');
        continue;
      }

      final feeInterval = FeeInterval(
        id: _generateUniqueId(),
        minAmount: minAmountInAriary,
        maxAmount: maxAmountInAriary,
        fee: feeInAriary,
      );

      await db.insert(
        ConstantUtil.tableFeeIntervals,
        FeeInterval.toMap(feeInterval, providerId.toString())
      );
      feesAdded++;
    }

    return _GroupResult(
      providersAdded: providersAdded,
      feesAdded: feesAdded,
      errors: errors,
    );
  }

  static bool _isEmptyFeeRow(_AmountData amounts) {
    return (amounts.minStr == null || amounts.minStr!.isEmpty) &&
           (amounts.maxStr == null || amounts.maxStr!.isEmpty) &&
           (amounts.feeStr == null || amounts.feeStr!.isEmpty);
  }

  // ============================================================================
  // EXPORT METHODS
  // ============================================================================

  static Future<CsvResult> exportToCsv({
    String? providerId,
    String locale = 'en',
    CurrencyProvider? currencyProvider,
  }) async {
    try {
      final db = DatabaseUtil();
      final csvData = await _buildExportData(db, providerId, locale, currencyProvider);

      if (csvData.length <= 1) {
        return const CsvResult(success: false, message: 'No data to export');
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      final filePath = await _saveCsvFile(csvString, 'combined');
      await Share.shareXFiles([XFile(filePath)]);

      return CsvResult(
        success: true,
        message: 'Export successful',
        providersCount: csvData.where((row) => row[0].toString().isNotEmpty).length - 1,
        feeIntervalsCount: csvData.length - 1,
      );
    } catch (e) {
      return CsvResult(success: false, message: 'Export failed: ${e.toString()}');
    }
  }

  static Future<List<List<dynamic>>> _buildExportData(
    DatabaseUtil db,
    String? providerId,
    String locale,
    CurrencyProvider? currencyProvider,
  ) async {
    final providers = await _fetchProviders(db, providerId);
    final headers = _getHeaders(locale);
    final csvData = <List<dynamic>>[headers];

    for (final provider in providers) {
      final providerIdValue = _parseId(provider[ConstantUtil.columnId]);
      if (providerIdValue == null) continue;

      final feeIntervals = await db.query(
        ConstantUtil.tableFeeIntervals,
        where: '${ConstantUtil.columnProviderId} = ?',
        whereArgs: [providerIdValue],
      );

      _addProviderRows(csvData, provider, feeIntervals, currencyProvider);
    }

    return csvData;
  }

  static Future<List<Map<String, dynamic>>> _fetchProviders(
    DatabaseUtil db,
    String? providerId,
  ) async {
    if (providerId == null || providerId.isEmpty) {
      return await db.query(ConstantUtil.tableProviders);
    }

    final parsedId = _parseId(providerId);
    if (parsedId == null) {
      return await db.query(ConstantUtil.tableProviders);
    }

    return await db.query(
      ConstantUtil.tableProviders,
      where: '${ConstantUtil.columnId} = ?',
      whereArgs: [parsedId],
    );
  }

  static void _addProviderRows(
    List<List<dynamic>> csvData,
    Map<String, dynamic> provider,
    List<Map<String, dynamic>> feeIntervals,
    CurrencyProvider? currencyProvider,
  ) {
    final baseRow = [
      provider[ConstantUtil.columnName] ?? '',
      provider[ConstantUtil.columnDescription] ?? '',
      provider[ConstantUtil.columnIconName] ?? 'business',
    ];

    if (feeIntervals.isEmpty) {
      csvData.add([...baseRow, '', '', '']);
    } else {
      for (final fee in feeIntervals) {
        final minAmount = (fee[ConstantUtil.columnMinAmount] as num?)?.toDouble() ?? 0.0;
        final maxAmount = (fee[ConstantUtil.columnMaxAmount] as num?)?.toDouble() ?? 0.0;
        final feeAmount = (fee[ConstantUtil.columnFee] as num?)?.toDouble() ?? 0.0;

        // Convert amounts from Ariary (base currency) to selected currency for export
        final minAmountInSelectedCurrency = currencyProvider?.convertFromAriary(minAmount) ?? minAmount;
        final maxAmountInSelectedCurrency = currencyProvider?.convertFromAriary(maxAmount) ?? maxAmount;
        final feeAmountInSelectedCurrency = currencyProvider?.convertFromAriary(feeAmount) ?? feeAmount;

        csvData.add([
          ...baseRow,
          minAmountInSelectedCurrency,
          maxAmountInSelectedCurrency,
          feeAmountInSelectedCurrency,
        ]);
      }
    }
  }

  static Future<String> _saveCsvFile(String csvContent, String type) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/${type}_$timestamp.csv');
    await file.writeAsString(csvContent);
    return file.path;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  static int _findHeaderIndex(List<String> headers, List<String> possibleNames) {
    for (final name in possibleNames) {
      final index = headers.indexWhere((h) => h == name.toLowerCase());
      if (index != -1) return index;
    }
    return -1;
  }

  static String? _getCellValue(List<dynamic> row, int index) {
    if (index == -1 || index >= row.length) return null;
    final value = row[index]?.toString().trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  static double? _parseAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  static List<String> _getHeaders(String locale) {
    const headers = {
      'fr': ['nom_fournisseur', 'description', 'icone', 'montant_min', 'montant_max', 'frais'],
      'mg': ['anarany_mpanome', 'famaritana', 'sary', 'vola_farany_kely', 'vola_farany_lehibe', 'sara'],
    };
    
    return headers[locale] ?? 
      ['provider_name', 'provider_description', 'provider_icon', 'min_amount', 'max_amount', 'fee'];
  }

  static String getImportTemplate(String locale) {
    final headers = _getHeaders(locale);
    final template = [
      headers,
      ['TELMA', 'Mobile provider', 'phone', '0', '5000', '10'],
      ['TELMA', '', '', '5001', '10000', '25'],
      ['AIRTEL', 'Another mobile provider', 'phone_android', '1000', '2000', '15'],
    ];

    return const ListToCsvConverter().convert(template);
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

class _HeaderIndices {
  _HeaderIndices(List<String> headers)
      : providerName = CsvUtil._findHeaderIndex(headers, _ColumnMapping.providerName),
        description = CsvUtil._findHeaderIndex(headers, _ColumnMapping.description),
        icon = CsvUtil._findHeaderIndex(headers, _ColumnMapping.icon),
        minAmount = CsvUtil._findHeaderIndex(headers, _ColumnMapping.minAmount),
        maxAmount = CsvUtil._findHeaderIndex(headers, _ColumnMapping.maxAmount),
        fee = CsvUtil._findHeaderIndex(headers, _ColumnMapping.fee);

  final int providerName;
  final int description;
  final int icon;
  final int minAmount;
  final int maxAmount;
  final int fee;

  bool get hasValidFeeColumns => 
    providerName != -1 && minAmount != -1 && maxAmount != -1 && fee != -1;
}

class _RowResult {
  const _RowResult({this.success = false, this.error});
  
  final bool success;
  final String? error;
}

class _AmountData {
  const _AmountData({
    this.min,
    this.max,
    this.fee,
    this.minStr,
    this.maxStr,
    this.feeStr,
  });

  final double? min;
  final double? max;
  final double? fee;
  final String? minStr;
  final String? maxStr;
  final String? feeStr;
}

class _ProviderData {
  const _ProviderData({
    required this.description,
    required this.iconName,
  });

  final String description;
  final String iconName;
}

class _GroupResult {
  const _GroupResult({
    this.providersAdded = 0,
    this.feesAdded = 0,
    this.errors = const [],
  });

  final int providersAdded;
  final int feesAdded;
  final List<String> errors;
}