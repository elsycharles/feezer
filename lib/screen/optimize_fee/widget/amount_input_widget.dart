import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../util/theme_util.dart';
import '../../../styles/global.dart';

class AmountInputWidget extends StatefulWidget {
  const AmountInputWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999999,
    this.step = 1,
    this.label = 'Amount',
    this.currency = 'Ar',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min, max, step;
  final String label, currency;

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  late final TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _repeatTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AmountInputWidget old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _controller.text = widget.value.toString();
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
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ) ?? ThemeUtil.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                widget.currency,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ) ?? ThemeUtil.labelMedium.copyWith(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildRepeatButton(
                  Icons.remove,
                  widget.value > widget.min,
                  isIncrement: false,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11)
                    ],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ) ?? ThemeUtil.titleLarge.copyWith(
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
                _buildRepeatButton(
                  Icons.add,
                  widget.value < widget.max,
                  isIncrement: true,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildRepeatButton(
    IconData icon,
    bool enabled, {
    required bool isIncrement,
  }) {
    final Color fg = enabled
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final Color bg = enabled
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
        : Theme.of(context).colorScheme.surface;

    void tapOnce() {
      if (!enabled) return;
      isIncrement ? _increment() : _decrement();
    }

    void startRepeat() {
      if (!enabled) return;
      _repeatTimer?.cancel();
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 70), (_) {
        isIncrement ? _increment() : _decrement();
      });
    }

    void stopRepeat() {
      _repeatTimer?.cancel();
      _repeatTimer = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onLongPressStart: (_) => startRepeat(),
        onLongPressEnd: (_) => stopRepeat(),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: tapOnce,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 18, color: fg),
            ),
          ),
        ),
      ),
    );
  }

  int _clamp(int v) => v.clamp(widget.min, widget.max);
  void _increment() => widget.onChanged(_clamp(widget.value + widget.step));
  void _decrement() => widget.onChanged(_clamp(widget.value - widget.step));
  void _onTextChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null && intValue >= widget.min && intValue <= widget.max) {
      widget.onChanged(intValue);
    } else if (value.isEmpty) {
      widget.onChanged(widget.min);
    }
  }
}
