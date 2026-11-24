import 'dart:convert';

import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:fee_minimizer/model/fee_interval_model.dart';
import 'package:fee_minimizer/util/csv_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('parsing', () {
    test('comma separated file with CRLF and BOM', () {
      final rows = CsvUtil.parseRows(
        '﻿provider_name,min_amount,max_amount,fee,fee_type\r\n'
        'YAS,100,1000,100,fixed\r\n'
        '\r\n'
        'BANK,1,1000,2.5,percentage\r\n',
      )!;
      expect(rows, hasLength(2));
      expect(rows.first.providerName, 'YAS');
      expect(rows.first.rowNumber, 2);
      expect(rows.last.feeType, 'percentage');
    });

    test('semicolon separated file (French spreadsheets)', () {
      final rows = CsvUtil.parseRows(
        'nom_fournisseur;montant_min;montant_max;frais\nORANGE;200;1000;100\n',
      )!;
      expect(rows.single.min, '200');
      expect(rows.single.fee, '100');
    });

    test('Malagasy export headers are read back', () {
      final header = CsvUtil.headers('mg').join(',');
      final rows = CsvUtil.parseRows('$header\nX,,,1,10,5,percentage\n')!;
      expect(CsvUtil.parseFeeType(rows.single.feeType), FeeType.percentage);
    });

    test('missing provider column', () {
      expect(CsvUtil.parseRows('foo,bar\n1,2\n'), isNull);
    });

    test('UTF-8 accents are decoded, Latin-1 is a fallback', () {
      expect(CsvUtil.decodeBytes(utf8.encode('opérateur')), 'opérateur');
      expect(CsvUtil.decodeBytes(latin1.encode('télécom')), 'télécom');
    });
  });

  group('interval conversion', () {
    CsvRow row({String? min, String? max, String? fee, String? type}) => CsvRow(
      rowNumber: 3,
      providerName: 'P',
      min: min,
      max: max,
      fee: fee,
      feeType: type,
    );

    test('amounts are read as is, comma decimals accepted', () {
      final fixed = CsvUtil.toInterval(
        row(min: '1', max: '10 000', fee: '0,5'),
        l10n,
      ).interval!;
      expect(fixed.minAmount, 1);
      expect(fixed.maxAmount, 10000);
      expect(fixed.fee, 0.5);

      final percentage = CsvUtil.toInterval(
        row(min: '1', max: '10', fee: '2.5', type: '%'),
        l10n,
      ).interval!;
      expect(percentage.fee, 2.5);
      expect(percentage.feeType, FeeType.percentage);
    });

    test('validation errors are localized', () {
      expect(
        CsvUtil.toInterval(row(min: 'x', max: '10', fee: '1'), l10n).error,
        contains('Row 3'),
      );
      expect(
        CsvUtil.toInterval(row(min: '10', max: '5', fee: '1'), l10n).error,
        contains('Row 3'),
      );
      expect(
        CsvUtil.toInterval(
          row(min: '1', max: '5', fee: '150', type: 'percentage'),
          l10n,
        ).error,
        contains('Row 3'),
      );
    });
  });

  test('template parses back', () {
    for (final locale in ['en', 'fr', 'mg']) {
      final rows = CsvUtil.parseRows(CsvUtil.getImportTemplate(locale))!;
      expect(rows, hasLength(4));
      for (final r in rows) {
        expect(CsvUtil.toInterval(r, l10n).interval, isNotNull);
      }
    }
  });
}
