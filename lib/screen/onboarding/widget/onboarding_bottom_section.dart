import 'package:fee_minimizer/screen/onboarding/widget/onboarding_page_dot.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/util/onboarding_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:flutter/material.dart';

class OnboardingBottomSection extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingBottomSection({
    super.key,
    required this.currentIndex,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = currentIndex == OnboardingUtil.items.length - 1;

    return Padding(
      padding: Global.padXl,
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              OnboardingUtil.items.length,
              (index) => OnboardingPageDot(isActive: index == currentIndex),
            ),
          ),

          Global.gapXl,

          // Action button
          SizedBox(
            width: double.infinity,
            height: Global.buttonHeight,
            child: ElevatedButton(
              onPressed: onNext,
              style: ButtonStyle(
                backgroundColor: ThemeUtil.interactiveBackground(
                  ThemeUtil.onboardingButton,
                ),
                foregroundColor: WidgetStateProperty.all(
                  ThemeUtil.onboardingTextPrimary,
                ),
                overlayColor: ThemeUtil.interactiveOverlay(
                  ThemeUtil.onboardingTextPrimary,
                ),
                elevation: WidgetStateProperty.all(0),
                splashFactory: NoSplash.splashFactory,
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              child: Text(
                isLastPage ? 'Get Started' : 'Next',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeUtil.onboardingTextPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
