import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Lightweight elevated surface container reused across headers
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: ThemeUtil.surfaceLight,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
