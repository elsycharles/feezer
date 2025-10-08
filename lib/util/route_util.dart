import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fee_minimizer/screen/provider_list/provider_list_screen.dart';
import 'package:fee_minimizer/screen/onboarding/onboarding_screen.dart';
import 'package:fee_minimizer/screen/settings/settings_screen.dart';
import 'package:fee_minimizer/screen/new_provider/new_provider_screen.dart';
import 'package:fee_minimizer/screen/provider_detail/provider_detail_screen.dart';
import 'package:fee_minimizer/screen/optimize_fee/optimize_fee_screen.dart';
import 'package:fee_minimizer/screen/fee_interval/new_fee_interval_screen.dart';
import 'package:fee_minimizer/model/provider_model.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';

class AppRouter {
  static const String onboardingRoute = '/';
  static const String providersRoute = '/providers';
  static const String settingsRoute = '/settings';
  static const String newProviderRoute = '/new-provider';
  static const String providerDetailRoute = '/provider-detail';
  static const String optimizeFeeRoute = '/optimize-fee';
  static const String newFeeIntervalRoute = '/new-fee-interval';

  static final GoRouter router = GoRouter(
    initialLocation: onboardingRoute,
    debugLogDiagnostics: false,
    errorBuilder: (context, state) {
      final colorScheme = Theme.of(context).colorScheme;
      final currentLocation = state.uri.toString();
      final isOnHomePage =
          currentLocation == providersRoute ||
          currentLocation == onboardingRoute;

      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).error)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(
                  context,
                ).screenNotFound(state.uri.toString()),
              ),
              const SizedBox(height: 16),
              // Only show navigation button if not already on home page
              if (!isOnHomePage)
                ElevatedButton(
                  onPressed: () => context.go(providersRoute),
                  child: Text(AppLocalizations.of(context).goHome),
                ),
            ],
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: onboardingRoute,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: providersRoute,
        name: 'providers',
        builder: (_, __) => const ProviderListScreen(),
      ),
      GoRoute(
        path: settingsRoute,
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: newProviderRoute,
        name: 'newProvider',
        builder: (_, __) => const NewProviderScreen(),
      ),
      GoRoute(
        path: '$providerDetailRoute/:providerId',
        name: 'providerDetail',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          final provider = state.extra as Provider?;
          
          // If provider object is passed via extra, use it
          if (provider != null) {
            return ProviderDetailScreen(provider: provider);
          }
          
          // Otherwise, we need to find the provider by ID
          // For now, we'll create a dummy provider - this should be replaced with actual data loading
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
      GoRoute(
        path: optimizeFeeRoute,
        name: 'optimizeFee',
        builder: (_, __) => const OptimizeFeeScreen(),
      ),
      GoRoute(
        path: newFeeIntervalRoute,
        name: 'newFeeInterval',
        builder: (_, __) => const NewFeeIntervalScreen(),
      ),
    ],
  );


}
