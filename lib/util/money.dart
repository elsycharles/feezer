import 'package:flutter/widgets.dart';

/// Formats amounts as money, without currency: `10 050`, `1 234,50`.
///
/// Thousands are grouped with a no-break space (amounts never wrap), and two
/// decimals are shown only when the amount is not a whole number.
abstract final class Money {
  static const String groupSeparator = ' ';

  /// Decimal separator of [locale] (comma for French and Malagasy).
  static String decimalSeparatorOf(Locale locale) =>
      locale.languageCode == 'en' ? '.' : ',';

  static String format(num value, {String decimalSeparator = ','}) {
    final v = value.toDouble();
    if (!v.isFinite) return '—';
    final negative = v < 0;
    final abs = v.abs();
    final rounded = abs.roundToDouble();
    final whole = (abs - rounded).abs() < 0.005;
    final fixed = whole ? rounded.toStringAsFixed(0) : abs.toStringAsFixed(2);
    final dot = fixed.indexOf('.');
    final integer = dot < 0 ? fixed : fixed.substring(0, dot);
    final buffer = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buffer.write(groupSeparator);
      buffer.write(integer[i]);
    }
    if (dot >= 0) {
      buffer
        ..write(decimalSeparator)
        ..write(fixed.substring(dot + 1));
    }
    final text = buffer.toString();
    return negative && text != '0' ? '-$text' : text;
  }

  /// Percentage without useless zeros: `2`, `2,5`, `0,125`.
  static String percent(num value, {String decimalSeparator = ','}) {
    var text = value.toDouble().toStringAsFixed(4);
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return '${text.replaceAll('.', decimalSeparator)} %';
  }
}

extension MoneyContext on BuildContext {
  String get _decimal => Money.decimalSeparatorOf(Localizations.localeOf(this));

  /// Amount formatted for the current language.
  String money(num value) => Money.format(value, decimalSeparator: _decimal);

  /// Percentage formatted for the current language.
  String percent(num value) => Money.percent(value, decimalSeparator: _decimal);
}
