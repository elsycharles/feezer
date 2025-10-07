import 'package:flutter/material.dart';
import '../styles/global.dart';
import '../util/extensions_util.dart';

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
      color: context.colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: Global.shadowMd,
    ),
    child: child,
  );
}
