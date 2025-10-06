import 'package:flutter/material.dart';
import '../util/theme_util.dart';
import '../util/extensions.dart';
import '../styles/global.dart';

/// Reusable counter widget with increment/decrement buttons
class CounterWidget extends StatelessWidget {
  const CounterWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999999,
    this.step = 1,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      borderRadius: Global.borderMd,
      border: Border.all(color: context.colorScheme.outlineVariant),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          context,
          Icons.remove,
          () => _decrement(),
          enabled: value > min,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 80),
          padding: Global.padHorizontalMd,
          child: Text(
            value.toString(),
            style: ThemeUtil.titleLarge.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        _buildButton(
          context,
          Icons.add,
          () => _increment(),
          enabled: value < max,
        ),
      ],
    ),
  );

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    {required bool enabled}
  ) => IconButton(
    onPressed: enabled ? onPressed : null,
    icon: Icon(icon),
    style: IconButton.styleFrom(
      foregroundColor: enabled 
        ? context.colorScheme.primary 
        : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      padding: Global.padMd,
    ),
  );

  void _increment() {
    if (value < max) onChanged(value + step);
  }

  void _decrement() {
    if (value > min) onChanged(value - step);
  }
}