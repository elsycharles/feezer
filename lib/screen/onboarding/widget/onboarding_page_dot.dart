import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:flutter/material.dart';

class OnboardingPageDot extends StatelessWidget {
  final bool isActive;

  const OnboardingPageDot({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Global.animFast,
      margin: const EdgeInsets.symmetric(horizontal: Global.spacingXs),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive 
            ? ThemeUtil.onboardingDotActive 
            : ThemeUtil.onboardingDotInactive.withValues(
                alpha: ThemeUtil.onboardingDotInactiveOpacity,
              ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}