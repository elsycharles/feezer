import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../util/link_util.dart';
import '../../widget/common.dart';

/// Frequently asked questions and contact.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _email = 'elsy.s.charles@gmail.com';
  static const _whatsapp = 'https://wa.me/261348421634';
  static const _website = 'https://elsycharles.github.io/';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final faq = [
      (l10n.faqHowItWorks, l10n.faqHowItWorksAnswer),
      (l10n.faqFeeUpdate, l10n.faqFeeUpdateAnswer),
      (l10n.faqRounding, l10n.faqRoundingAnswer),
      (l10n.faqPrivacy, l10n.faqPrivacyAnswer),
      (l10n.faqExportData, l10n.faqExportDataAnswer),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpAndSupport)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.sm,
          Space.page,
          Space.xxl,
        ),
        children: [
          SectionLabel(l10n.faq),
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < faq.length; i++) ...[
                  if (i > 0) const Divider(),
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: Space.lg,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        Space.lg,
                        0,
                        Space.lg,
                        Space.lg,
                      ),
                      title: Text(faq[i].$1, style: context.text.titleSmall),
                      children: [
                        Text(
                          faq[i].$2,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Space.gapXl,
          SectionLabel(l10n.contactUs),
          MenuGroup(
            children: [
              MenuRow(
                icon: Icons.mail_outline_rounded,
                title: l10n.email,
                subtitle: _email,
                trailing: const SizedBox.shrink(),
                onTap: () =>
                    LinkUtil.open(context, Uri(scheme: 'mailto', path: _email)),
              ),
              MenuRow(
                icon: Icons.chat_outlined,
                title: 'WhatsApp',
                subtitle: '+261 34 84 216 34',
                trailing: const SizedBox.shrink(),
                onTap: () => LinkUtil.open(context, Uri.parse(_whatsapp)),
              ),
              MenuRow(
                icon: Icons.language_rounded,
                title: l10n.website,
                subtitle: Uri.parse(_website).host,
                trailing: const SizedBox.shrink(),
                onTap: () => LinkUtil.open(context, Uri.parse(_website)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
