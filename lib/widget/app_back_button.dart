import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Consistent back button used across the application.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.semanticLabel});

  /// Callback invoked when the button is pressed.
  /// Defaults to [NavigationUtil.safeBack].
  final VoidCallback? onPressed;

  /// Optional semantic label for accessibility screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed ?? () => GoRouter.of(context).pop(),
          splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
          highlightColor: colorScheme.onSurface.withValues(alpha: 0.05),
          hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Semantics(
              button: true,
              label: semanticLabel,
              child: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
