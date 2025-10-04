import 'package:fee_minimizer/screen/home/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class AppRouter {

  static const String homeRoute = '/';

  static final GoRouter router = GoRouter(
    initialLocation: homeRoute,
    debugLogDiagnostics: true,

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Screen ${state.uri.toString()} not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(homeRoute),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    ),

    routes: [
      GoRoute(
        path: homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}