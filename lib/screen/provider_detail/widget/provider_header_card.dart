import 'package:flutter/material.dart';
import '../../../model/provider_model.dart';
import '../../../util/theme_util.dart';
import '../../../util/icon_util.dart';

/// Provider header card showing provider info with optimize button
class ProviderHeaderCard extends StatelessWidget {
  final Provider provider;

  const ProviderHeaderCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeUtil.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeUtil.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (provider.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDescription(),
            ],
          ],
        ),
      );

  Widget _buildHeader() => Row(
        children: [
          CircleAvatar(
            backgroundColor: ThemeUtil.primaryColor,
            radius: 24,
            child: Icon(
              IconUtil.getIcon(provider.iconName),
              color: ThemeUtil.textLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: ThemeUtil.titleSmall,
                ),
                if (provider.description.isNotEmpty)
                  Text(
                    provider.description,
                    style: ThemeUtil.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          _buildOptimizeButton(),
        ],
      );

  Widget _buildDescription() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ThemeUtil.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          provider.description,
          style: ThemeUtil.bodyMedium.copyWith(
            color: ThemeUtil.textSecondary,
            height: 1.4,
          ),
        ),
      );

  Widget _buildOptimizeButton() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeUtil.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Optimize Fee',
          style: ThemeUtil.bodySmall.copyWith(
            color: ThemeUtil.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}