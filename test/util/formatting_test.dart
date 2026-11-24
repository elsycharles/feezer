import 'package:fee_minimizer/util/constant_util.dart';
import 'package:fee_minimizer/widget/amount_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCurrencyAmount', () {
    test('groups thousands and trims zeros', () {
      expect(ConstantUtil.formatCurrencyAmount(1234567), '1 234 567');
      expect(ConstantUtil.formatCurrencyAmount(1234.5), '1 234.5');
      expect(ConstantUtil.formatCurrencyAmount(1234.567), '1 234.57');
      expect(ConstantUtil.formatCurrencyAmount(0), '0');
      expect(ConstantUtil.formatCurrencyAmount(0.0123), '0.0123');
    });

    test('negative amounts', () {
      expect(ConstantUtil.formatCurrencyAmount(-123), '-123');
      expect(ConstantUtil.formatCurrencyAmount(-1234), '-1 234');
    });

    test('fixed decimals', () {
      expect(ConstantUtil.formatCurrencyAmount(12, decimals: 2), '12.00');
    });
  });

  group('parseLocalizedNumber', () {
    test('accepts spaces and comma decimals', () {
      expect(ConstantUtil.parseLocalizedNumber('1 234,5'), 1234.5);
      expect(ConstantUtil.parseLocalizedNumber('10.25'), 10.25);
      expect(ConstantUtil.parseLocalizedNumber(''), isNull);
      expect(ConstantUtil.parseLocalizedNumber('1.2.3'), isNull);
      expect(ConstantUtil.parseLocalizedNumber('abc'), isNull);
    });
  });

  test('parseDateTime accepts millis and ISO strings', () {
    expect(
      ConstantUtil.parseDateTime(0),
      DateTime.fromMillisecondsSinceEpoch(0),
    );
    expect(
      ConstantUtil.parseDateTime('2025-01-02T03:04:05.000'),
      DateTime(2025, 1, 2, 3, 4, 5),
    );
  });

  test('formatAmountInput', () {
    expect(ConstantUtil.formatAmountInput(10000), '10 000');
    expect(ConstantUtil.formatAmountInput(0.1 + 0.2), '0.3');
  });

  group('AmountInputFormatter', () {
    TextEditingValue type(String text, {double? max}) =>
        AmountInputFormatter(max: max).formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
        );

    test('groups digits and keeps the cursor at the end', () {
      final value = type('1234567');
      expect(value.text, '1 234 567');
      expect(value.selection.baseOffset, value.text.length);
    });

    test('comma is a decimal separator and only one is kept', () {
      expect(type('12,5').text, '12.5');
      expect(type('1.2.3').text, '1.23');
      expect(type(',5').text, '0.5');
    });

    test('max is enforced', () {
      expect(type('101', max: 100).text, '');
    });
  });
}
