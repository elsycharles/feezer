import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../styles/global.dart';
import '../../../util/theme_util.dart';

/// Integer field for the minimum / maximum number of transactions
/// (empty means 0, i.e. no constraint). Values above [max] cannot be typed.
class TransactionInputWidget extends StatefulWidget {
  const TransactionInputWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.max = 999,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int max;

  @override
  State<TransactionInputWidget> createState() => _TransactionInputWidgetState();
}

class _TransactionInputWidgetState extends State<TransactionInputWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.value),
  );
  final FocusNode _focusNode = FocusNode();

  static String _format(int value) => value == 0 ? '' : '$value';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(TransactionInputWidget old) {
    super.didUpdateWidget(old);
    if (!_focusNode.hasFocus && _controller.text != _format(widget.value)) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final focused = _focusNode.hasFocus;
    return Container(
      decoration: BoxDecoration(
        color: focused
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: Global.borderMd,
        border: Border.all(
          color: focused
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.12),
          width: focused ? 1.5 : 0.8,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: ThemeUtil.labelMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              TextInputFormatter.withFunction(
                (oldValue, newValue) =>
                    (int.tryParse(newValue.text) ?? 0) > widget.max
                    ? oldValue
                    : newValue,
              ),
            ],
            style: ThemeUtil.titleMedium.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              hintText: '0',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            onChanged: (text) => widget.onChanged(int.tryParse(text) ?? 0),
          ),
        ],
      ),
    );
  }
}
