import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' hide AppBar;
import '../util/theme_util.dart';

/// Simple and reusable white AppBar with centered title
class AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;

  const AppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.elevation = 0,
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
        ) ?? ThemeUtil.titleSmall.copyWith(color: colorScheme.onSurface),
      ),
      actions: actions,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
