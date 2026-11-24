import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

/// Terms of use and privacy policy.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = [
      (l10n.termsServiceTitle, l10n.termsServiceContent),
      (l10n.termsPrivacyTitle, l10n.termsPrivacyContent),
      (l10n.termsLiabilityTitle, l10n.termsLiabilityContent),
      (l10n.termsContactTitle, l10n.termsContactContent),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsOfUse)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.sm,
          Space.page,
          Space.xxl,
        ),
        itemCount: sections.length,
        separatorBuilder: (_, _) => Space.gapXl,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${sections[index].$1}',
              style: context.text.titleMedium,
            ),
            Space.gapSm,
            Text(
              sections[index].$2,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
