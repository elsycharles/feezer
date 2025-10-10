import 'package:go_router/go_router.dart';
import 'package:fee_minimizer/screen/provider_list/provider_list_screen.dart';
import 'package:fee_minimizer/screen/onboarding/onboarding_screen.dart';
import 'package:fee_minimizer/screen/settings/settings_screen.dart';
import 'package:fee_minimizer/screen/new_provider/new_provider_screen.dart';
import 'package:fee_minimizer/screen/provider_detail/provider_detail_screen.dart';
import 'package:fee_minimizer/screen/optimize_fee/optimize_fee_screen.dart';
import 'package:fee_minimizer/screen/fee_interval/new_fee_interval_screen.dart';
import 'package:fee_minimizer/model/provider_model.dart';
import 'package:fee_minimizer/widget/error_widget.dart';
import 'package:fee_minimizer/util/preference_util.dart';

/// Centralized router configuration using GoRouter for clean navigation
class AppRouter {
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/';
  static const String providersRoute = '/providers';
  static const String settingsRoute = '/settings';
  static const String newProviderRoute = '/new-provider';
  static const String providerDetailRoute = '/provider';
  static const String newFeeIntervalRoute = '/new-fee-interval';
  
  // Convenience getters for commonly used routes
  static String get optimizeFeeRoute => homeRoute;

  static final GoRouter router = GoRouter(
    initialLocation: homeRoute,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final isFirstLaunch = await PreferenceUtil.isFirstLaunch();
      if (isFirstLaunch && state.uri.toString() != onboardingRoute) {
        return onboardingRoute;
      }
      return null;
    },
    errorBuilder: (context, state) => ErrorScreen(state: state),
    routes: [
      // Home route (Fee Optimization)
      GoRoute(
        path: homeRoute,
        name: 'home',
        builder: (context, state) {
          final defaultProvider = state.extra as Provider?;
          return OptimizeFeeScreen(defaultProvider: defaultProvider);
        },
      ),
      
      // Onboarding
      GoRoute(
        path: onboardingRoute,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      
      // Providers list
      GoRoute(
        path: providersRoute,
        name: 'providers',
        builder: (_, __) => const ProviderListScreen(),
      ),
      
      // Settings
      GoRoute(
        path: settingsRoute,
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      
      // New provider
      GoRoute(
        path: newProviderRoute,
        name: 'newProvider',
        builder: (_, __) => const NewProviderScreen(),
      ),
      
      // Provider detail
      GoRoute(
        path: '$providerDetailRoute/:providerId',
        name: 'providerDetail',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          final provider = state.extra as Provider?;
          
          if (provider != null) {
            return ProviderDetailScreen(provider: provider);
          }
          
          // Create a fallback provider for cases where extra data is not passed
          return ProviderDetailScreen(
            provider: Provider(
              id: providerId,
              name: 'Loading...',
              description: 'Loading provider details...',
              iconName: 'business',
            ),
          );
        },
      ),
      
      // New fee interval
      GoRoute(
        path: newFeeIntervalRoute,
        name: 'newFeeInterval',
        builder: (_, __) => const NewFeeIntervalScreen(),
      ),
    ],
  );
}
