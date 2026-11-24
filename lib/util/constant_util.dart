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
