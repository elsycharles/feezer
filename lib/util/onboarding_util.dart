import 'package:flutter/material.dart';
import 'package:fee_minimizer/model/onboarding_model.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';

class OnboardingUtil {
  static List<OnboardingItem> items(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      OnboardingItem(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDescription1,
        imagePath: 'assets/images/onboarding_1.png',
      ),
      OnboardingItem(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDescription2,
        imagePath: 'assets/images/onboarding_2.png',
      ),
      OnboardingItem(
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDescription3,
        imagePath: 'assets/images/onboarding_3.png',
      ),
    ];
  }
}
