import 'package:flutter/material.dart';

import '../model/provider_model.dart';
import '../screen/home/home_shell.dart';
import '../screen/providers/provider_form.dart';

/// Route names and navigation helpers.
abstract final class NavigationUtil {
  static const String homeRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String providerDetailRoute = '/provider';
  static const String dataRoute = '/data';
  static const String helpRoute = '/help';
  static const String termsRoute = '/terms';

  /// Key of the tab shell, to switch tabs from pushed screens.
  static final GlobalKey<HomeShellState> shellKey = GlobalKey<HomeShellState>();

  static Future<void> openProvider(BuildContext context, Provider provider) =>
      Navigator.of(context).pushNamed(providerDetailRoute, arguments: provider);

  /// Creates a provider, then opens it so its fee grid can be filled.
  static Future<void> openNewProvider(BuildContext context) async {
    final provider = await showProviderForm(context);
    if (provider != null && context.mounted) {
      await openProvider(context, provider);
    }
  }

  /// Goes back to the optimizer tab with [provider] selected.
  static void optimizeWith(BuildContext context, Provider provider) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    shellKey.currentState?.optimizeWith(provider);
  }
}
