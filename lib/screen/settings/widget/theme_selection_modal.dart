import 'package:flutter/material.dart';
import '../../../util/preference_util.dart';
import '../../../provider/theme_provider.dart';
import '../../../widget/interactive_surface.dart';
import 'package:provider/provider.dart';

/// Theme selection modal with radio buttons
class ThemeSelectionModal extends StatelessWidget {
  const ThemeSelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSelectionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Choose Theme',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Theme options
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    _buildThemeOption(
                      context,
                      'Light',
                      'Always use light theme',
                      Icons.light_mode,
                      AppThemeMode.light,
                      themeProvider.themeMode == AppThemeMode.light,
                      () => themeProvider.setThemeMode(AppThemeMode.light),
                    ),
                    _buildThemeOption(
                      context,
                      'Dark',
                      'Always use dark theme',
                      Icons.dark_mode,
                      AppThemeMode.dark,
                      themeProvider.themeMode == AppThemeMode.dark,
                      () => themeProvider.setThemeMode(AppThemeMode.dark),
                    ),
                    _buildThemeOption(
                      context,
                      'System',
                      'Follow system settings',
                      Icons.settings_brightness,
                      AppThemeMode.system,
                      themeProvider.themeMode == AppThemeMode.system,
                      () => themeProvider.setThemeMode(AppThemeMode.system),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AppThemeMode themeMode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InteractiveSurface(
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.zero,
      builder: (context, hovered, pressed) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Radio<AppThemeMode>(
              value: themeMode,
              groupValue: context.watch<ThemeProvider>().themeMode,
              onChanged: (value) {
                if (value != null) {
                  onTap();
                  Navigator.of(context).pop();
                }
              },
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}