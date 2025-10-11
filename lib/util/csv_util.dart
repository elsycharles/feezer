import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../model/provider_model.dart' as model;
import '../model/fee_interval_model.dart';
import '../util/database_util.dart';
import '../util/constant_util.dart';

class CsvResult {
  CsvResult({
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

class CsvUtil {
  static const String providerNameKey = 'provider_name';
  static const String providerDescriptionKey = 'provider_description';
  static const String providerIconKey = 'provider_icon';
  static const String minAmountKey = 'min_amount';
  static const String maxAmountKey = 'max_amount';
  static const String feeKey = 'fee';

  // ID counter pour éviter les doublons
  static int _idCounter = 0;

  static String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _idCounter++;
    return '$timestamp$_idCounter';
  }

  // Helper pour parser un ID en toute sécurité
  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }
    return null;
  }

  // ============================================================================
  // IMPORT METHODS
  // ============================================================================

  /// Import data from CSV file - automatically detects type based on columns
  static Future<CsvResult> importFromCsv(String csvContent) async {
    try {
      // Parse CSV
      final rows = const CsvToListConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvContent);

      if (rows.isEmpty) {
        return CsvResult(
          success: false,
          message: 'CSV file is empty',
        );
      }

      // Extract headers (first row)
      final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
      final dataRows = rows.skip(1).where((row) {
        // Filtrer les lignes complètement vides
        return row.any((cell) => cell.toString().trim().isNotEmpty);
      }).toList();

      if (dataRows.isEmpty) {
        return CsvResult(
          success: false,
          message: 'No data rows found',
        );
      }

      // Detect import type automatically and process
      final hasProviderName = headers.any((h) =>
          h == 'provider_name' || 
          h == 'nom_fournisseur' || 
          h == 'anaran\'ny_mpanome' ||
          h == 'provider' ||
          h == 'fournisseur');
      
      final hasDescription = headers.any((h) =>
          h == 'provider_description' || 
          h == 'description' ||
          h == 'famaritana');
      
      final hasIcon = headers.any((h) =>
          h == 'provider_icon' || 
          h == 'icon' ||
          h == 'icone' ||
          h == 'sary');
      
      final hasMinAmount = headers.any((h) =>
          h == 'min_amount' || 
          h == 'montant_min' ||
          h == 'vola_farany_kely' ||
          h == 'min');
      
      final hasMaxAmount = headers.any((h) =>
          h == 'max_amount' || 
          h == 'montant_max' ||
          h == 'vola_farany_lehibe' ||
          h == 'max');
      
      final hasFee = headers.any((h) =>
          h == 'fee' || 
          h == 'frais' ||
          h == 'sara');

      final hasFeeFields = hasMinAmount && hasMaxAmount && hasFee;
      final hasProviderFields = hasDescription || hasIcon;

      // Determine import type and process
      if (hasProviderName && hasFeeFields && hasProviderFields) {
        // Combined data
        return await _importCombined(headers, dataRows);
      } else if (hasProviderName && hasProviderFields && !hasFeeFields) {
        // Providers only
        return await _importProviders(headers, dataRows);
      } else if (hasProviderName && hasFeeFields) {
        // Fee intervals only
        return await _importFeeIntervals(headers, dataRows);
      } else {
        // Default to combined import
        return await _importCombined(headers, dataRows);
      }
    } catch (e) {
      return CsvResult(
        success: false,
        message: 'Import failed: ${e.toString()}',
      );
    }
  }



  static Future<CsvResult> _importProviders(
    List<String> headers,
    List<List<dynamic>> dataRows,
  ) async {
    final db = DatabaseUtil();
    int successCount = 0;
    final errors = <String>[];

    // Map header indices
    final nameIndex = _findHeaderIndex(headers, [
      providerNameKey,
      'name',
      'nom',
      'nom_fournisseur',
      'provider',
      'fournisseur',
      'anaran\'ny_mpanome',
    ]);
    final descIndex = _findHeaderIndex(headers, [
      providerDescriptionKey,
      'description',
      'desc',
      'famaritana',
    ]);
    final iconIndex = _findHeaderIndex(headers, [
      providerIconKey,
      'icon',
      'icone',
      'sary',
    ]);

    if (nameIndex == -1) {
      return CsvResult(
        success: false,
        message: 'Provider name column not found. Required headers: provider_name, name, nom, provider, fournisseur, or nom_fournisseur',
      );
    }

    for (int i = 0; i < dataRows.length; i++) {
      try {
        final row = dataRows[i];
        final name = _getCellValue(row, nameIndex)?.trim();

        if (name == null || name.isEmpty) {
          errors.add('Row ${i + 2}: Provider name is required');
          continue;
        }

        // Check if provider already exists
        final existing = await db.query(
          ConstantUtil.tableProviders,
          where: '${ConstantUtil.columnName} = ?',
          whereArgs: [name],
        );

        if (existing.isNotEmpty) {
          errors.add('Row ${i + 2}: Provider "$name" already exists');
          continue;
        }

        final provider = model.Provider(
          id: _generateUniqueId(),
          name: name,
          description: _getCellValue(row, descIndex)?.trim() ?? '',
          iconName: _getCellValue(row, iconIndex)?.trim() ?? 'business',
        );

        await db.insert(ConstantUtil.tableProviders, model.Provider.toMap(provider));
        successCount++;
      } catch (e) {
        errors.add('Row ${i + 2}: ${e.toString()}');
      }
    }

    return CsvResult(
      success: successCount > 0,
      message: 'Imported $successCount provider(s)',
      providersCount: successCount,
      errors: errors,
    );
  }

  static Future<CsvResult> _importFeeIntervals(
    List<String> headers,
    List<List<dynamic>> dataRows,
  ) async {
    final db = DatabaseUtil();
    int successCount = 0;
    final errors = <String>[];

    // Map header indices
    final providerNameIndex = _findHeaderIndex(headers, [
      providerNameKey,
      'provider',
      'provider_name',
      'fournisseur',
      'nom_fournisseur',
      'anaran\'ny_mpanome',
    ]);
    final minIndex = _findHeaderIndex(headers, [
      minAmountKey,
      'min',
      'minimum',
      'min_amount',
      'montant_min',
      'vola_farany_kely',
    ]);
    final maxIndex = _findHeaderIndex(headers, [
      maxAmountKey,
      'max',
      'maximum',
      'max_amount',
      'montant_max',
      'vola_farany_lehibe',
    ]);
    final feeIndex = _findHeaderIndex(headers, [
      feeKey,
      'fee',
      'fees',
      'frais',
      'commission',
      'sara',
    ]);

    if (providerNameIndex == -1) {
      return CsvResult(
        success: false,
        message: 'Provider name column not found',
      );
    }

    if (minIndex == -1 || maxIndex == -1 || feeIndex == -1) {
      return CsvResult(
        success: false,
        message: 'Required columns not found: min_amount, max_amount, and fee',
      );
    }

    for (int i = 0; i < dataRows.length; i++) {
      try {
        final row = dataRows[i];
        final providerName = _getCellValue(row, providerNameIndex)?.trim();
        final minStr = _getCellValue(row, minIndex);
        final maxStr = _getCellValue(row, maxIndex);
        final feeStr = _getCellValue(row, feeIndex);

        if (providerName == null || providerName.isEmpty) {
          errors.add('Row ${i + 2}: Provider name is required');
          continue;
        }

        // Find provider
        final providers = await db.query(
          ConstantUtil.tableProviders,
          where: '${ConstantUtil.columnName} = ?',
          whereArgs: [providerName],
        );

        if (providers.isEmpty) {
          errors.add('Row ${i + 2}: Provider "$providerName" not found');
          continue;
        }

        final providerIdValue = providers.first[ConstantUtil.columnId];
        final providerId = _parseId(providerIdValue);

        if (providerId == null) {
          errors.add('Row ${i + 2}: Invalid provider ID');
          continue;
        }

        // Parse amounts
        final min = _parseAmount(minStr);
        final max = _parseAmount(maxStr);
        final fee = _parseAmount(feeStr);

        if (min == null || max == null || fee == null) {
          errors.add('Row ${i + 2}: Invalid amounts (min: $minStr, max: $maxStr, fee: $feeStr)');
          continue;
        }

        if (min >= max) {
          errors.add('Row ${i + 2}: Min amount ($min) must be less than max amount ($max)');
          continue;
        }

        if (fee < 0) {
          errors.add('Row ${i + 2}: Fee must be positive');
          continue;
        }

        // Vérifier les chevauchements d'intervalles
        final overlapping = await _checkIntervalOverlap(db, providerId, min, max);
        if (overlapping != null) {
          errors.add('Row ${i + 2}: Interval overlaps with existing interval ($overlapping)');
          continue;
        }

        final feeInterval = FeeInterval(
          id: _generateUniqueId(),
          minAmount: min,
          maxAmount: max,
          fee: fee,
        );

        await db.insert(ConstantUtil.tableFeeIntervals, FeeInterval.toMap(feeInterval, providerId.toString()));
        successCount++;
      } catch (e) {
        errors.add('Row ${i + 2}: ${e.toString()}');
      }
    }

    return CsvResult(
      success: successCount > 0,
      message: 'Imported $successCount fee interval(s)',
      feeIntervalsCount: successCount,
      errors: errors,
    );
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

      // Vérifier le chevauchement
      if ((min >= existingMin && min < existingMax) ||
          (max > existingMin && max <= existingMax) ||
          (min <= existingMin && max >= existingMax)) {
        return '$existingMin - $existingMax';
      }
    }

    return null;
  }

  static Future<CsvResult> _importCombined(
    List<String> headers,
    List<List<dynamic>> dataRows,
  ) async {
    final db = DatabaseUtil();
    int providersCount = 0;
    int feesCount = 0;
    final errors = <String>[];

    // Map header indices
    final providerNameIndex = _findHeaderIndex(headers, [
      providerNameKey,
      'provider',
      'provider_name',
      'fournisseur',
      'nom_fournisseur',
      'anaran\'ny_mpanome',
    ]);
    final descIndex = _findHeaderIndex(headers, [
      providerDescriptionKey,
      'description',
      'desc',
      'famaritana',
    ]);
    final iconIndex = _findHeaderIndex(headers, [
      providerIconKey,
      'icon',
      'icone',
      'sary',
    ]);
    final minIndex = _findHeaderIndex(headers, [
      minAmountKey,
      'min',
      'minimum',
      'montant_min',
      'vola_farany_kely',
    ]);
    final maxIndex = _findHeaderIndex(headers, [
      maxAmountKey,
      'max',
      'maximum',
      'montant_max',
      'vola_farany_lehibe',
    ]);
    final feeIndex = _findHeaderIndex(headers, [
      feeKey,
      'fee',
      'frais',
      'sara',
    ]);

    if (providerNameIndex == -1) {
      return CsvResult(
        success: false,
        message: 'Provider name column not found',
      );
    }

    // Group rows by provider
    final providerMap = <String, List<int>>{};
    for (int i = 0; i < dataRows.length; i++) {
      final providerName = _getCellValue(dataRows[i], providerNameIndex)?.trim();
      if (providerName != null && providerName.isNotEmpty) {
        providerMap.putIfAbsent(providerName, () => []).add(i);
      }
    }

    // Process each provider
    for (final entry in providerMap.entries) {
      final providerName = entry.key;
      final rowIndices = entry.value;

      try {
        // Check if provider exists
        var providers = await db.query(
          ConstantUtil.tableProviders,
          where: '${ConstantUtil.columnName} = ?',
          whereArgs: [providerName],
        );

        int? providerId;

        if (providers.isEmpty) {
          // Create provider - prendre description et icône de la première ligne non-vide
          String? description;
          String? iconName;

          for (final rowIndex in rowIndices) {
            final row = dataRows[rowIndex];
            if (description == null || description.isEmpty) {
              description = _getCellValue(row, descIndex)?.trim();
            }
            if (iconName == null || iconName.isEmpty) {
              iconName = _getCellValue(row, iconIndex)?.trim();
            }
            if ((description != null && description.isNotEmpty) && 
                (iconName != null && iconName.isNotEmpty)) {
              break;
            }
          }

          final provider = model.Provider(
            id: _generateUniqueId(),
            name: providerName,
            description: description ?? '',
            iconName: iconName ?? 'business',
          );

          await db.insert(ConstantUtil.tableProviders, model.Provider.toMap(provider));
          providerId = _parseId(provider.id);
          providersCount++;
        } else {
          final providerIdValue = providers.first[ConstantUtil.columnId];
          providerId = _parseId(providerIdValue);
        }

        if (providerId == null) {
          errors.add('Provider "$providerName": Invalid provider ID');
          continue;
        }

        // Import fee intervals for this provider
        for (final rowIndex in rowIndices) {
          try {
            final row = dataRows[rowIndex];
            final minStr = _getCellValue(row, minIndex);
            final maxStr = _getCellValue(row, maxIndex);
            final feeStr = _getCellValue(row, feeIndex);

            // Skip if no fee data
            if ((minStr == null || minStr.trim().isEmpty) &&
                (maxStr == null || maxStr.trim().isEmpty) &&
                (feeStr == null || feeStr.trim().isEmpty)) {
              continue;
            }

            final min = _parseAmount(minStr);
            final max = _parseAmount(maxStr);
            final fee = _parseAmount(feeStr);

            if (min == null || max == null || fee == null) {
              errors.add('Row ${rowIndex + 2}: Invalid amounts for provider "$providerName" (min: $minStr, max: $maxStr, fee: $feeStr)');
              continue;
            }

            if (min >= max) {
              errors.add('Row ${rowIndex + 2}: Min ($min) must be less than max ($max)');
              continue;
            }

            if (fee < 0) {
              errors.add('Row ${rowIndex + 2}: Fee must be positive');
              continue;
            }

            // Vérifier les chevauchements
            final overlapping = await _checkIntervalOverlap(db, providerId, min, max);
            if (overlapping != null) {
              errors.add('Row ${rowIndex + 2}: Interval overlaps with existing interval ($overlapping)');
              continue;
            }

            final feeInterval = FeeInterval(
              id: _generateUniqueId(),
              minAmount: min,
              maxAmount: max,
              fee: fee,
            );

            await db.insert(ConstantUtil.tableFeeIntervals, FeeInterval.toMap(feeInterval, providerId.toString()));
            feesCount++;
          } catch (e) {
            errors.add('Row ${rowIndex + 2}: ${e.toString()}');
          }
        }
      } catch (e) {
        errors.add('Provider "$providerName": ${e.toString()}');
      }
    }

    return CsvResult(
      success: providersCount > 0 || feesCount > 0,
      message: 'Imported $providersCount provider(s) and $feesCount fee interval(s)',
      providersCount: providersCount,
      feeIntervalsCount: feesCount,
      errors: errors,
    );
  }

  // ============================================================================
  // EXPORT METHODS
  // ============================================================================

  /// Export all data to CSV file (always combined format)
  static Future<CsvResult> exportToCsv({
    String? providerId,
    String locale = 'en',
  }) async {
    try {
      final db = DatabaseUtil();
      final csvData = await _exportCombined(db, providerId, locale);

      if (csvData.length <= 1) {
        return CsvResult(
          success: false,
          message: 'No data to export',
        );
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Save and share file
      final filePath = await _saveCsvFile(csvString, 'combined');
      await Share.shareXFiles([XFile(filePath)]);

      return CsvResult(
        success: true,
        message: 'Export successful',
        providersCount: csvData.where((row) => row[0].toString().isNotEmpty).length - 1,
        feeIntervalsCount: csvData.length - csvData.where((row) => row[0].toString().isEmpty).length - 1,
      );
    } catch (e) {
      return CsvResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
      );
    }
  }

  static Future<List<List<dynamic>>> _exportCombined(
    DatabaseUtil db,
    String? providerId,
    String locale,
  ) async {
    String? whereClause;
    List<dynamic>? whereArgs;

    if (providerId != null && providerId.isNotEmpty) {
      final parsedId = _parseId(providerId);
      if (parsedId != null) {
        whereClause = '${ConstantUtil.columnId} = ?';
        whereArgs = [parsedId];
      }
    }

    final providers = await db.query(
      ConstantUtil.tableProviders,
      where: whereClause,
      whereArgs: whereArgs,
    );

    final headers = _getCombinedHeaders(locale);
    final csvData = <List<dynamic>>[headers];

    for (final provider in providers) {
      final providerIdValue = provider[ConstantUtil.columnId];
      final parsedProviderId = _parseId(providerIdValue);

      if (parsedProviderId == null) continue;

      final feeIntervals = await db.query(
        ConstantUtil.tableFeeIntervals,
        where: '${ConstantUtil.columnProviderId} = ?',
        whereArgs: [parsedProviderId],
      );

      if (feeIntervals.isEmpty) {
        // Provider without fee intervals
        csvData.add([
          provider[ConstantUtil.columnName] ?? '',
          provider[ConstantUtil.columnDescription] ?? '',
          provider[ConstantUtil.columnIconName] ?? 'business',
          '',
          '',
          '',
        ]);
      } else {
        // Provider with fee intervals
        for (final fee in feeIntervals) {
          csvData.add([
            provider[ConstantUtil.columnName] ?? '',
            provider[ConstantUtil.columnDescription] ?? '',
            provider[ConstantUtil.columnIconName] ?? 'business',
            fee[ConstantUtil.columnMinAmount] ?? 0,
            fee[ConstantUtil.columnMaxAmount] ?? 0,
            fee[ConstantUtil.columnFee] ?? 0,
          ]);
        }
      }
    }

    return csvData;
  }

  static Future<String> _saveCsvFile(String csvContent, String type) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${type}_$timestamp.csv';
    final file = File('${directory.path}/$fileName');
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
    final value = row[index];
    if (value == null) return null;
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  static double? _parseAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    // Remove spaces and replace comma with dot
    final cleaned = value.trim().replaceAll(' ', '').replaceAll(',', '.');

    return double.tryParse(cleaned);
  }

  // Headers in different languages
  static List<String> _getCombinedHeaders(String locale) {
    switch (locale) {
      case 'fr':
        return ['nom_fournisseur', 'description', 'icone', 'montant_min', 'montant_max', 'frais'];
      case 'mg':
        return ['anaran\'ny_mpanome', 'famaritana', 'sary', 'vola_farany_kely', 'vola_farany_lehibe', 'sara'];
      default:
        return ['provider_name', 'provider_description', 'provider_icon', 'min_amount', 'max_amount', 'fee'];
    }
  }

  /// Generate CSV template for import (combined format)
  static String getImportTemplate(String locale) {
    final headers = _getCombinedHeaders(locale);
    final template = [
      headers,
      ['TELMA', 'Mobile provider', 'phone', '0', '5000', '10'],
      ['TELMA', '', '', '5001', '10000', '25'],
      ['AIRTEL', 'Another mobile provider', 'phone_android', '1000', '2000', '15'],
    ];

    return const ListToCsvConverter().convert(template);
  }
}