import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/fee_interval_model.dart';
import '../../../util/theme_util.dart';

/// Modern fee interval tile with clean design and animations
class FeeIntervalTile extends StatefulWidget {
  final FeeInterval feeInterval;
  final bool isSelected;
  final bool showSelection;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  const FeeIntervalTile({
    super.key,
    required this.feeInterval,
    required this.isSelected,
    required this.showSelection,
    required this.onSelectionChanged,
    required this.onLongPress,
    this.onTap,
  });

  @override
  State<FeeIntervalTile> createState() => _FeeIntervalTileState();
}

class _FeeIntervalTileState extends State<FeeIntervalTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    widget.onLongPress();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            onLongPress: _onLongPress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getBorderColor(),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: _isPressed ? _getPressedShadow() : _getDefaultShadow(),
              ),
              child: Row(
                children: [
                  if (widget.showSelection) _buildCheckbox(),
                  Expanded(child: _buildContent()),
                  _buildFeeChip(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildCheckbox() => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Checkbox(
          value: widget.isSelected,
          onChanged: (value) => widget.onSelectionChanged(value ?? false),
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
            style: ThemeUtil.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(widget.feeInterval.creationDatetime ?? DateTime.now()),
            style: ThemeUtil.bodySmall.copyWith(
              color: ThemeUtil.textSecondary,
            ),
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
          '${_formatFee(widget.feeInterval.fee ?? 0)} Ar',
          style: ThemeUtil.labelLarge.copyWith(
            color: ThemeUtil.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // Helper methods
  String _formatAmountRange() {
    final min = (widget.feeInterval.minAmount ?? 0).toInt();
    final max = (widget.feeInterval.maxAmount ?? 0).toInt();
    return '$min - $max Ar';
  }

  String _formatFee(double fee) => fee.toInt().toString();

  String _formatDate(DateTime date) => 
      '${date.day}/${date.month}/${date.year}';

  Color _getBackgroundColor() {
    if (_isPressed) return ThemeUtil.primaryColor.withValues(alpha: 0.08);
    if (widget.isSelected) return ThemeUtil.primaryColor.withValues(alpha: 0.05);
    return ThemeUtil.surfaceLight;
  }

  Color _getBorderColor() {
    if (_isPressed || widget.isSelected) return ThemeUtil.primaryColor;
    return ThemeUtil.textSecondary.withValues(alpha: 0.2);
  }

  List<BoxShadow> _getDefaultShadow() => [
        BoxShadow(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.08),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  List<BoxShadow> _getPressedShadow() => [
        BoxShadow(
          color: ThemeUtil.primaryColor.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
}