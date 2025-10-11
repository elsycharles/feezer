import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Enum for toast types
enum ToastType { success, error, info, warning }

/// Custom toast widget with beautiful design
class AppToast extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const AppToast({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    required this.onDismiss,
  });

  /// Static method to show toast with theme-based styling
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    late Color backgroundColor;
    late Color textColor;
    late Color borderColor;
    late IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = ThemeUtil.success.withValues(alpha: 0.95);
        textColor = Colors.white;
        borderColor = ThemeUtil.success;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = ThemeUtil.error.withValues(alpha: 0.95);
        textColor = Colors.white;
        borderColor = ThemeUtil.error;
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = ThemeUtil.warning.withValues(alpha: 0.95);
        textColor = Colors.white;
        borderColor = ThemeUtil.warning;
        icon = Icons.warning;
        break;
      case ToastType.info:
        backgroundColor = isDark
            ? colorScheme.surface.withValues(alpha: 0.98)
            : colorScheme.surface.withValues(alpha: 0.98);
        textColor = colorScheme.onSurface;
        borderColor = colorScheme.primary.withValues(alpha: 0.3);
        icon = Icons.info;
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AppToast(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderColor: borderColor,
        icon: icon,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Convenience methods for specific toast types
  static void success(BuildContext context, String message) {
    show(context, message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: ToastType.info);
  }

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      bottom: mediaQuery.padding.bottom + 75,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: widget.borderColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.textColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: ThemeUtil.bodyMedium.copyWith(
                        color: widget.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                    child: Icon(
                      Icons.close,
                      color: widget.textColor.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
