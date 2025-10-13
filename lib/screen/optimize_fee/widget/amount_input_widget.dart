import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../util/theme_util.dart';
import '../../../styles/global.dart';
import '../../../provider/currency_provider.dart';
import '../../../util/constant_util.dart';

class AmountInputWidget extends StatefulWidget {
  const AmountInputWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 999999.0,
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

  @override
  void initState() {
    super.initState();
    // Initialize with formatted value to avoid showing .0 for integers
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode = FocusNode();
    // Add focus listeners to manage typing state
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
      // Quand le focus est perdu, formater proprement la valeur
      _isUserTyping = false;
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void didUpdateWidget(AmountInputWidget old) {
    super.didUpdateWidget(old);
    // Do not update if user has focus OR is typing
    if (old.value != widget.value && !_isUserTyping && !_focusNode.hasFocus) {
      _controller.text = _formatValue(widget.value);
    }
  }

  // New method to format value
  String _formatValue(double value) {
    // Si c'est un nombre entier, on n'affiche pas le .0
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                LengthLimitingTextInputFormatter(11),
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
    final doubleValue = ConstantUtil.parseLocalizedNumber(value);
    if (doubleValue != null &&
        doubleValue >= widget.min &&
        doubleValue <= widget.max) {
      widget.onChanged(doubleValue);
    } else if (value.isEmpty) {
      widget.onChanged(widget.min);
    }
    // No need to reset to false here, let onFocusChanged handle it
  }
}
