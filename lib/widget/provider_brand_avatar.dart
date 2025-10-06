import 'package:flutter/material.dart';
import '../util/icon_util.dart';

/// Gradient avatar used for provider visuals across screens
class ProviderBrandAvatar extends StatelessWidget {
  const ProviderBrandAvatar({
    super.key,
    required this.iconName,
    this.size = 56,
  });

  final String iconName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final highlight = Color.alphaBlend(
      colorScheme.surface.withValues(alpha: 0.08),
      primary,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, highlight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: size * 0.15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        IconUtil.getIcon(iconName),
        color: colorScheme.onPrimary,
        size: size * 0.45,
      ),
    );
  }
}
