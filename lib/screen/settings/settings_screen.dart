import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../util/preference_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/app_toast.dart';
import '../../widget/surface_card.dart';
import '../../widget/interactive_surface.dart';
import '../../provider/theme_provider.dart';
import '../../provider/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'widget/theme_selection_modal.dart';
import 'widget/language_selection_modal.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).settings,
        showSettingsButton: false, // Don't show settings button on settings page
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              context,
              AppLocalizations.of(context).general,
              [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) => _buildSettingTile(
                    context,
                    AppLocalizations.of(context).theme,
                    _getThemeModeDisplayName(context, themeProvider.themeMode),
                    Icons.palette_outlined,
                    onTap: () => ThemeSelectionModal.show(context),
                  ),
                ),
                Consumer<LocaleProvider>(
                  builder: (context, localeProvider, child) => _buildSettingTile(
                    context,
                    AppLocalizations.of(context).language,
                    localeProvider.currentSupportedLocale?.nativeName ?? AppLocalizations.of(context).system,
                    Icons.language_outlined,
                    onTap: () => LanguageSelectionModal.show(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // _buildSection(
            //   context,
            //   'Data',
            //   [
            //     _buildSettingTile(
            //       context,
            //       'Export data',
            //       'Backup your providers and fees',
            //       Icons.file_download_outlined,
            //       onTap: () => _showComingSoon(context),
            //     ),
            //     _buildSettingTile(
            //       context,
            //       'Import data',
            //       'Restore from backup',
            //       Icons.file_upload_outlined,
            //       onTap: () => _showComingSoon(context),
            //     ),
            //     _buildSettingTile(
            //       context,
            //       'Reset',
            //       'Clear all data',
            //       Icons.delete_outline,
            //       onTap: () => _showResetConfirmation(context),
            //       textColor: colorScheme.error,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 24),
            _buildSection(
              context,
              AppLocalizations.of(context).about,
              [
                _buildSettingTile(
                  context,
                  AppLocalizations.of(context).version,
                  '1.0.0',
                  Icons.info_outline,
                  showArrow: false,
                ),
                _buildSettingTile(
                  context,
                  AppLocalizations.of(context).helpAndSupport,
                  AppLocalizations.of(context).faqAndContact,
                  Icons.help_outline,
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingTile(
                  context,
                  AppLocalizations.of(context).termsOfUse,
                  AppLocalizations.of(context).termsAndPrivacyPolicy,
                  Icons.description_outlined,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    bool showArrow = true,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      builder: (context, hovered, pressed) => ListTile(
        leading: Icon(
          icon,
          color: textColor ?? colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textColor ?? colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: showArrow
            ? Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
        enabled: onTap != null,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    AppToast.info(context, AppLocalizations.of(context).featureComingNextVersion);
  }

  String _getThemeModeDisplayName(BuildContext context, AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return AppLocalizations.of(context).light;
      case AppThemeMode.dark:
        return AppLocalizations.of(context).dark;
      case AppThemeMode.system:
        return AppLocalizations.of(context).system;
    }
  }
}