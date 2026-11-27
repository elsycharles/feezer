import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../model/locale_model.dart';
import '../../provider/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../widget/common.dart';

/// Name of the language in use, in that language ("Français", "Malagasy").
String currentLanguageName(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return SupportedLocale.supportedLocales
          .where((l) => l.locale.languageCode == code)
          .firstOrNull
          ?.nativeName ??
      code;
}

/// Sheet to choose the language: the phone's, or one of the app's.
Future<void> showLanguagePicker(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final provider = context.read<LocaleProvider>();
  final selected = provider.locale?.languageCode;
  return showAppSheet<void>(
    context,
    title: l10n.language,
    builder: (sheetContext) {
      Widget option(String label, String? code, VoidCallback onTap) => MenuRow(
        icon: selected == code
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected == code ? sheetContext.colors.primary : null,
        title: label,
        trailing: const SizedBox.shrink(),
        onTap: () {
          onTap();
          Navigator.of(sheetContext).pop();
        },
      );
      return MenuGroup(
        children: [
          option(l10n.system, null, provider.clearLocale),
          for (final locale in SupportedLocale.supportedLocales)
            option(
              locale.nativeName,
              locale.locale.languageCode,
              () => provider.setLocale(locale.locale),
            ),
        ],
      );
    },
  );
}
