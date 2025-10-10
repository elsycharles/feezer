import 'package:fee_minimizer/model/onboarding_model.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:flutter/material.dart';

class OnboardingPageView extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPageView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: Global.padLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: Global.borderXl,
              color: colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: Global.borderXl,
              child: Image.asset(
                item.imagePath,
                width: 280,
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback image if onboarding image not found
                  return Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: Global.borderSm,
                      color: colorScheme.surface,
                    ),
                    child: ClipRRect(
                      borderRadius: Global.borderSm,
                      child: Image.asset(
                        'assets/images/fallback.png',
                        width: 280,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: Global.spacingXxl),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
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
              color: colorScheme.onSurface.withValues(
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
