import 'package:flutter/material.dart';

import '../../../styles/global.dart';
import '../../../util/constant_util.dart';
import '../../../util/theme_util.dart';
import '../../../widget/amount_input_formatter.dart';

/// Large amount field. [value] is expressed in the display currency; every
/// edit is reported, including an empty field (0), so the screen state always
/// matches what the user sees.
class AmountInputWidget extends StatefulWidget {
  const AmountInputWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.currencySymbol,
    this.max = ConstantUtil.maxInputAmount,
    this.label = 'Amount',
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String currencySymbol;
  final double max;
  final String label;

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.value),
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AmountInputWidget old) {
    super.didUpdateWidget(old);
    // External change (currency switch...): refresh the text unless the user
    // is editing it.
    if (!_focusNode.hasFocus) {
      final current = ConstantUtil.parseLocalizedNumber(_controller.text) ?? 0;
      if ((current - widget.value).abs() > 1e-9 * (widget.value.abs() + 1)) {
        _controller.text = _format(widget.value);
      }
    }
  }

  static String _format(double value) =>
      value > 0 ? ConstantUtil.formatAmountInput(value) : '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final focused = _focusNode.hasFocus;
    return Container(
      decoration: BoxDecoration(
        color: focused
            ? colorScheme.primary.withValues(alpha: 0.05)
            : colorScheme.surface,
        borderRadius: Global.borderMd,
        border: Border.all(
          color: focused
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.12),
          width: focused ? 1.5 : 0.8,
        ),
      ),
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: ThemeUtil.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  widget.currencySymbol,
                  style: ThemeUtil.labelMedium.copyWith(
                    color: colorScheme.primary,
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [AmountInputFormatter(max: widget.max)],
                style: ThemeUtil.titleLarge.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (text) => widget.onChanged(
                  ConstantUtil.parseLocalizedNumber(text) ?? 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
