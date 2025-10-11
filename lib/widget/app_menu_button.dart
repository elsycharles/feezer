import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../styles/global.dart';
import '../util/extensions_util.dart';
import '../util/navigation_util.dart';
import '../util/theme_util.dart';

/// Réutilisable PopupMenuButton pour la navigation entre les écrans principaux
class AppMenuButton extends StatelessWidget {
  final List<String> excludeRoutes;
  final Color? iconColor;

  const AppMenuButton({
    super.key,
    this.excludeRoutes = const [],
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = _buildMenuItems(context);
    
    if (menuItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = context.colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.menu,
        color: iconColor ?? colorScheme.onSurface,
      ),
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: Global.borderMd),
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => menuItems,
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<String>>[];
    
    // Fee Optimizer (Home)
    if (!excludeRoutes.contains(NavigationUtil.homeRoute)) {
      items.add(PopupMenuItem(
        value: NavigationUtil.homeRoute,
        child: _MenuItem(
          icon: Icons.analytics,
          text: AppLocalizations.of(context).optimizeFee,
          context: context,
        ),
      ));
    }

    // Providers
    if (!excludeRoutes.contains(NavigationUtil.providersRoute)) {
      items.add(PopupMenuItem(
        value: NavigationUtil.providersRoute,
        child: _MenuItem(
          icon: Icons.business,
          text: AppLocalizations.of(context).providers,
          context: context,
        ),
      ));
    }

    // Settings
    if (!excludeRoutes.contains(NavigationUtil.settingsRoute)) {
      items.add(PopupMenuItem(
        value: NavigationUtil.settingsRoute,
        child: _MenuItem(
          icon: Icons.settings,
          text: AppLocalizations.of(context).settings,
          context: context,
        ),
      ));
    }

    return items;
  }

  void _handleMenuSelection(BuildContext context, String route) {
    NavigationUtil.pushTo(context, route);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final BuildContext context;

  const _MenuItem({
    required this.icon,
    required this.text,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.colorScheme.onSurface),
        const SizedBox(width: 12),
        Text(
          text,
          style: ThemeUtil.bodyMedium.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}