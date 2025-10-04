import 'package:fee_minimizer/screen/provider_list/provider_list_screen.dart';
import 'package:fee_minimizer/screen/onboarding/onboarding_screen.dart';
import 'package:fee_minimizer/screen/splash/splash_screen.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String providersRoute = '/providers';

  static final GoRouter router = GoRouter(
    initialLocation: splashRoute,
    debugLogDiagnostics: false,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: ThemeUtil.error),
            const SizedBox(height: 16),
            Text('Screen ${state.uri.toString()} not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(providersRoute),
              child: const Text('Back to providers'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboardingRoute,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: providersRoute,
        name: 'providers',
        builder: (context, state) => const ProviderListScreen(),
      ),
    ],
  );
}