import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
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
                        AppLocalizations.of(context).manageYourProviders,
                        style: ThemeUtil.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).centralizeProviders,
                        style: ThemeUtil.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Global.gapLg,
            ProviderStatChip(
              icon: Icons.people_alt,
              label: providerCount == 1 
                  ? AppLocalizations.of(context).activeProvider
                  : AppLocalizations.of(context).activeProviders,
              value: '$providerCount',
            ),
          ],
        ),
      ),
    );
  }
}
