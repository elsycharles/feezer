import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/provider_model.dart';
import '../../../util/theme_util.dart';
import '../../../util/icon_util.dart';

/// Animated provider tile with tap and long press feedback
class ProviderTile extends StatefulWidget {
  const ProviderTile({
    super.key,
    required this.provider,
    required this.isSelected,
    required this.showSelection,
    required this.onSelectionChanged,
    required this.onLongPress,
    this.onTap,
  });

  final Provider provider;
  final bool isSelected;
  final bool showSelection;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  @override
  State<ProviderTile> createState() => _ProviderTileState();
}

class _ProviderTileState extends State<ProviderTile>
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
                title: Text(
                  widget.provider.name,
                  style: ThemeUtil.bodyLarge.copyWith(color: ThemeUtil.textPrimary),
                ),
                subtitle: widget.provider.description.isNotEmpty
                    ? Text(
                        widget.provider.description,
                        style: ThemeUtil.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: null,
              ),
            ),
          ),
        ),
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

  Widget _buildLeading() => SizedBox(
        width: widget.showSelection ? 80 : 56,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showSelection) ...[
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: widget.isSelected,
                  onChanged: (value) => widget.onSelectionChanged(value ?? false),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
            ],
            CircleAvatar(
              backgroundColor: ThemeUtil.primaryColor,
              child: Icon(
                IconUtil.getIcon(widget.provider.iconName),
                color: ThemeUtil.textLight,
              ),
            ),
          ],
        ),
      );
}