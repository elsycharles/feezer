import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' hide AppBar;

import '../util/theme_util.dart';
import 'app_menu_button.dart';

/// Simple and reusable white AppBar with centered title
class AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final bool showMenuButton;
  final List<String> menuExcludeRoutes;
  final Color? menuIconColor;

  const AppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.elevation = 0,
    this.showMenuButton = true,
    this.menuExcludeRoutes = const [],
    this.menuIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return material.AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: elevation,
      centerTitle: true,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ) ??
            ThemeUtil.titleSmall.copyWith(color: colorScheme.onSurface),
      ),
      actions: _buildActions(context, colorScheme),
      leading: leading, // Use native GoRouter back button behavior
      automaticallyImplyLeading: leading == null, // Let GoRouter handle back button
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
