import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../util/theme_util.dart';

/// Animated contextual action bar for multi-selection
class SelectionActionBar extends StatefulWidget {
  const SelectionActionBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onDelete,
    required this.onEdit,
    required this.onDetails,
    this.margin = EdgeInsets.zero,
  });

  final int selectedCount;
  final int totalCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDetails;
  final EdgeInsetsGeometry margin;

  @override
  State<SelectionActionBar> createState() => _SelectionActionBarState();
}

class _SelectionActionBarState extends State<SelectionActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Transform.scale(
      scale: _scaleAnimation.value,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: Container(
          margin: widget.margin,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onClearSelection,
                icon: Icon(Icons.close, color: colorScheme.onPrimary),
                tooltip: AppLocalizations.of(context).clearSelection,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.selectedCount} ${AppLocalizations.of(context).selected}',
                style: ThemeUtil.labelLarge.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              const Spacer(),
              if (widget.selectedCount < widget.totalCount)
                IconButton(
                  onPressed: widget.onSelectAll,
                  icon: Icon(
                    Icons.select_all,
                    color: colorScheme.onPrimary,
                  ),
                  tooltip: 'Select all',
                ),
              if (widget.onDetails != null)
                IconButton(
                  onPressed: widget.onDetails,
                  icon: Icon(
                    Icons.info_outline,
                    color: colorScheme.onPrimary,
                  ),
                  tooltip: 'Details',
                ),
              if (widget.onEdit != null)
                IconButton(
                  onPressed: widget.onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.onPrimary,
                  ),
                  tooltip: 'Edit',
                ),
              IconButton(
                onPressed: widget.onDelete,
                icon: Icon(
                  Icons.delete_outlined,
                  color: colorScheme.onPrimary,
                ),
                tooltip: AppLocalizations.of(context).delete,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
