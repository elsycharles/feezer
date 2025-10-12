import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// A reusable widget that wraps content with pull-to-refresh functionality
class RefreshableScreen extends StatefulWidget {
  const RefreshableScreen({
    super.key,
    required this.child,
    required this.onRefresh,
    this.scrollController,
    this.physics,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  @override
  State<RefreshableScreen> createState() => _RefreshableScreenState();
}

class _RefreshableScreenState extends State<RefreshableScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: ThemeUtil.primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      displacement: 40,
      strokeWidth: 3,
      child: widget.child,
    );
  }
}

/// Extension method to easily wrap any scrollable widget with refresh functionality
extension RefreshableExtension on Widget {
  Widget withRefresh({
    required Future<void> Function() onRefresh,
    ScrollController? scrollController,
    ScrollPhysics? physics,
  }) {
    return RefreshableScreen(
      onRefresh: onRefresh,
      scrollController: scrollController,
      physics: physics,
      child: this,
    );
  }
}