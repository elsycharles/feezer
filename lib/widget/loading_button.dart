import 'package:flutter/material.dart';
import '../util/theme_util.dart';
import 'app_loading.dart';

/// Loading button that shows loading state
/// Replaces PrimaryButton when loading state is needed
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(
                  foregroundColor ?? colorScheme.onSurfaceVariant,
                ),
                overlayColor: ThemeUtil.interactiveOverlay(
                  foregroundColor ?? colorScheme.onSurfaceVariant,
                ),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: foregroundColor ?? colorScheme.outlineVariant,
                  ),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                padding: WidgetStateProperty.all(padding),
                splashFactory: NoSplash.splashFactory,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const AppLoading.small()
                    : Text(
                        text,
                        key: ValueKey(text),
                        style: ThemeUtil.labelLarge.copyWith(
                          color: foregroundColor ?? colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ButtonStyle(
                backgroundColor: ThemeUtil.interactiveBackground(
                  backgroundColor ?? colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all(
                  foregroundColor ?? colorScheme.onPrimary,
                ),
                overlayColor: ThemeUtil.interactiveOverlay(
                  foregroundColor ?? colorScheme.onPrimary,
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                padding: WidgetStateProperty.all(padding),
                elevation: WidgetStateProperty.all(0),
                splashFactory: NoSplash.splashFactory,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const AppLoading.small()
                    : Text(
                        text,
                        key: ValueKey(text),
                        style: ThemeUtil.labelLarge.copyWith(
                          color: foregroundColor ?? colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
    );
  }
}