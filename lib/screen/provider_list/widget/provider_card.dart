import 'package:flutter/material.dart';
import '../../../model/provider_model.dart';
import '../../../util/theme_util.dart';
import '../../../util/icon_util.dart';
import '../../../styles/global.dart';
import '../../../widget/interactive_surface.dart';

/// Reusable provider card widget for consistent styling
class ProviderCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;
  final bool showDescription;
  final Widget? trailing;

  const ProviderCard({
    super.key,
    required this.provider,
    this.onTap,
    this.onLongPress,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.showDescription = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      onLongPress: onLongPress,
      builder: (context, hovered, pressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _backgroundColor(colorScheme, hovered, pressed),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(colorScheme),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: hovered || pressed ? 0.16 : 0.08,
              ),
              blurRadius: hovered || pressed ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showCheckbox) ...[
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onSelectionChanged != null
                      ? (value) => onSelectionChanged!(value ?? false)
                      : null,
                  visualDensity: VisualDensity.compact,
                  activeColor: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            _buildIcon(colorScheme),
            Global.gapMd,
            Expanded(child: _buildContent(colorScheme)),
            if (trailing != null) ...[Global.gapSm, trailing!],
          ],
        ),
      ),
    );
  }

  Color _backgroundColor(ColorScheme colorScheme, bool hovered, bool pressed) {
    final base = isSelected
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colorScheme.surface;
    return ThemeUtil.interactiveSurfaceColor(
      base,
      hovered: hovered,
      pressed: pressed,
      overlayColor: colorScheme.primary,
    );
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    if (isSelected) return colorScheme.primary;
    return colorScheme.outlineVariant;
  }

  Widget _buildIcon(ColorScheme colorScheme) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: colorScheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Icon(
        IconUtil.getIcon(provider.iconName),
        color: colorScheme.primary,
        size: 24,
      ),
    ),
  );

  Widget _buildContent(ColorScheme colorScheme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        provider.name,
        style: ThemeUtil.titleSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      if (showDescription && provider.description.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          provider.description,
          style: ThemeUtil.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ],
  );
}
