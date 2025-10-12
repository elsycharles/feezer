import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../util/navigation_util.dart';

/// Error screen displayed when a route is not found
class ErrorScreen extends StatelessWidget {
  final String? errorMessage;

  const ErrorScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              errorMessage ??
                  AppLocalizations.of(context).screenNotFound('Unknown'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  NavigationUtil.goTo(context, NavigationUtil.homeRoute),
              child: Text(AppLocalizations.of(context).goHome),
            ),
          ],
        ),
      ),
    );
  }
}
