import 'package:flutter/material.dart';
import 'app_loading.dart';

/// Full screen loading page with Scaffold
/// Used for entire screen loading states
class AppLoadingPage extends StatelessWidget {
  const AppLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const AppLoading.overlay(),
    );
  }
}
