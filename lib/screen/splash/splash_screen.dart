import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fee_minimizer/util/route_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/util/constante_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _loadingController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: ConstanteUtil.fadeAnimationDuration,
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: ConstanteUtil.loadingAnimationDuration,
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );
  }

  void _startSequence() {
    _controller.forward();
    Future.delayed(ConstanteUtil.splashDuration, _navigateToHome);
  }

  void _navigateToHome() {
    if (mounted) context.go(AppRouter.onboardingRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeUtil.primaryColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Main content centered
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ConstanteUtil.appName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Simple loading with 3 dots
                    AnimatedBuilder(
                      animation: _loadingAnimation,
                      builder: (context, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            final delay = index * 0.3;
                            final animValue = (_loadingAnimation.value + delay) % 1.0;
                            final opacity = animValue < 0.5 
                                ? (animValue * 2) 
                                : (2 - animValue * 2);
                            
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Opacity(
                                opacity: 0.3 + (opacity * 0.7),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Description at bottom
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                ConstanteUtil.appTagline,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}