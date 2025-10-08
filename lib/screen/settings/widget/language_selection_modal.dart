import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../provider/locale_provider.dart';
import '../../../model/locale_model.dart';
import '../../../widget/interactive_surface.dart';
import '../../../l10n/app_localizations.dart';

/// Language selection modal with radio buttons
class LanguageSelectionModal extends StatelessWidget {
  const LanguageSelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectionModal(),
    );
  }

  void _changeLanguage(BuildContext context, SupportedLocale supportedLocale) {
    final localeProvider = context.read<LocaleProvider>();
    localeProvider.setLocale(supportedLocale.locale);
    // Do not close modal automatically
  }

  void _useSystemLanguage(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    localeProvider.clearLocale();
    // Do not close modal automatically
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar - tap to close
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text(
                l10n.language,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Language options
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return Column(
                  children: [
                    // System default option
                    _buildLanguageOption(
                      context,
                      l10n.systemDefault,
                      localeProvider.locale == null,
                      () => _useSystemLanguage(context),
                      icon: Icons.settings_brightness,
                    ),

                    // Specific language options
                    _buildLanguageOption(
                      context,
                      l10n.english,
                      localeProvider.locale?.languageCode == 'en',
                      () => _changeLanguage(
                        context,
                        SupportedLocale.supportedLocales[0],
                      ),
                      svgAsset: 'assets/icons/en.svg',
                    ),
                    _buildLanguageOption(
                      context,
                      l10n.french,
                      localeProvider.locale?.languageCode == 'fr',
                      () => _changeLanguage(
                        context,
                        SupportedLocale.supportedLocales[1],
                      ),
                      svgAsset: 'assets/icons/fr.svg',
                    ),
                    _buildLanguageOption(
                      context,
                      l10n.malagasy,
                      localeProvider.locale?.languageCode == 'mg',
                      () => _changeLanguage(
                        context,
                        SupportedLocale.supportedLocales[2],
                      ),
                      svgAsset: 'assets/icons/mg.svg',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String primaryText,
    bool isSelected,
    VoidCallback onTap, {
    IconData? icon,
    String? svgAsset,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      builder: (context, hovered, pressed) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Language icon (SVG or Material Icon)
            if (svgAsset != null) ...[
              SvgPicture.asset(svgAsset, width: 32, height: 32),
              const SizedBox(width: 16),
            ] else if (icon != null) ...[
              Icon(icon, size: 32, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                primaryText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
