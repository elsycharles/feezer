import 'package:flutter/material.dart';
import '../../../styles/global.dart';
import '../../../util/theme_util.dart';
import '../../../widget/provider_brand_avatar.dart';
import '../../../widget/provider_stat_chip.dart';
import '../../../widget/surface_card.dart';

/// Provider overview card matching detail screen styling
class ProviderHeader extends StatelessWidget {
  const ProviderHeader({super.key, required this.providerCount});

  final int providerCount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProviderBrandAvatar(iconName: 'group', size: 52),
              Global.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage your providers',
                      style: ThemeUtil.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Centralize bank and mobile money partners in one place.',
                      style: ThemeUtil.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Global.gapLg,
          ProviderStatChip(
            icon: Icons.people_alt,
            label: 'Active provider${providerCount == 1 ? '' : 's'}',
            value: '$providerCount',
          ),
        ],
      ),
    ),
  );
}
