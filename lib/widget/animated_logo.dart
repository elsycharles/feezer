import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final Widget child;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  
  const AnimatedLogo({
    super.key,
    required this.child,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
}