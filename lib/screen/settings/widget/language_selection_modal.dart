import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    Navigator.of(context).pop();
  }

  void _useSystemLanguage(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    localeProvider.clearLocale();
    Navigator.of(context).pop();
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
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
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
                      l10n.system,
                      AppLocalizations.of(context).systemDefault,
                      null,
                      localeProvider.locale == null,
                      () => _useSystemLanguage(context),
                    ),
                    
                    // Specific language options
                    ...SupportedLocale.supportedLocales.map((supportedLocale) =>
                      _buildLanguageOption(
                        context,
                        supportedLocale.nativeName,
                        supportedLocale.displayName,
                        supportedLocale.locale,
                        localeProvider.locale?.languageCode == supportedLocale.locale.languageCode,
                        () => _changeLanguage(context, supportedLocale),
                      ),
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
    String secondaryText,
    Locale? locale,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      builder: (context, hovered, pressed) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (secondaryText != primaryText) ...[
                    const SizedBox(height: 2),
                    Text(
                      secondaryText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}