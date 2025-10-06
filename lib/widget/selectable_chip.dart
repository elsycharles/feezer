import 'package:flutter/material.dart';
import '../util/theme_util.dart';
import '../util/extensions.dart';
import '../styles/global.dart';

/// Selectable chip widget for min/max ranges
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected 
          ? context.colorScheme.primary 
          : context.colorScheme.surface,
        borderRadius: Global.borderMd,
        border: Border.all(
          color: isSelected 
            ? context.colorScheme.primary 
            : context.colorScheme.outlineVariant,
        ),
        boxShadow: isSelected ? Global.shadowSm : null,
      ),
      child: Text(
        label,
        style: ThemeUtil.titleMedium.copyWith(
          color: isSelected 
            ? context.colorScheme.onPrimary 
            : context.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}