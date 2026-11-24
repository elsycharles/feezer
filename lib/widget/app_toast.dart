import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum ToastType { success, error, warning, info }

/// Short message shown at the top of the screen, above every route and
/// modal sheet. A new toast replaces the previous one.
class AppToast {
  const AppToast._();

  static OverlayEntry? _current;
  static GlobalKey<_ToastState>? _key;
  static Timer? _timer;

  static void success(BuildContext context, String message) =>
      show(context, message, type: ToastType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: ToastType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: ToastType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message, type: ToastType.info);

  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _removeNow();
    final key = GlobalKey<_ToastState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Toast(
        key: key,
        message: message,
        type: type,
        onDismiss: () => _hide(entry),
      ),
    );
    _current = entry;
    _key = key;
    overlay.insert(entry);
    _timer = Timer(
      Duration(milliseconds: 2600 + message.length * 25),
      () => _hide(entry),
    );
  }

  /// Plays the exit animation, then removes [entry].
  static void _hide(OverlayEntry entry) {
    if (!identical(_current, entry)) return;
    _timer?.cancel();
    _timer = null;
    final state = _key?.currentState;
    if (state == null) {
      _removeNow();
      return;
    }
    state.hide().whenComplete(() {
      if (identical(_current, entry)) _removeNow();
    });
  }

  static void _removeNow() {
    _timer?.cancel();
    _timer = null;
    final entry = _current;
    _current = null;
    _key = null;
    if (entry != null && entry.mounted) entry.remove();
  }
}

class _Toast extends StatefulWidget {
  const _Toast({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 180),
  )..forward();
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  Future<void> hide() =>
      _controller.reverse().orCancel.catchError((Object _) {});

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _curve,
    builder: (context, child) => Opacity(
      opacity: _curve.value,
      child: Transform.translate(
        offset: Offset(0, -16 * (1 - _curve.value)),
        child: child,
      ),
    ),
    child: _ToastBody(
      message: widget.message,
      type: widget.type,
      onDismiss: widget.onDismiss,
    ),
  );
}

class _ToastBody extends StatelessWidget {
  const _ToastBody({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    final (icon, accent) = switch (type) {
      ToastType.success => (Icons.check_circle_rounded, palette.success),
      ToastType.error => (Icons.error_rounded, colors.error),
      ToastType.warning => (Icons.warning_rounded, palette.warning),
      ToastType.info => (Icons.info_rounded, colors.inversePrimary),
    };
    final radius = BorderRadius.circular(Space.radiusMd);
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, 0),
          child: Material(
            color: colors.inverseSurface,
            elevation: 6,
            shadowColor: Colors.black38,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: onDismiss,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.lg,
                    vertical: Space.md,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: accent, size: 22),
                      Space.gapMd,
                      Flexible(
                        child: Text(
                          message,
                          style: context.text.bodyMedium?.copyWith(
                            color: colors.onInverseSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
