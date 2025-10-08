import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fee_minimizer/screen/provider_list/provider_list_screen.dart';
import 'package:fee_minimizer/screen/onboarding/onboarding_screen.dart';
import 'package:fee_minimizer/screen/settings/settings_screen.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';

class AppRouter {
  static const String onboardingRoute = '/';
  static const String providersRoute = '/providers';
  static const String settingsRoute = '/settings';

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
    ],
  );
}
