import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/fee_interval_model.dart';
import '../../../util/theme_util.dart';
import '../../../widget/interactive_surface.dart';

/// Fee interval tile with subtle hover feedback
class FeeIntervalTile extends StatelessWidget {
  const FeeIntervalTile({
    super.key,
    required this.feeInterval,
    required this.isSelected,
    required this.showSelection,
    required this.onSelectionChanged,
    required this.onLongPress,
    this.onTap,
  });

  final FeeInterval feeInterval;
  final bool isSelected;
  final bool showSelection;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: InteractiveSurface(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress();
        },
        builder: (context, hovered, pressed) => AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          // Ensure minimum height for accessibility
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: ThemeUtil.interactiveSurfaceColor(
              isSelected
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : colorScheme.surface,
              hovered: hovered,
              pressed: pressed,
              overlayColor: colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: hovered || pressed ? 0.16 : 0.08,
                ),
                blurRadius: hovered || pressed ? 10 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showSelection) _buildCheckbox(colorScheme),
              Expanded(child: _buildContent(colorScheme)),
              _buildFeeChip(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(ColorScheme colorScheme) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Checkbox(
      value: isSelected,
      onChanged: (value) => onSelectionChanged(value ?? false),
      visualDensity: VisualDensity.compact,
      activeColor: colorScheme.primary,
    ),
  );

  Widget _buildContent(ColorScheme colorScheme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        feeInterval.formattedRange,
        style: ThemeUtil.titleSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        _formatDate(feeInterval.creationDatetime),
        style: ThemeUtil.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );

  Widget _buildFeeChip(ColorScheme colorScheme) => Text(
    feeInterval.formattedFee,
    style: ThemeUtil.bodyMedium.copyWith(
      color: ThemeUtil.success,
      fontWeight: FontWeight.w600,
    ),
    textAlign: TextAlign.center,
  );

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
