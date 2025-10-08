import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/provider_model.dart';
import 'route_util.dart';

/// Navigation utilities for safe and consistent navigation throughout the app
class NavigationUtil {
  /// Safe async navigation - captures context before async operation
  static Future<void> safeAsyncNavigate({
    required BuildContext context,
    required bool Function() isMounted,
    required Future<String> Function() getRoute,
  }) async {
    final route = await getRoute();
    if (isMounted()) {
      // ignore: use_build_context_synchronously
      context.go(route);
    }
  }

  /// Safely navigates back using GoRouter. If no pages to pop, navigates to fallback route.
  /// 
  /// [context] - BuildContext for navigation
  /// [fallbackRoute] - Route to navigate to if stack is empty (defaults to providers route)
  static void safeBack(BuildContext context, {String? fallbackRoute}) {
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else {
      context.go(fallbackRoute ?? AppRouter.providersRoute);
    }
  }

  /// Safely pops with a result using GoRouter. If no pages to pop, navigates to fallback route.
  /// 
  /// [context] - BuildContext for navigation
  /// [result] - Result to return when popping
  /// [fallbackRoute] - Route to navigate to if stack is empty (defaults to providers route)
  static void safeBackWithResult<T>(BuildContext context, T result, {String? fallbackRoute}) {
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop(result);
    } else {
      context.go(fallbackRoute ?? AppRouter.providersRoute);
    }
  }

  // Provider navigation helpers
  /// Navigate to provider detail screen with provider object
  static void goToProviderDetail(BuildContext context, Provider provider) {
    context.go(providerDetailPath(provider.id), extra: provider);
  }
  
  /// Push provider detail screen and return result
  static Future<T?> pushProviderDetail<T>(BuildContext context, Provider provider) {
    return context.push(providerDetailPath(provider.id), extra: provider);
  }

  /// Generate provider detail path with ID
  static String providerDetailPath(String providerId) => 
    '${AppRouter.providerDetailRoute}/$providerId';

  // Common navigation actions
  /// Navigate to new provider screen
  static Future<T?> pushNewProvider<T>(BuildContext context) {
    return context.push(AppRouter.newProviderRoute);
  }

  /// Navigate to optimize fee screen
  static Future<T?> pushOptimizeFee<T>(BuildContext context) {
    return context.push(AppRouter.optimizeFeeRoute);
  }

  /// Navigate to new fee interval screen
  static Future<T?> pushNewFeeInterval<T>(BuildContext context) {
    return context.push(AppRouter.newFeeIntervalRoute);
  }

  /// Navigate to providers list
  static void goToProviders(BuildContext context) {
    context.go(AppRouter.providersRoute);
  }

  /// Navigate to settings
  static void goToSettings(BuildContext context) {
    context.go(AppRouter.settingsRoute);
  }

  /// Navigate to onboarding
  static void goToOnboarding(BuildContext context) {
    context.go(AppRouter.onboardingRoute);
  }
}
