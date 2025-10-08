import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Reusable loading widget with consistent theme styling
/// Used throughout the app for loading states
class AppLoading extends StatelessWidget {
  final bool showBackground;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;

  const AppLoading({
    super.key,
    this.showBackground = true,
    this.backgroundColor,
    this.size = 40.0,
    this.strokeWidth = 3.0,
  });

  /// Overlay loading that covers the entire screen
  const AppLoading.overlay({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 3.0,
  }) : showBackground = true,
       backgroundColor = null;

  /// Inline loading without background
  const AppLoading.inline({super.key, this.size = 24.0, this.strokeWidth = 2.5})
    : showBackground = false,
      backgroundColor = null;

  /// Small loading indicator for buttons or compact spaces
  const AppLoading.small({super.key, this.size = 20.0, this.strokeWidth = 2.0})
    : showBackground = false,
      backgroundColor = null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget loadingWidget = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: colorScheme.primary,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
      ),
    );

    if (!showBackground) {
      return loadingWidget;
    }

    return Container(
      color:
          backgroundColor ??
          (isDark
              ? ThemeUtil.backgroundDark.withValues(alpha: 0.9)
              : ThemeUtil.backgroundLight.withValues(alpha: 0.9)),
      child: Center(child: loadingWidget),
    );
  }
}
