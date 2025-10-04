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
    return material.AppBar(
      backgroundColor: ThemeUtil.surfaceLight,
      foregroundColor: ThemeUtil.textPrimary,
      elevation: elevation,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ThemeUtil.textPrimary,
        ),
      ),
      actions: actions,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}