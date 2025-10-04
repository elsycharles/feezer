import 'package:flutter/material.dart';
import 'provider_tile.dart';

/// Provider list with separators
class ProviderListView extends StatelessWidget {
  final List<Map<String, String>> providers;
  final VoidCallback? onEditProvider;
  final VoidCallback? onDeleteProvider;

  const ProviderListView({
    super.key,
    required this.providers,
    this.onEditProvider,
    this.onDeleteProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        return ProviderTile(
          title: provider['name'] ?? '',
          logoPath: provider['logo'],
          onEdit: onEditProvider,
          onDelete: onDeleteProvider,
        );
      },
    );
  }
}