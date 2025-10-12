import 'package:flutter/material.dart';
import 'package:fee_minimizer/widget/surface_card.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/widget/app_bar.dart' as custom;
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:fee_minimizer/widget/refreshable_screen.dart';
import 'package:fee_minimizer/styles/global.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).termsOfUse,
        menuExcludeRoutes: const [],
      ),
      body: SafeArea(
        child: RefreshableScreen(
          onRefresh: () async {
            // For terms screen, we could refresh terms data or just provide haptic feedback
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsIntroductionTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsIntroductionContent,
                        style: ThemeUtil.bodyLarge.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // Acceptance of Terms section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsAcceptanceTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsAcceptanceContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // User Responsibilities section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsResponsibilitiesTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsResponsibilitiesContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // Service Description section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsServiceTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsServiceContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // Privacy and Data section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsPrivacyTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsPrivacyContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // Limitation of Liability section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsLiabilityTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsLiabilityContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // Termination section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsTerminationTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsTerminationContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // Governing Law section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsGoverningLawTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsGoverningLawContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingLg),

                // Contact Information section
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).termsContactTitle,
                        style: ThemeUtil.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Global.spacingMd),
                      Text(
                        AppLocalizations.of(context).termsContactContent,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Global.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}