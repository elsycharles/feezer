import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../util/theme_util.dart';

/// Modern confirmation modal with consistent design
class ConfirmationModal {
  static Future<bool?> show(
    BuildContext context,
    String title,
    String message, {
    String? confirmText,
    String? cancelText,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _Dialog(
      title: title,
      message: message,
      confirmText: confirmText ?? AppLocalizations.of(ctx).delete,
      cancelText: cancelText ?? AppLocalizations.of(ctx).cancel,
    ),
  );
}

class _Dialog extends StatelessWidget {
  const _Dialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 16),
            _buildMessage(colorScheme),
            const SizedBox(height: 24),
            _buildActions(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.warning_rounded,
          color: colorScheme.error,
          size: 24,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          title,
          style: ThemeUtil.titleSmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );

  Widget _buildMessage(ColorScheme colorScheme) => Text(
        message,
        style: ThemeUtil.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        textAlign: TextAlign.left,
      );

  Widget _buildActions(BuildContext context, ColorScheme colorScheme) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: ButtonStyle(
            foregroundColor:
                WidgetStateProperty.all(colorScheme.onSurfaceVariant),
            overlayColor: ThemeUtil.interactiveOverlay(
              colorScheme.onSurfaceVariant,
            ),
            side: WidgetStateProperty.all(
              BorderSide(color: colorScheme.outlineVariant),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 14),
            ),
            splashFactory: NoSplash.splashFactory,
          ),
          child: Text(
            cancelText,
            style: ThemeUtil.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ButtonStyle(
            backgroundColor: ThemeUtil.interactiveBackground(colorScheme.error),
            foregroundColor: WidgetStateProperty.all(colorScheme.onError),
            overlayColor: ThemeUtil.interactiveOverlay(colorScheme.onError),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 14),
            ),
            elevation: WidgetStateProperty.all(0),
            splashFactory: NoSplash.splashFactory,
          ),
          child: Text(
            confirmText,
            style: ThemeUtil.labelLarge.copyWith(color: colorScheme.onError),
          ),
        ),
      ),
    ],
  );
}
