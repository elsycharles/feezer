import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../data/fee_interval_repository.dart';
import '../data/provider_repository.dart';
import '../l10n/app_localizations.dart';
import '../model/fee_interval_model.dart';
import '../model/provider_model.dart';
import '../provider/currency_provider.dart';
import 'constant_util.dart';

/// Outcome of an import or export.
class CsvResult {
  const CsvResult({
    required this.success,
    this.message,
    this.providersCount = 0,
    this.feeIntervalsCount = 0,
    this.errors = const [],
    this.filePath,
  });

  final bool success;
  final String? message;
  final int providersCount;
  final int feeIntervalsCount;
  final List<String> errors;
  final String? filePath;
}

/// Accepted header names (English, French, Malagasy), lower case.
abstract final class _Columns {
  static const providerName = [
    'provider_name',
    'name',
    'nom',
    'nom_fournisseur',
    'provider',
    'fournisseur',
    'anarany_mpanome',
  ];
  static const description = [
    'provider_description',
    'description',
    'desc',
    'famaritana',
  ];
  static const icon = ['provider_icon', 'icon', 'icone', 'icône', 'sary'];
  static const minAmount = [
    'min_amount',
    'min',
    'minimum',
    'montant_min',
    'vola_farany_kely',
  ];
  static const maxAmount = [
    'max_amount',
    'max',
    'maximum',
    'montant_max',
    'vola_farany_lehibe',
  ];
  static const fee = ['fee', 'fees', 'frais', 'commission', 'sara'];
  static const feeType = [
    'fee_type',
    'type_frais',
    'type',
    'is_percentage',
    'pourcentage',
    'karazany_sara',
  ];
}

/// One parsed data row.
class CsvRow {
  const CsvRow({
    required this.rowNumber,
    required this.providerName,
    this.description,
    this.icon,
    this.min,
    this.max,
    this.fee,
    this.feeType,
  });

  /// Line number in the file (header = 1).
  final int rowNumber;
  final String? providerName;
  final String? description;
  final String? icon;
  final String? min;
  final String? max;
  final String? fee;
  final String? feeType;

  bool get hasFeeData => min != null || max != null || fee != null;
}

/// CSV import/export of providers and their fee intervals.
///
/// Amounts in files are expressed in the currency selected in the app;
/// they are stored in Ariary. Percentage fees are never converted.
class CsvUtil {
  const CsvUtil._();

  // ---------------------------------------------------------------------------
  // Parsing (pure, testable)
  // ---------------------------------------------------------------------------

  /// Decodes file bytes: UTF-8 (with or without BOM), falling back to
  /// Latin-1 for files saved by older spreadsheet software.
  static String decodeBytes(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }

  /// Splits [content] into trimmed cells. The delimiter (`,` or `;`) is
  /// detected from the header line.
  static List<List<String>> parseTable(String content) {
    var text = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (text.startsWith('﻿')) text = text.substring(1);
    final firstLine = text.split('\n').first;
    final delimiter =
        ';'.allMatches(firstLine).length > ','.allMatches(firstLine).length
        ? ';'
        : ',';
    final rows = CsvToListConverter(
      fieldDelimiter: delimiter,
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(text);
    return [
      for (final row in rows) [for (final cell in row) cell.toString().trim()],
    ];
  }

  /// Parses [content] into rows, or returns `null` when there is no provider
  /// name column.
  static List<CsvRow>? parseRows(String content) {
    final table = parseTable(content);
    if (table.isEmpty) return const [];
    final headers = [for (final h in table.first) h.toLowerCase()];
    int indexOf(List<String> names) =>
        headers.indexWhere((h) => names.contains(h));

    final name = indexOf(_Columns.providerName);
    if (name < 0) return null;
    final description = indexOf(_Columns.description);
    final icon = indexOf(_Columns.icon);
    final min = indexOf(_Columns.minAmount);
    final max = indexOf(_Columns.maxAmount);
    final fee = indexOf(_Columns.fee);
    final feeType = indexOf(_Columns.feeType);

    String? cell(List<String> row, int index) {
      if (index < 0 || index >= row.length) return null;
      final value = row[index].trim();
      return value.isEmpty ? null : value;
    }

    final rows = <CsvRow>[];
    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      if (row.every((c) => c.isEmpty)) continue;
      rows.add(
        CsvRow(
          rowNumber: i + 1,
          providerName: cell(row, name),
          description: cell(row, description),
          icon: cell(row, icon),
          min: cell(row, min),
          max: cell(row, max),
          fee: cell(row, fee),
          feeType: cell(row, feeType),
        ),
      );
    }
    return rows;
  }

