import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Generic selectable tile widget with consistent interaction patterns
/// Can be used as a base for various list items that support selection
class SelectableTile extends StatelessWidget {
  const SelectableTile({
    super.key,
    required this.child,
    required this.isSelected,
    required this.showSelection,
    required this.onSelectionChanged,
    required this.onLongPress,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.selectionIndicatorColor,
  });

  final Widget child;
  final bool isSelected;
  final bool showSelection;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final Color? selectionIndicatorColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          if (showSelection) {
            onSelectionChanged(!isSelected);
          } else {
            onTap?.call();
          }
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (selectionIndicatorColor ?? colorScheme.primary).withValues(
                    alpha: 0.12,
                  )
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (selectionIndicatorColor ?? colorScheme.primary)
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (showSelection)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Checkbox(
                      key: ValueKey(isSelected),
                      value: isSelected,
                      onChanged: (value) => onSelectionChanged(value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
