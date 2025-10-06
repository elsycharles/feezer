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
    final canPop = Navigator.of(context).canPop();

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
      leading: leading ?? (canPop ? _buildBackButton(context, colorScheme) : null),
      automaticallyImplyLeading: leading == null && canPop,
    );
  }

  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).maybePop(),
          splashColor: colorScheme.onSurface.withOpacity(0.1),
          highlightColor: colorScheme.onSurface.withOpacity(0.05),
          hoverColor: colorScheme.onSurface.withOpacity(0.08),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
