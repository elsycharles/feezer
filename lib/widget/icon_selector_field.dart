import 'package:flutter/material.dart';
import '../util/icon_util.dart';
import '../util/theme_util.dart';
import 'icon_picker.dart';

/// Reusable icon selector field
class IconSelectorField extends StatelessWidget {
  const IconSelectorField({
    super.key,
    required this.selectedIcon,
    required this.onChanged,
    this.label = 'Icon',
  });

  final String selectedIcon;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeUtil.bodyLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showIconPicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surface,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    IconUtil.getIcon(selectedIcon),
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap to select icon',
                    style: ThemeUtil.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showIconPicker(BuildContext context) => IconPicker.show(
    context: context,
    selected: selectedIcon,
    onSelected: onChanged,
  );
}