/// Application constants plus number/date parsing and formatting helpers.
class ConstantUtil {
  const ConstantUtil._();

  static const String appName = 'Feezer';

  /// Largest amount accepted in amount fields (in the display currency).
  static const double maxInputAmount = 99999999999;

  /// Largest number of transactions accepted in the constraint fields.
  static const int maxTransactionsInput = 999;

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  /// Parses a number typed by the user: spaces (thousand separators) are
  /// ignored and a comma is accepted as decimal separator.
  static double? parseLocalizedNumber(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[\s  ]'), '')
        .replaceAll(',', '.');
    if (cleaned.isEmpty || '.'.allMatches(cleaned).length > 1) return null;
    final parsed = double.tryParse(cleaned);
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  /// Reads a date stored either as milliseconds since epoch or as an ISO-8601
  /// string (older currency rows); falls back to now.
  static DateTime parseDateTime(Object? value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (value is String) {
      final asInt = int.tryParse(value);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  /// Formats an amount for display: thousands separated by spaces, at most two
  /// decimals for amounts >= 1 (more for smaller amounts), trailing zeros
  /// removed. [decimals] forces a fixed number of decimals.
  static String formatCurrencyAmount(num amount, {int? decimals}) {
    final value = amount.toDouble();
    if (!value.isFinite) return value.toString();
    if (value == 0) {
      return decimals != null && decimals > 0 ? '0.${'0' * decimals}' : '0';
    }

    final negative = value < 0;
    final abs = value.abs();
    String text;
    if (decimals != null) {
      text = abs.toStringAsFixed(decimals);
    } else if (abs >= 1) {
      text = _trimZeros(abs.toStringAsFixed(2));
    } else if (abs >= 1e-6) {
      text = _trimZeros(abs.toStringAsFixed(10));
    } else {
      return value.toStringAsExponential(4);
    }
    final formatted = _groupThousands(text);
    return negative && formatted != '0' ? '-$formatted' : formatted;
  }

  /// Formats a percentage (up to 4 significant decimals, no trailing zeros).
  static String formatPercentage(num value) =>
      _trimZeros(value.toDouble().toStringAsFixed(4));

  /// Text used to prefill an amount field (spaces as thousand separators, no
  /// rounding beyond the precision of the value).
  static String formatAmountInput(double value) {
    if (!value.isFinite) return '';
    final rounded = value.roundToDouble();
    final text = (value - rounded).abs() < 1e-9 * (value.abs() + 1)
        ? rounded.toStringAsFixed(0)
        : _trimZeros(value.toStringAsFixed(6));
    return _groupThousands(text);
  }

  static String _trimZeros(String text) {
    if (!text.contains('.')) return text;
    final trimmed = text.replaceFirst(RegExp(r'0+$'), '');
    return trimmed.endsWith('.')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  /// Inserts a space every three digits of the integer part.
  static String groupThousands(String digits) => _groupThousands(digits);

  static String _groupThousands(String text) {
    final dot = text.indexOf('.');
    final integer = dot < 0 ? text : text.substring(0, dot);
    final fraction = dot < 0 ? '' : text.substring(dot);
    final buffer = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(integer[i]);
    }
    return '$buffer$fraction';
  }
}
