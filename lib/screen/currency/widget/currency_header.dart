import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../styles/global.dart';
import '../../../util/theme_util.dart';
import '../../../widget/surface_card.dart';

/// Currency overview card matching detail screen styling
class CurrencyHeader extends StatelessWidget {
  const CurrencyHeader({
    super.key,
    required this.totalCount,
    required this.filteredCount,
    required this.selectedCount,
  });

  final int totalCount;
  final int filteredCount;
  final int selectedCount;

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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.currency_exchange,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                Global.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).manageYourCurrencies,
                        style: ThemeUtil.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).centralizeCurrencies,
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
            Row(
              children: [
                _buildStatChip(
                  context,
                  AppLocalizations.of(context).totalCurrencies,
                  totalCount.toString(),
                  colorScheme.primary,
                ),
                if (selectedCount > 0) ...[
                  Global.gapSm,
                  _buildStatChip(
                    context,
                    AppLocalizations.of(context).activeCurrencies,
                    selectedCount.toString(),
                    colorScheme.secondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: ThemeUtil.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: ThemeUtil.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
