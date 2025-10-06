import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../util/theme_util.dart';

/// Reusable widget to handle double back press logic to exit the application
class DoubleBackToExit extends StatefulWidget {
  final Widget child;
  final String message;

  const DoubleBackToExit({
    super.key,
    required this.child,
    this.message = 'Press again to exit',
  });

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _onBackPressed(context),
      child: widget.child,
    );
  }

  void _onBackPressed(BuildContext context) async {
    final now = DateTime.now();
    const exitTimeLimit = Duration(seconds: 2);

    if (_lastPressed == null || now.difference(_lastPressed!) > exitTimeLimit) {
      _lastPressed = now;
      ThemeUtil.showSnackBar(context, widget.message);
    } else {
      SystemNavigator.pop();
    }
  }
}