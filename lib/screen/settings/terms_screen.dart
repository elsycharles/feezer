import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../util/link_util.dart';
import 'help_screen.dart';

/// Terms of use, one line per point.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = [
      (l10n.termsServiceTitle, l10n.termsServiceContent),
      (l10n.termsPrivacyTitle, l10n.termsPrivacyContent),
      (l10n.termsLiabilityTitle, l10n.termsLiabilityContent),
      (l10n.termsIndependenceTitle, l10n.termsIndependenceContent),
    ];
    final body = context.text.bodyMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    Widget section(int number, String title, Widget content) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number. $title', style: context.text.titleMedium),
        Space.gapXs,
        content,
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsOfUse)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.sm,
          Space.page,
          Space.xxl,
        ),
        children: [
          for (final (i, (title, content)) in sections.indexed) ...[
            section(i + 1, title, Text(content, style: body)),
            Space.gapXl,
          ],
          section(
            sections.length + 1,
            l10n.termsContactTitle,
            GestureDetector(
              onTap: () => LinkUtil.open(
                context,
                Uri(scheme: 'mailto', path: HelpScreen.email),
              ),
              child: Text(
                HelpScreen.email,
                style: body?.copyWith(color: context.colors.primary),
              ),
            ),
          ),
          Space.gapXxl,
          Text(l10n.termsAcceptance, style: context.text.bodySmall),
        ],
      ),
    );
  }
}
