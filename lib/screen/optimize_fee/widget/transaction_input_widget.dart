import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../util/theme_util.dart';
import '../../../styles/global.dart';

class TransactionInputWidget extends StatefulWidget {
  const TransactionInputWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999999,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min, max;

  @override
  State<TransactionInputWidget> createState() => _TransactionInputWidgetState();
}

class _TransactionInputWidgetState extends State<TransactionInputWidget> {
  late final TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TransactionInputWidget old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _focusNode.hasFocus
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : Theme.of(context).colorScheme.surface,
        borderRadius: Global.borderMd,
        border: Border.all(
          color: _focusNode.hasFocus
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          width: _focusNode.hasFocus ? 1.5 : 0.8,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ) ?? ThemeUtil.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              LengthLimitingTextInputFormatter(7),
            ],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ) ?? ThemeUtil.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: false,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null &&
                  intValue >= widget.min &&
                  intValue <= widget.max) {
                widget.onChanged(intValue);
              } else if (value.isEmpty) {
                widget.onChanged(widget.min);
              }
            },
          ),
        ],
      ),
    );
  }
}
