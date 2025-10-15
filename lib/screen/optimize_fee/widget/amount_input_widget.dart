import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../util/theme_util.dart';
import '../../../styles/global.dart';
import '../../../provider/currency_provider.dart';
import '../../../util/constant_util.dart';

// Custom formatter with limit checking
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final double max;
  
  ThousandsSeparatorInputFormatter({required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the text is empty, return it as-is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all existing spaces
    String digitsOnly = newValue.text.replaceAll(' ', '');

    // Ensure the string is a valid number
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(digitsOnly)) {
      return oldValue;
    }

    // Check if the value exceeds the limit
    final numericValue = double.tryParse(digitsOnly);
    if (numericValue != null && numericValue > max) {
      // If we're trying to add characters (new text longer), block the change
      if (newValue.text.replaceAll(' ', '').length > oldValue.text.replaceAll(' ', '').length) {
        return oldValue; // Return the previous value to block the input
      }
      // Sinon (suppression), permettre la modification
    }

  // Split integer and decimal parts
    List<String> parts = digitsOnly.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

  // Format the integer part with spaces
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = ' $formatted';
      }
      formatted = integerPart[i] + formatted;
      count++;
    }

    // Append the decimal part if it exists
    if (decimalPart.isNotEmpty) {
      formatted += '.$decimalPart';
    } else if (digitsOnly.endsWith('.')) {
      formatted += '.';
    }

  // Compute the new cursor position
    int originalCursorPos = newValue.selection.baseOffset;
    int spacesBeforeCursor = newValue.text.substring(0, originalCursorPos).split(' ').length - 1;
    int digitsBeforeCursor = originalCursorPos - spacesBeforeCursor;
    
  // Count spaces in the formatted text up to the cursor position
    int newSpacesBeforeCursor = 0;
    int digitCount = 0;
    for (int i = 0; i < formatted.length && digitCount < digitsBeforeCursor; i++) {
      if (formatted[i] == ' ') {
        newSpacesBeforeCursor++;
      } else if (formatted[i] != '.') {
        digitCount++;
      } else if (formatted[i] == '.') {
        digitCount++;
      }
    }
    
    int newCursorPos = digitsBeforeCursor + newSpacesBeforeCursor;
    newCursorPos = newCursorPos.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

class AmountInputWidget extends StatefulWidget {
  const AmountInputWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 99999999999.0,
    this.label = 'Amount',
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min, max;
  final String label;

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  late final TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isUserTyping = false;
  String _lastValidText = '';

  @override
  void initState() {
    super.initState();
    _lastValidText = _formatValue(widget.value);
    _controller = TextEditingController(text: _lastValidText);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _isUserTyping = false;
      // NOTE: Do not reformat from widget.value
      // The text in _controller is already correctly formatted
    }
  }

  @override
  void didUpdateWidget(AmountInputWidget old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_isUserTyping && !_focusNode.hasFocus) {
      _lastValidText = _formatValue(widget.value);
      _controller.text = _lastValidText;
    }
  }

  String _formatValue(double value) {
    // For very large numbers (> 1e15), use a more precise representation
    String valueStr;
    
    if (value.abs() > 1e15) {
      // Use toStringAsFixed(0) for very large integers
      if (value == value.toInt()) {
        valueStr = value.toInt().toString();
      } else {
        // For very large decimals, preserve precision
        valueStr = value.toStringAsFixed(0);
      }
    } else if (value == value.toInt()) {
      // For normal integers
      valueStr = value.toInt().toString();
    } else {
      // For decimals - keep significant decimal digits
      String tempStr = value.toString();
      if (tempStr.contains('.')) {
        List<String> parts = tempStr.split('.');
        String decimalPart = parts[1].replaceAll(RegExp(r'0+$'), '');
        if (decimalPart.isEmpty) {
          valueStr = parts[0];
        } else {
          valueStr = '${parts[0]}.$decimalPart';
        }
      } else {
        valueStr = tempStr;
      }
    }
    
    // Split integer and decimal parts
    List<String> parts = valueStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Format the integer part with spaces
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = ' $formatted';
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    // Append the decimal part if it exists
    if (decimalPart.isNotEmpty) {
      formatted += '.$decimalPart';
    }
    
    return formatted;
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _focusNode.hasFocus
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
          : Theme.of(context).colorScheme.surface,
      borderRadius: Global.borderMd,
      border: Border.all(
        color: _focusNode.hasFocus
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        width: _focusNode.hasFocus ? 1.5 : 0.8,
      ),
    ),
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: ThemeUtil.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                context.read<CurrencyProvider>().currencySymbol,
                style: ThemeUtil.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 56,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.]')),
                ThousandsSeparatorInputFormatter(max: widget.max),
                LengthLimitingTextInputFormatter(30), // Increased for large numbers
              ],
              style: ThemeUtil.titleLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: false,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _onTextChanged,
            ),
          ),
        ),
      ],
    ),
  );

  void _onTextChanged(String value) {
    _isUserTyping = true;
    
  // Remove spaces for conversion
    String cleanValue = value.replaceAll(' ', '');
    
    final decimalValue = ConstantUtil.parseLocalizedNumber(cleanValue);
    if (decimalValue != null) {
      final doubleValue = decimalValue.toDouble();
      if (doubleValue >= widget.min && doubleValue <= widget.max) {
  // Save the current text as the last valid text
        _lastValidText = value;
        widget.onChanged(doubleValue);
      }
    } else if (cleanValue.isEmpty) {
      widget.onChanged(widget.min);
    }
  }
}
