import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Reusable empty state for search lists
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            title,
            style: ThemeUtil.bodyMedium.copyWith(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          if (message?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              style: ThemeUtil.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
