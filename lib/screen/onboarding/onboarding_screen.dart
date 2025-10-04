import 'package:fee_minimizer/screen/onboarding/widget/onboarding_bottom_section.dart';
import 'package:fee_minimizer/screen/onboarding/widget/onboarding_page_view.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/util/onboarding_util.dart';
import 'package:fee_minimizer/util/route_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/util/preference_util.dart';
import 'package:fee_minimizer/util/navigation_util.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  void _nextPage() {
    if (_currentIndex < OnboardingUtil.items.length - 1) {
      _pageController.nextPage(
        duration: Global.animMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  Future<void> _goToHome() async {
    await NavigationUtil.safeAsyncNavigate(
      context: context,
      isMounted: () => mounted,
        getRoute: () async {
        // Mark that onboarding is completed
        await PreferenceUtil.setFirstLaunchCompleted();
          return AppRouter.providersRoute;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: ThemeUtil.onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: Global.padMd,
                child: TextButton(
                  onPressed: _goToHome,
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: Text(
                    'Skip',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ThemeUtil.onboardingTextSecondary.withValues(
                        alpha: ThemeUtil.onboardingTextSecondaryOpacity,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingUtil.items.length,
                itemBuilder: (context, index) => OnboardingPageView(
                  item: OnboardingUtil.items[index],
                ),
              ),
            ),
            
            // Bottom section
            OnboardingBottomSection(
              currentIndex: _currentIndex,
              onNext: _nextPage,
              onSkip: _goToHome,
            ),
          ],
        ),
      ),
    );
  }
}