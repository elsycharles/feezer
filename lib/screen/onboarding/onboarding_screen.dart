import 'package:fee_minimizer/screen/onboarding/widget/onboarding_bottom_section.dart';
import 'package:fee_minimizer/screen/onboarding/widget/onboarding_page_view.dart';
import 'package:fee_minimizer/styles/global.dart';
import 'package:fee_minimizer/util/onboarding_util.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/util/preference_util.dart';
import 'package:fee_minimizer/util/navigation_util.dart';
import 'package:fee_minimizer/widget/app_loading_page.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _shouldShowOnboarding = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    final isFirstLaunch = await PreferenceUtil.isFirstLaunch();
    if (!isFirstLaunch && mounted) {
      NavigationUtil.safeAsyncNavigate(
        context: context,
        isMounted: () => mounted,
        getRoute: () async => NavigationUtil.homeRoute,
      );
    } else if (mounted) {
      setState(() => _shouldShowOnboarding = true);
    }
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  void _nextPage() {
    final items = OnboardingUtil.items(context);
    if (_currentIndex < items.length - 1) {
      _pageController.nextPage(
        duration: Global.animMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _startLoadingAndGoHome();
    }
  }

  Future<void> _startLoadingAndGoHome() async {
    setState(() => _isLoading = true);
    await _goToHome();
    // No need to set false since we navigate away
  }

  Future<void> _goToHome() async {
    await NavigationUtil.safeAsyncNavigate(
      context: context,
      isMounted: () => mounted,
      getRoute: () async {
        // Mark that onboarding is completed
        await PreferenceUtil.setFirstLaunchCompleted();
        return NavigationUtil.homeRoute;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowOnboarding) {
      return const AppLoadingPage();
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _goToHome,
                  style: ButtonStyle(
                    overlayColor: ThemeUtil.interactiveOverlay(
                      theme.colorScheme.onSurface,
                    ),
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    AppLocalizations.of(context).skip,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
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
              child: Builder(
                builder: (context) {
                  final items = OnboardingUtil.items(context);
                  return PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        OnboardingPageView(item: items[index]),
                  );
                },
              ),
            ),

            // Bottom section
            OnboardingBottomSection(
              currentIndex: _currentIndex,
              onNext: _nextPage,
              onSkip: _goToHome,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
