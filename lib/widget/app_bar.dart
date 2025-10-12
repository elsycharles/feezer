import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' hide AppBar;

import '../util/theme_util.dart';
import 'app_menu_button.dart';

/// Beautiful and modern AppBar with elegant design matching AppToast styling
class AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final bool showMenuButton;
  final List<String> menuExcludeRoutes;
  final Color? menuIconColor;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? titleColor;
  final double borderRadius;
  final bool useGradient;
  final Color? gradientStartColor;
  final Color? gradientEndColor;

  const AppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.elevation = 0,
    this.showMenuButton = true,
    this.menuExcludeRoutes = const [],
    this.menuIconColor,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.titleColor,
    this.borderRadius = 0,
    this.useGradient = false,
    this.gradientStartColor,
    this.gradientEndColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        backgroundColor ??
        (isDark
            ? colorScheme.surface.withValues(alpha: 0.95)
            : colorScheme.surface.withValues(alpha: 0.98));

    final textColor = titleColor ?? colorScheme.onSurface;

    final decoration = BoxDecoration(
      color: useGradient ? null : bgColor,
      gradient: useGradient
          ? LinearGradient(
              colors: [
                gradientStartColor ??
                    colorScheme.primary.withValues(alpha: 0.1),
                gradientEndColor ?? colorScheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      border: Border(
        bottom: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );

    return Container(
      decoration: decoration,
      child: material.AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0, // We handle elevation with our own shadows
        centerTitle: true,
        title: Text(
          title,
          style: ThemeUtil.titleMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: _buildActions(context, colorScheme),
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading && leading == null,
        toolbarHeight: kToolbarHeight + (borderRadius > 0 ? 8 : 0),
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context, ColorScheme colorScheme) {
    final List<Widget> allActions = [];

    if (actions != null && actions!.isNotEmpty) {
      allActions.addAll(actions!);
    }

    if (showMenuButton) {
      allActions.add(
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: AppMenuButton(
            excludeRoutes: menuExcludeRoutes,
            iconColor: menuIconColor ?? colorScheme.onSurface,
          ),
        ),
      );
    }

    return allActions.isEmpty ? null : allActions;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (borderRadius > 0 ? 8 : 0));
}
