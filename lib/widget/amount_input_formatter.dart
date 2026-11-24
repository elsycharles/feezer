import 'package:flutter/services.dart';

import '../util/constant_util.dart';

/// Formats amount fields while typing: digits grouped by thousands with
/// spaces, a single decimal separator (`.` or `,` typed, shown as
/// [decimalSeparator]) and an optional maximum value.
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter({
    this.max,
    this.maxDecimals = 2,
    this.decimalSeparator = ',',
  });

  final double? max;
  final int maxDecimals;
  final String decimalSeparator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '.');
    final buffer = StringBuffer();
    var hasDot = false;
    var decimals = 0;
    // Number of kept characters (digits and dot) before the cursor.
    var keptBeforeCursor = 0;
    final cursor = newValue.selection.baseOffset.clamp(0, raw.length);
    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      final code = char.codeUnitAt(0);
      final isDigit = code >= 0x30 && code <= 0x39;
      var keep = false;
      if (isDigit) {
        if (!hasDot || decimals < maxDecimals) {
          keep = true;
          if (hasDot) decimals++;
        }
      } else if (char == '.' && !hasDot) {
        hasDot = true;
        keep = true;
      }
      if (keep) {
        buffer.write(char);
        if (i < cursor) keptBeforeCursor++;
      }
    }

    var cleaned = buffer.toString();
    if (cleaned.startsWith('.')) {
      cleaned = '0$cleaned';
      keptBeforeCursor++;
    }
    if (cleaned.isEmpty) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final value = double.tryParse(cleaned);
    if (max != null && value != null && value > max!) return oldValue;

    final formatted = ConstantUtil.groupThousands(
      cleaned,
    ).replaceFirst('.', decimalSeparator);
    // Place the cursor after the same number of kept characters.
    var offset = 0;
    var seen = 0;
    while (offset < formatted.length && seen < keptBeforeCursor) {
      if (formatted[offset] != ' ') seen++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
