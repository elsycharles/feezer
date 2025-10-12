import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../util/theme_util.dart';
import '../../util/preference_util.dart';
import '../../util/navigation_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/surface_card.dart';
import '../../widget/interactive_surface.dart';
import '../../provider/theme_provider.dart';
import '../../provider/locale_provider.dart';
import '../../provider/currency_provider.dart';
import '../../l10n/app_localizations.dart';
import 'widget/theme_selection_modal.dart';
import 'widget/language_selection_modal.dart';
import 'widget/currency_selection_modal.dart';
import '../../widget/refreshable_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    // For settings screen, we could refresh currency data or just provide haptic feedback
    // For now, we'll just wait a bit to simulate refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).settings,
        menuExcludeRoutes: [NavigationUtil.settingsRoute],
      ),
      body: SafeArea(
        child: RefreshableScreen(
          onRefresh: () => _onRefresh(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(context, AppLocalizations.of(context).general, [
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
                  builder: (context, localeProvider, child) =>
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context).language,
                        localeProvider.currentSupportedLocale?.nativeName ??
                            AppLocalizations.of(context).system,
                        Icons.language_outlined,
                        onTap: () => LanguageSelectionModal.show(context),
                      ),
                ),
                Consumer<CurrencyProvider>(
                  builder: (context, currencyProvider, child) =>
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context).currencies,
                        currencyProvider.selectedCurrency?.displayName ??
                            AppLocalizations.of(context).system,
                        Icons.currency_exchange_outlined,
                        onTap: () => _showCurrencySelection(context),
                      ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection(
                context,
                AppLocalizations.of(context).dataManagement,
                [
                  _buildSettingTile(
                    context,
                    AppLocalizations.of(context).csvManagement,
                    AppLocalizations.of(context).importExportData,
                    Icons.file_download_outlined,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(NavigationUtil.csvManagementRoute),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(context, AppLocalizations.of(context).about, [
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
                  onTap: () => Navigator.of(context).pushNamed(NavigationUtil.helpSupportRoute),
                ),
                _buildSettingTile(
                  context,
                  AppLocalizations.of(context).termsOfUse,
                  AppLocalizations.of(context).termsAndPrivacyPolicy,
                  Icons.description_outlined,
                  onTap: () => Navigator.of(context).pushNamed(NavigationUtil.termsOfUseRoute),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
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
        leading: Icon(icon, color: textColor ?? colorScheme.onSurface),
        title: Text(
          title,
          style: ThemeUtil.bodyLarge.copyWith(
            color: textColor ?? colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: ThemeUtil.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: showArrow
            ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant)
            : null,
        enabled: onTap != null,
      ),
    );
  }

  void _showCurrencySelection(BuildContext context) {
    CurrencySelectionModal.show(context);
  }

  String _getThemeModeDisplayName(
    BuildContext context,
    AppThemeMode themeMode,
  ) {
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