  static FeeType parseFeeType(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'percentage' ||
          'pourcentage' ||
          'percent' ||
          '%' ||
          '1' ||
          'true' ||
          'isan-jato' ||
          'isanjato':
        return FeeType.percentage;
      default:
        return FeeType.fixed;
    }
  }

  /// Validates a fee row and converts it to an interval in Ariary, or
  /// returns the localized error.
  static ({FeeInterval? interval, String? error}) toInterval(
    CsvRow row,
    double exchangeRate,
    AppLocalizations l10n,
  ) {
    final min = row.min == null
        ? null
        : ConstantUtil.parseLocalizedNumber(row.min!);
    final max = row.max == null
        ? null
        : ConstantUtil.parseLocalizedNumber(row.max!);
    final fee = row.fee == null
        ? null
        : ConstantUtil.parseLocalizedNumber(row.fee!);
    if (min == null || max == null || fee == null) {
      return (
        interval: null,
        error: l10n.rowInvalidAmounts(
          row.rowNumber,
          row.min ?? '',
          row.max ?? '',
          row.fee ?? '',
        ),
      );
    }
    if (min < 0 || min >= max) {
      return (
        interval: null,
        error: l10n.rowMinAmountGreaterThanMax(
          row.rowNumber,
          ConstantUtil.formatCurrencyAmount(min),
          ConstantUtil.formatCurrencyAmount(max),
        ),
      );
    }
    final type = parseFeeType(row.feeType);
    if (type == FeeType.percentage && (fee < 0 || fee > 100)) {
      return (
        interval: null,
        error: l10n.rowFeePercentageInvalid(
          row.rowNumber,
          ConstantUtil.formatPercentage(fee),
        ),
      );
    }
    if (fee < 0) {
      return (interval: null, error: l10n.rowFeeMustBePositive(row.rowNumber));
    }
    return (
      interval: FeeInterval(
        minAmount: min * exchangeRate,
        maxAmount: max * exchangeRate,
        fee: type == FeeType.percentage ? fee : fee * exchangeRate,
        feeType: type,
      ),
      error: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Imports providers and fee intervals. Rows are grouped by provider name
  /// (case insensitive); unknown providers are created, intervals are added
  /// to existing ones when they do not overlap.
  static Future<CsvResult> importFromCsv(
    String content,
    CurrencyProvider currencyProvider,
    AppLocalizations l10n, {
    ProviderRepository? providers,
    FeeIntervalRepository? intervals,
  }) async {
    final providerRepository = providers ?? ProviderRepository();
    final intervalRepository = intervals ?? FeeIntervalRepository();
    try {
      if (content.trim().isEmpty) {
        return CsvResult(success: false, message: l10n.csvFileIsEmpty);
      }
      final rows = parseRows(content);
      if (rows == null) {
        return CsvResult(
          success: false,
          message: l10n.providerNameColumnNotFound,
        );
      }
      if (rows.isEmpty) {
        return CsvResult(success: false, message: l10n.noDataRowsFound);
      }

      final errors = <String>[];
      final groups = <String, List<CsvRow>>{};
      for (final row in rows) {
        final name = row.providerName;
        if (name == null) {
          errors.add(l10n.rowProviderNameRequired(row.rowNumber));
          continue;
        }
        groups.putIfAbsent(name.toLowerCase(), () => []).add(row);
      }

      var providersCreated = 0;
      var feesAdded = 0;
      await providerRepository.transaction((txn) async {
        for (final group in groups.values) {
          final name = group.first.providerName!;
          var provider = await providerRepository.findByName(
            name,
            executor: txn,
          );
          final feeRows = group.where((r) => r.hasFeeData).toList();
          if (provider == null) {
            provider = await providerRepository.insert(
              Provider(
                id: '',
                name: name,
                description:
                    group.map((r) => r.description).nonNulls.firstOrNull ?? '',
                iconName:
                    group.map((r) => r.icon).nonNulls.firstOrNull ?? 'business',
              ),
              executor: txn,
            );
            providersCreated++;
          } else if (feeRows.isEmpty) {
            errors.add(
              l10n.rowProviderAlreadyExists(group.first.rowNumber, name),
            );
            continue;
          }

          final existing = await intervalRepository.getByProvider(
            provider.id,
            executor: txn,
          );
          for (final row in feeRows) {
            final parsed = toInterval(row, currencyProvider.exchangeRate, l10n);
            final interval = parsed.interval;
            if (interval == null) {
              errors.add(parsed.error!);
              continue;
            }
            final overlap = existing.where(interval.overlaps).firstOrNull;
            if (overlap != null) {
              errors.add(
                l10n.rowIntervalOverlaps(
                  row.rowNumber,
                  overlap.formattedRangeWithSymbol(
                    currencyProvider.currencySymbol,
                    currencyProvider.exchangeRate,
                  ),
                ),
              );
              continue;
            }
            existing.add(
              await intervalRepository.insert(
                interval,
                provider.id,
                executor: txn,
              ),
            );
            feesAdded++;
          }
        }
      });

      return CsvResult(
        success: providersCreated > 0 || feesAdded > 0,
        message: l10n.importedProvidersAndFees(providersCreated, feesAdded),
        providersCount: providersCreated,
        feeIntervalsCount: feesAdded,
        errors: errors,
      );
    } catch (e) {
      return CsvResult(
        success: false,
        message: l10n.importFailed(e.toString()),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  /// Builds the CSV text of every provider (one row per fee interval).
  static Future<({String csv, int providers, int intervals})> buildExport({
    required String locale,
    required double exchangeRate,
    ProviderRepository? providers,
    FeeIntervalRepository? intervals,
  }) async {
    final providerRepository = providers ?? ProviderRepository();
    final intervalRepository = intervals ?? FeeIntervalRepository();
    final rows = <List<String>>[headers(locale)];
    final all = await providerRepository.getAll();
    var intervalCount = 0;
    for (final provider in all) {
      final base = [provider.name, provider.description, provider.iconName];
      final list = await intervalRepository.getByProvider(provider.id);
      if (list.isEmpty) {
        rows.add([...base, '', '', '', 'fixed']);
        continue;
      }
      for (final interval in list) {
        intervalCount++;
        final fee = interval.fee ?? 0;
        rows.add([
          ...base,
          _number((interval.minAmount ?? 0) / exchangeRate),
          _number((interval.maxAmount ?? 0) / exchangeRate),
          _number(interval.isPercentage ? fee : fee / exchangeRate),
          interval.isPercentage ? 'percentage' : 'fixed',
        ]);
      }
    }
    return (
      csv: const ListToCsvConverter().convert(rows),
      providers: all.length,
      intervals: intervalCount,
    );
  }

  /// Exports every provider into a temporary file.
  static Future<CsvResult> exportToCsv({
    required String locale,
    required CurrencyProvider currencyProvider,
    required AppLocalizations l10n,
  }) async {
    try {
      final export = await buildExport(
        locale: locale,
        exchangeRate: currencyProvider.exchangeRate,
      );
      if (export.providers == 0) {
        return CsvResult(success: false, message: l10n.noDataToExport);
      }
      final path = await writeTemporaryFile(export.csv, 'export');
      return CsvResult(
        success: true,
        providersCount: export.providers,
        feeIntervalsCount: export.intervals,
        filePath: path,
      );
    } catch (e) {
      return CsvResult(
        success: false,
        message: l10n.exportFailed(e.toString()),
      );
    }
  }

  /// Writes [content] (UTF-8 with BOM so spreadsheets detect the encoding).
  static Future<String> writeTemporaryFile(
    String content,
    String prefix,
  ) async {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString('﻿$content', encoding: utf8);
    return file.path;
  }

  static String _number(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 1e-9 * (value.abs() + 1)) {
      return rounded.toStringAsFixed(0);
    }
    return value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static List<String> headers(String locale) => switch (locale) {
    'fr' => const [
      'nom_fournisseur',
      'description',
      'icone',
      'montant_min',
      'montant_max',
      'frais',
      'type_frais',
    ],
    'mg' => const [
      'anarany_mpanome',
      'famaritana',
      'sary',
      'vola_farany_kely',
      'vola_farany_lehibe',
      'sara',
      'karazany_sara',
    ],
    _ => const [
      'provider_name',
      'provider_description',
      'provider_icon',
      'min_amount',
      'max_amount',
      'fee',
      'fee_type',
    ],
  };

  static String getImportTemplate(String locale) =>
      const ListToCsvConverter().convert([
        headers(locale),
        [
          'TELMA',
          'Mobile provider',
          'phone_android',
          '100',
          '5000',
          '100',
          'fixed',
        ],
        ['TELMA', '', '', '5001', '10000', '250', 'fixed'],
        [
          'AIRTEL',
          'Another mobile provider',
          'phone_android',
          '1000',
          '2000',
          '15',
          'fixed',
        ],
        [
          'BANK',
          'Bank transfer provider',
          'account_balance',
          '1',
          '100000',
          '2.5',
          'percentage',
        ],
      ]);
}
