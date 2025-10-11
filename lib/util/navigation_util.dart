import 'package:flutter/material.dart';
import '../screen/new_provider/new_provider_screen.dart';
import '../screen/fee_interval/new_fee_interval_screen.dart';

/// Navigation utilities for safe and consistent navigation throughout the app
class NavigationUtil {
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/';
  static const String providersRoute = '/providers';
  static const String settingsRoute = '/settings';
  static const String newProviderRoute = '/new-provider';
  static const String providerDetailRoute = '/provider';
  static const String newFeeIntervalRoute = '/new-fee-interval';
  /// Safe async navigation - captures context before async operation
  static Future<void> safeAsyncNavigate({
    required BuildContext context,
    required bool Function() isMounted,
    required Future<String> Function() getRoute,
  }) async {
    final route = await getRoute();
    if (isMounted()) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(route);
    }
  }

  /// Safely navigates back using Navigator. If no pages to pop, navigates to fallback route.
  /// 
  /// [context] - BuildContext for navigation
  /// [fallbackRoute] - Route to navigate to if stack is empty (defaults to home route)
  static Future<void> safeBack(BuildContext context, {String? fallbackRoute}) async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushNamedAndRemoveUntil(fallbackRoute ?? NavigationUtil.homeRoute, (route) => false);
  }

  /// Safely pops with a result using Navigator. If no pages to pop, navigates to fallback route.
  /// 
  /// [context] - BuildContext for navigation
  /// [result] - Result to return when popping
  /// [fallbackRoute] - Route to navigate to if stack is empty (defaults to home route)
  static void safeBackWithResult<T>(BuildContext context, T result, {String? fallbackRoute}) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop<T>(result);
      return;
    }
    navigator.pushNamedAndRemoveUntil(fallbackRoute ?? NavigationUtil.homeRoute, (route) => false);
  }


  NavigationUtil._();

  /// Navigate (replace) to [route]
  static void goTo(BuildContext context, String route, {Object? extra}) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false, arguments: extra);
  }

  /// Push [route] on stack and optionally return a result
  static Future<T?> pushTo<T>(BuildContext context, String route, {Object? extra}) {
    // For routes that return values, use push with MaterialPageRoute
    if (route == newProviderRoute) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute<T>(
          builder: (_) => const NewProviderScreen(),
          settings: RouteSettings(name: route, arguments: extra),
        ),
      );
    }
    if (route == newFeeIntervalRoute) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute<T>(
          builder: (_) => const NewFeeIntervalScreen(),
          settings: RouteSettings(name: route, arguments: extra),
        ),
      );
    }
    // For other routes, use pushNamed
    return Navigator.of(context).pushNamed<T>(route, arguments: extra);
  }

  /// Build route with id: baseRoute + '/' + id
  static String buildIdRoute(String baseRoute, String id) => '$baseRoute/$id';
}
