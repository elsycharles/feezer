import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  static Future<void> safeBack(BuildContext context, {String? fallbackRoute}) async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    context.go(fallbackRoute ?? AppRouter.optimizeFeeRoute);
  }

  /// Safely pops with a result using GoRouter. If no pages to pop, navigates to fallback route.
  /// 
  /// [context] - BuildContext for navigation
  /// [result] - Result to return when popping
  /// [fallbackRoute] - Route to navigate to if stack is empty (defaults to providers route)
  static void safeBackWithResult<T>(BuildContext context, T result, {String? fallbackRoute}) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop<T>(result);
      return;
    }
    context.go(fallbackRoute ?? AppRouter.optimizeFeeRoute);
  }


  NavigationUtil._();

  /// Navigate (replace) to [route]
  static void goTo(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  /// Push [route] on stack and optionally return a result
  static Future<T?> pushTo<T>(BuildContext context, String route, {Object? extra}) {
    return context.push<T>(route, extra: extra);
  }

  /// Build route with id: baseRoute + '/' + id
  static String buildIdRoute(String baseRoute, String id) => '$baseRoute/$id';
}
