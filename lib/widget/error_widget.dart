import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../util/route_util.dart';

/// Error screen displayed when a route is not found
class ErrorScreen extends StatelessWidget {
  final GoRouterState state;

  const ErrorScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLocation = state.uri.toString();
    final isOnHomePage = currentLocation == AppRouter.homeRoute || currentLocation == AppRouter.onboardingRoute;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).error),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).screenNotFound(state.uri.toString()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (!isOnHomePage)
              ElevatedButton(
                onPressed: () => context.go(AppRouter.homeRoute),
                child: Text(AppLocalizations.of(context).goHome),
              ),
          ],
        ),
      ),
    );
  }
}