import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/provider_model.dart';
import '../../../widget/provider_card.dart';

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
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
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
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ProviderCard(
                provider: widget.provider,
                showCheckbox: widget.showSelection,
                isSelected: widget.isSelected,
                onSelectionChanged: widget.onSelectionChanged,
                showDescription: true,
              ),
            ),
          ),
        ),
      );

}