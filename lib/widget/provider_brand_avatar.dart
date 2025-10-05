import 'package:flutter/material.dart';
import '../util/icon_util.dart';
import '../util/theme_util.dart';

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
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ThemeUtil.primaryColor,
          ThemeUtil.primaryColor.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(size * 0.3),
      boxShadow: [
        BoxShadow(
          color: ThemeUtil.primaryColor.withValues(alpha: 0.3),
          blurRadius: size * 0.15,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Icon(
      IconUtil.getIcon(iconName),
      color: ThemeUtil.textLight,
      size: size * 0.45,
    ),
  );
}
