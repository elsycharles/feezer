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
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            decoration: BoxDecoration(
              color: ThemeUtil.interactiveSurfaceColor(
                isSelected
                    ? ThemeUtil.primaryColor.withValues(alpha: 0.08)
                    : ThemeUtil.surfaceLight,
                hovered: hovered,
                pressed: pressed,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ThemeUtil.primaryColor
                    : ThemeUtil.textSecondary.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeUtil.textSecondary.withValues(
                    alpha: hovered || pressed ? 0.12 : 0.08,
                  ),
                  blurRadius: hovered || pressed ? 10 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (showSelection) _buildCheckbox(),
                Expanded(child: _buildContent()),
                _buildFeeChip(),
              ],
            ),
          ),
        ),
      );

  Widget _buildCheckbox() => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Checkbox(
          value: isSelected,
          onChanged: (value) => onSelectionChanged(value ?? false),
          visualDensity: VisualDensity.compact,
          activeColor: ThemeUtil.primaryColor,
        ),
      );

  Widget _buildContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatAmountRange(),
            style: ThemeUtil.titleSmall.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(feeInterval.creationDatetime ?? DateTime.now()),
            style: ThemeUtil.bodySmall.copyWith(color: ThemeUtil.textSecondary),
          ),
        ],
      );

  Widget _buildFeeChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeUtil.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeUtil.success.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          '${_formatFee(feeInterval.fee ?? 0)} Ar',
          style: ThemeUtil.labelMedium.copyWith(
            color: ThemeUtil.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  String _formatAmountRange() {
    final min = (feeInterval.minAmount ?? 0).toInt();
    final max = (feeInterval.maxAmount ?? 0).toInt();
    return '$min - $max Ar';
  }

  String _formatFee(double fee) => fee.toInt().toString();

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}