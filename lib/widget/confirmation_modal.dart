import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Modern confirmation modal with consistent design
class ConfirmationModal {
  static Future<bool?> show(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _Dialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
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
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeUtil.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildMessage(),
          const SizedBox(height: 24),
          _buildActions(context),
        ],
      ),
    ),
  );

  Widget _buildHeader() => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: ThemeUtil.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.warning_rounded,
          color: ThemeUtil.error,
          size: 24,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(child: Text(title, style: ThemeUtil.titleSmall)),
    ],
  );

  Widget _buildMessage() => Text(
    message,
    style: ThemeUtil.bodyMedium.copyWith(
      color: ThemeUtil.textSecondary,
      height: 1.4,
    ),
    textAlign: TextAlign.left,
  );

  Widget _buildActions(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(ThemeUtil.textSecondary),
            overlayColor: ThemeUtil.interactiveOverlay(ThemeUtil.textSecondary),
            side: WidgetStateProperty.all(
              BorderSide(color: ThemeUtil.textSecondary.withValues(alpha: 0.3)),
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
            style: ThemeUtil.bodyLarge.copyWith(color: ThemeUtil.textSecondary),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ButtonStyle(
            backgroundColor: ThemeUtil.interactiveBackground(ThemeUtil.error),
            foregroundColor: WidgetStateProperty.all(ThemeUtil.textLight),
            overlayColor: ThemeUtil.interactiveOverlay(ThemeUtil.textLight),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 14),
            ),
            elevation: WidgetStateProperty.all(0),
            splashFactory: NoSplash.splashFactory,
          ),
          child: Text(confirmText, style: ThemeUtil.labelLarge),
        ),
      ),
    ],
  );
}
