import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/provider_model.dart';
import '../../../util/theme_util.dart';
import '../../../styles/global.dart';
import '../../../widget/provider_brand_avatar.dart';
import '../../../widget/provider_stat_chip.dart';
import '../../../widget/surface_card.dart';
import '../../../widget/loading_button.dart';

/// Clean provider header card with optimize button
class ProviderHeaderCard extends StatefulWidget {
  final Provider provider;
  final VoidCallback? onOptimize;

  const ProviderHeaderCard({
    super.key,
    required this.provider,
    this.onOptimize,
  });

  @override
  State<ProviderHeaderCard> createState() => _ProviderHeaderCardState();
}

class _ProviderHeaderCardState extends State<ProviderHeaderCard> {
  bool _isOptimizing = false;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildHeader(), Global.gapLg, _buildStats()],
    ),
  );

  Widget _buildHeader() => Row(
    children: [
      ProviderBrandAvatar(iconName: widget.provider.iconName),
      const SizedBox(width: 16),
      Expanded(child: _buildProviderInfo()),
      LoadingButton(
        text: AppLocalizations.of(context).feeOptimizer,
        onPressed: _optimizeFees,
        isLoading: _isOptimizing,
        isFullWidth: false,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ],
  );

  Widget _buildProviderInfo() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.provider.name,
          style: ThemeUtil.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        if (widget.provider.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.provider.description,
            style: ThemeUtil.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats() => ProviderStatChip(
    icon: Icons.receipt_long,
    label: AppLocalizations.of(context).totalFeeIntervals,
    value: '5',
  );

  void _optimizeFees() async {
    if (_isOptimizing) return;

    HapticFeedback.lightImpact();
    setState(() => _isOptimizing = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isOptimizing = false);
      widget.onOptimize?.call();
    }
  }
}
