import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/fee_interval_model.dart';
import '../../../util/theme_util.dart';

/// Animated fee interval tile with selection support
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
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: ThemeUtil.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ListTile(
                leading: _buildLeading(),
                title: _buildContent(),
                trailing: null,
              ),
            ),
          ),
        ),
      );

  Widget? _buildLeading() => widget.showSelection
        ? Checkbox(
            value: widget.isSelected,
            onChanged: (value) => widget.onSelectionChanged(value ?? false),
            visualDensity: VisualDensity.compact,
          )
        : null;

  Widget _buildContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Interval', style: ThemeUtil.bodyLarge),
              const Spacer(),
              Text('Fee', style: ThemeUtil.bodyLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${widget.feeInterval.minAmount ?? 0} - ${widget.feeInterval.maxAmount ?? 0}',
                style: ThemeUtil.bodyMedium.copyWith(color: ThemeUtil.textSecondary),
              ),
              const Spacer(),
              Text(
                '${widget.feeInterval.fee ?? 0} Ar',
                style: ThemeUtil.bodyLarge.copyWith(
                  color: ThemeUtil.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(widget.feeInterval.creationDatetime ?? DateTime.now()),
            style: ThemeUtil.bodySmall,
          ),
        ],
      );

  Color _getBackgroundColor() {
    if (_isPressed) return ThemeUtil.primaryColor.withValues(alpha: 0.15);
    if (widget.isSelected) return ThemeUtil.primaryColor.withValues(alpha: 0.1);
    return ThemeUtil.surfaceLight;
  }

  Color _getBorderColor() {
    if (_isPressed) return ThemeUtil.primaryColor;
    if (widget.isSelected) return ThemeUtil.primaryColor;
    return ThemeUtil.textSecondary.withValues(alpha: 0.3);
  }

  String _formatDate(DateTime date) =>
      '${_monthName(date.month)} ${date.day}, ${date.year}';

  String _monthName(int month) => [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][month - 1];
}