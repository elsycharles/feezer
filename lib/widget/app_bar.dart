import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' hide AppBar;
import 'package:go_router/go_router.dart';
import '../util/theme_util.dart';
import '../util/route_util.dart';

/// Simple and reusable white AppBar with centered title
class AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final bool showSettingsButton;
  final VoidCallback? onSettingsPressed;

  const AppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.elevation = 0,
    this.showSettingsButton = true,
    this.onSettingsPressed,
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
      actions: _buildActions(context, colorScheme),
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
          splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
          highlightColor: colorScheme.onSurface.withValues(alpha: 0.05),
          hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
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

  List<Widget>? _buildActions(BuildContext context, ColorScheme colorScheme) {
    final List<Widget> allActions = [];
    
    // Add custom actions if provided
    if (actions != null) {
      allActions.addAll(actions!);
    }
    
    // Add settings button if enabled
    if (showSettingsButton) {
      allActions.add(_buildSettingsButton(context, colorScheme));
    }
    
    return allActions.isEmpty ? null : allActions;
  }

  Widget _buildSettingsButton(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onSettingsPressed ?? () => _showSettingsDialog(context),
          splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
          highlightColor: colorScheme.onSurface.withValues(alpha: 0.05),
          hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.settings,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    // Navigate to settings screen
    context.push(AppRouter.settingsRoute);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
