import 'package:flutter/material.dart';
import '../model/provider_model.dart';
import '../util/theme_util.dart';
import '../util/icon_util.dart';
import '../styles/global.dart';
import 'interactive_surface.dart';

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
  Widget build(BuildContext context) => InteractiveSurface(
    onTap: onTap,
    onLongPress: onLongPress,
    builder: (context, hovered, pressed) => AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor(hovered, pressed),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(), width: isSelected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: ThemeUtil.textSecondary.withValues(
              alpha: hovered || pressed ? 0.12 : 0.08,
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
              ),
            ),
            const SizedBox(width: 8),
          ],
          _buildIcon(),
          Global.gapMd,
          Expanded(child: _buildContent()),
          if (trailing != null) ...[Global.gapSm, trailing!],
        ],
      ),
    ),
  );

  Color _backgroundColor(bool hovered, bool pressed) {
    final base = isSelected
        ? ThemeUtil.primaryColor.withValues(alpha: 0.08)
        : ThemeUtil.surfaceLight;
    return ThemeUtil.interactiveSurfaceColor(
      base,
      hovered: hovered,
      pressed: pressed,
    );
  }

  Color _getBorderColor() {
    if (isSelected) return ThemeUtil.primaryColor;
    return ThemeUtil.textSecondary.withValues(alpha: 0.2);
  }

  Widget _buildIcon() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: ThemeUtil.primaryColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Icon(
        IconUtil.getIcon(provider.iconName),
        color: ThemeUtil.primaryColor,
        size: 24,
      ),
    ),
  );

  Widget _buildContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        provider.name,
        style: ThemeUtil.titleSmall.copyWith(fontWeight: FontWeight.w600),
      ),
      if (showDescription && provider.description.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          provider.description,
          style: ThemeUtil.bodySmall.copyWith(color: ThemeUtil.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ],
  );
}
