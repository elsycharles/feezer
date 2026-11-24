import 'package:flutter/material.dart';

/// Navigation utilities for safe and consistent navigation throughout the app
class NavigationUtil {
  /// Lets screens know when they become visible again (see [RouteAware]).
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/';
  static const String providersRoute = '/providers';
  static const String settingsRoute = '/settings';
  static const String newProviderRoute = '/new-provider';
  static const String providerDetailRoute = '/provider';
  static const String newFeeIntervalRoute = '/new-fee-interval';
  static const String currenciesRoute = '/currencies';
  static const String newCurrencyRoute = '/new-currency';
  static const String csvManagementRoute = '/csv-management';
  static const String helpSupportRoute = '/help-support';
  static const String termsOfUseRoute = '/terms-of-use';

  /// Safely pops with a result using Navigator. If no pages to pop, navigates to fallback route.
  ///
  /// [context] - BuildContext for navigation
  /// [result] - Result to return when popping
  /// [fallbackRoute] - Route to navigate to if stack is empty (defaults to home route)
  static void safeBackWithResult<T>(
    BuildContext context,
    T result, {
    String? fallbackRoute,
  }) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop<T>(result);
      return;
    }
    navigator.pushNamedAndRemoveUntil(
      fallbackRoute ?? NavigationUtil.homeRoute,
      (route) => false,
    );
  }

  NavigationUtil._();

  /// Navigate (replace) to [route]
  static void goTo(BuildContext context, String route, {Object? extra}) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(route, (route) => false, arguments: extra);
  }

  /// Pushes [route] and returns its result. Routes producing a result are
  /// declared with their type in `MyApp.onGenerateRoute`.
  static Future<T?> pushTo<T>(
    BuildContext context,
    String route, {
    Object? extra,
  }) => Navigator.of(context).pushNamed<T>(route, arguments: extra);
}
