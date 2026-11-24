import 'dart:convert';
import 'package:csv/csv.dart';

import '../data/fee_interval_repository.dart';
import '../data/provider_repository.dart';
import '../l10n/app_localizations.dart';
import '../model/fee_interval_model.dart';
import '../model/fee_operation.dart';
import '../model/provider_model.dart';
import 'constant_util.dart';
import 'money.dart';

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
  static const operation = [
    'operation',
    'type_operation',
    'karazana_fifanakalozana',
  ];
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
    this.operation,
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

  /// Operation key (`withdrawal`, `transfer_same`...), optional.
  final String? operation;

  bool get hasFeeData => min != null || max != null || fee != null;
}

/// CSV import/export of providers and their fee intervals.
///
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
    final operation = indexOf(_Columns.operation);

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
          operation: cell(row, operation),
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

  /// Validates a fee row and converts it to an interval, or returns the
  /// localized error.
  static ({FeeInterval? interval, String? error}) toInterval(
    CsvRow row,
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
          Money.format(min),
          Money.format(max),
        ),
      );
    }
    final type = parseFeeType(row.feeType);
    if (type == FeeType.percentage && (fee < 0 || fee > 100)) {
      return (
        interval: null,
        error: l10n.rowFeePercentageInvalid(row.rowNumber, Money.percent(fee)),
      );
    }
    if (fee < 0) {
      return (interval: null, error: l10n.rowFeeMustBePositive(row.rowNumber));
    }
    return (
      interval: FeeInterval(
        minAmount: min,
        maxAmount: max,
        fee: fee,
        feeType: type,
      ),
      error: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Imports fee grids. Rows are grouped by operator name (case insensitive)
  /// and operation; unknown grids are created, tiers are added to existing
  /// grids when they do not overlap (a downloaded grid is then marked edited).
  static Future<CsvResult> importFromCsv(
    String content,
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
        final key =
            '${name.toLowerCase()}|${FeeOperation.fromKey(row.operation)?.key}';
        groups.putIfAbsent(key, () => []).add(row);
      }

      var providersCreated = 0;
      var feesAdded = 0;
      await providerRepository.transaction((txn) async {
        for (final group in groups.values) {
          final name = group.first.providerName!;
          final operation = FeeOperation.fromKey(group.first.operation);
          var provider = await providerRepository.findByName(
            name,
            operation: operation,
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
                operation: operation,
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

          final grid = provider;
          // A downloaded grid that receives tiers is no longer the published one.
          var markEdited =
              grid.isPublished && grid.sourceType != Provider.editedSource;
          final existing = await intervalRepository.getByProvider(
            grid.id,
            executor: txn,
          );
          for (final row in feeRows) {
            final parsed = toInterval(row, l10n);
            final interval = parsed.interval;
            if (interval == null) {
              errors.add(parsed.error!);
              continue;
            }
            final overlap = existing.where(interval.overlaps).firstOrNull;
            if (overlap != null) {
              errors.add(
                l10n.rowIntervalOverlaps(row.rowNumber, overlap.formattedRange),
              );
              continue;
            }
            existing.add(
              await intervalRepository.insert(interval, grid.id, executor: txn),
            );
            feesAdded++;
            if (markEdited) {
              await providerRepository.markEdited(grid.id, executor: txn);
              markEdited = false;
            }
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
      final operation = provider.operation?.key ?? '';
      final list = await intervalRepository.getByProvider(provider.id);
      if (list.isEmpty) {
        rows.add([...base, '', '', '', 'fixed', operation]);
        continue;
      }
      for (final interval in list) {
        intervalCount++;
        final fee = interval.fee ?? 0;
        rows.add([
          ...base,
          _number(interval.minAmount ?? 0),
          _number(interval.maxAmount ?? 0),
          _number(fee),
          interval.isPercentage ? 'percentage' : 'fixed',
          operation,
        ]);
      }
    }
    return (
      csv: const ListToCsvConverter().convert(rows),
      providers: all.length,
      intervals: intervalCount,
    );
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
      'type_operation',
    ],
    'mg' => const [
      'anarany_mpanome',
      'famaritana',
      'sary',
      'vola_farany_kely',
      'vola_farany_lehibe',
      'sara',
      'karazany_sara',
      'karazana_fifanakalozana',
    ],
    _ => const [
      'provider_name',
      'provider_description',
      'provider_icon',
      'min_amount',
      'max_amount',
      'fee',
      'fee_type',
      'operation',
    ],
  };

  static String getImportTemplate(String locale) =>
      const ListToCsvConverter().convert([
        headers(locale),
        [
          'MVola',
          'Mobile money',
          'phone_android',
          '100',
          '1000',
          '100',
          'fixed',
          'withdrawal',
        ],
        ['MVola', '', '', '1001', '5000', '150', 'fixed', 'withdrawal'],
        ['MVola', '', '', '100', '5000', '70', 'fixed', 'transfer_same'],
        [
          'BANK',
          'Bank transfer',
          'account_balance',
          '1',
          '100000',
          '2.5',
          'percentage',
          '',
        ],
      ]);
}
