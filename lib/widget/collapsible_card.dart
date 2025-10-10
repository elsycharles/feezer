import 'package:flutter/material.dart';
import '../styles/global.dart';
import '../util/theme_util.dart';
import 'surface_card.dart';

/// A reusable collapsible card widget that can expand/collapse content
class CollapsibleCard extends StatefulWidget {
  const CollapsibleCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.titleStyle,
    this.subtitleStyle,
    this.isInitiallyExpanded = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.onExpandedChanged,
  });

  /// Title text displayed in the header
  final String title;
  
  /// Optional subtitle text displayed below title
  final String? subtitle;
  
  /// Optional icon displayed before the title
  final IconData? icon;
  
  /// Color for the icon and expand/collapse icon
  final Color? iconColor;
  
  /// Custom style for the title text
  final TextStyle? titleStyle;
  
  /// Custom style for the subtitle text
  final TextStyle? subtitleStyle;
  
  /// Content widgets displayed when expanded
  final List<Widget> children;
  
  /// Whether the card is initially expanded
  final bool isInitiallyExpanded;
  
  /// Padding inside the card
  final EdgeInsets padding;
  
  /// Margin around the card
  final EdgeInsets margin;
  
  /// Callback when expanded state changes
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpandedChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultIconColor = widget.iconColor ?? colorScheme.primary;
    
    // Use title color for collapse icon
    final titleColor = widget.titleStyle?.color ?? colorScheme.onSurface;
    final collapseIconColor = titleColor;

    return Container(
      margin: widget.margin,
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and expand/collapse functionality
            GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                padding: widget.padding,
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: defaultIconColor,
                      ),
                      Global.gapSm,
                    ],
                    Expanded(
                      child: Column(
                        // Support RTL layouts properly
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: widget.titleStyle ?? 
                              ThemeUtil.titleMedium.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            // Add textDirection for better RTL support
                            textDirection: TextDirection.ltr,
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              widget.subtitle!,
                              style: widget.subtitleStyle ??
                                ThemeUtil.bodyMedium.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: collapseIconColor,
                    ),
                  ],
                ),
              ),
            ),
            
            // Collapsible content
            if (_isExpanded) ...[
              Container(
                padding: EdgeInsets.only(
                  left: widget.padding.left,
                  right: widget.padding.right,
                  bottom: widget.padding.bottom,
                  top: 8, // Reduced top spacing since header already has padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.children,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}