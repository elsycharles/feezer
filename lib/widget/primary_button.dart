import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Reusable primary button with consistent style
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isFullWidth = true,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: ThemeUtil.interactiveBackground(
            ThemeUtil.primaryColor,
          ),
          foregroundColor: WidgetStateProperty.all(ThemeUtil.textLight),
          overlayColor: ThemeUtil.interactiveOverlay(ThemeUtil.textLight),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: WidgetStateProperty.all(padding),
          elevation: WidgetStateProperty.all(0),
          splashFactory: NoSplash.splashFactory,
        ),
        child: Text(text, style: ThemeUtil.labelLarge),
      ),
    );
  }
}
