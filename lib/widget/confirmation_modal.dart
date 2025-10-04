import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Reusable confirmation modal for delete and other actions
class ConfirmationModal {
  static Future<bool?> show(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) =>
      showDialog<bool>(
        context: context,
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
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ThemeUtil.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning, color: ThemeUtil.error),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: ThemeUtil.titleSmall,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: ThemeUtil.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeUtil.error,
              foregroundColor: ThemeUtil.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      );
}