import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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
}
