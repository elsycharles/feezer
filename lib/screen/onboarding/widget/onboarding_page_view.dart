import 'package:fee_minimizer/model/onboarding_model.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:flutter/material.dart';

class OnboardingPageView extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPageView({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: Global.padLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: ThemeUtil.onboardingIllustrationBg.withValues(
                alpha: ThemeUtil.onboardingIllustrationBgOpacity,
              ),
              borderRadius: Global.borderXl,
            ),
            child: Icon(
              Icons.savings_outlined,
              size: 120,
              color: ThemeUtil.onboardingTextPrimary,
            ),
          ),
          
          const SizedBox(height: Global.spacingXxl),
          
          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: ThemeUtil.onboardingTextPrimary,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          
          Global.gapMd,
          
          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: ThemeUtil.onboardingTextSecondary.withValues(
                alpha: ThemeUtil.onboardingTextSecondaryOpacity,
              ),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}