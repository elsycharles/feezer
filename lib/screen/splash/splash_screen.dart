import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fee_minimizer/util/route_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/util/constante_util.dart';
import 'package:fee_minimizer/widget/app_logo.dart';
import 'package:fee_minimizer/widget/app_title.dart';
import 'package:fee_minimizer/widget/animated_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    _controller = AnimationController(duration: ConstanteUtil.animationDuration, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  void _startSequence() {
    _controller.forward();
    Future.delayed(ConstanteUtil.splashDuration, _navigateToHome);
  }

  void _navigateToHome() {
    if (mounted) context.go(AppRouter.homeRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ThemeUtil.primaryGradient),
        child: Center(
          child: AnimatedLogo(
            fadeAnimation: _fadeAnimation,
            scaleAnimation: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(),
                const SizedBox(height: 30),
                AppTitle(subtitle: ConstanteUtil.appTagline),
                const SizedBox(height: 50),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}