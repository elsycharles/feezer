import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widget/feezer_logo.dart';

/// Launch screen of the app: shown from the very first frame, it plays the
/// logo animation while the app gets ready ([ready]), then builds the app
/// below and fades away.
///
/// - The system launch screen is plain (same background, no logo), so the
///   animation starts from an empty screen.
/// - The logo starts assembling a moment after the first frame, once the
///   system launch screen has gone, so the whole animation is seen.
/// - The app is only built once the logo is complete: its first, heavier
///   frames never stutter the animation.
/// - With reduced motion, the logo shows at once and the app replaces it.
class LaunchSplash<T> extends StatelessWidget {
  const LaunchSplash({super.key, required this.ready, required this.builder});

  /// Work to finish before the app is shown (preferences, data…).
  final Future<T> ready;

  /// The app, built with the result of [ready].
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) => MediaQuery.fromView(
    view: View.of(context),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: _Launch<T>(ready: ready, builder: builder),
    ),
  );
}

class _Launch<T> extends StatefulWidget {
  const _Launch({required this.ready, required this.builder});

  final Future<T> ready;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<_Launch<T>> createState() => _LaunchState<T>();
}

class _LaunchState<T> extends State<_Launch<T>> with TickerProviderStateMixin {
  /// Wait after the first frame, while the system launch screen goes away.
  static const _startDelay = Duration(milliseconds: 120);

  /// Pause on the complete logo once the app is built below it.
  static const _hold = Duration(milliseconds: 60);

  late final AnimationController _assembly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 820),
  )..addStatusListener(_onAssembly);
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..addStatusListener(_onExit);

  T? _value;
  bool _ready = false;
  bool _appBuilt = false;
  bool _done = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    widget.ready.then((value) {
      if (!mounted) return;
      _value = value;
      _ready = true;
      _maybeBuildApp();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(_startDelay, () {
        if (mounted && !_reducedMotion) _assembly.forward();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion && !_assembly.isCompleted) _assembly.value = 1;
  }

  @override
  void dispose() {
    _assembly.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _onAssembly(AnimationStatus status) {
    if (status == AnimationStatus.completed) _maybeBuildApp();
  }

  void _onExit(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _done = true);
    }
  }

  /// Builds the app below the logo once both are ready, then reveals it.
  void _maybeBuildApp() {
    if (_appBuilt || !_ready || !_assembly.isCompleted || !mounted) return;
    setState(() => _appBuilt = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(_hold, () {
        if (!mounted) return;
        if (_reducedMotion) {
          setState(() => _done = true);
        } else {
          setState(() {
            _exit.forward();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_appBuilt)
        KeyedSubtree(
          key: const ValueKey('app'),
          // The app's own entrance animations wait for the reveal.
          child: TickerMode(
            enabled: _done || _exit.isAnimating,
            child: widget.builder(context, _value as T),
          ),
        ),
      if (!_done)
        _Splash(
          key: const ValueKey('splash'),
          assembly: _assembly,
          exit: _exit,
          interactive: !_appBuilt,
        ),
    ],
  );
}

/// The logo and its name on the launch background.
class _Splash extends StatelessWidget {
  const _Splash({
    super.key,
    required this.assembly,
    required this.exit,
    required this.interactive,
  });

  final Animation<double> assembly;
  final Animation<double> exit;

  /// Blocks touches until the app is there, then lets them through.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    // Same background as the system launch screen, which follows the phone.
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final background = dark ? const Color(0xFF0F1218) : Colors.white;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: IgnorePointer(
        ignoring: !interactive,
        child: AbsorbPointer(
          child: AnimatedBuilder(
            animation: Listenable.merge([assembly, exit]),
            builder: (context, _) {
              final out = Curves.easeOut.transform(exit.value);
              final name = Curves.easeOutCubic.transform(
                ((assembly.value - 0.5) / 0.5).clamp(0.0, 1.0),
              );
              return Opacity(
                opacity: 1 - out,
                child: ColoredBox(
                  color: background,
                  child: Center(
                    child: Transform.scale(
                      scale: 1 + 0.05 * out,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FeezerMark(
                            size: 88,
                            phase: LogoPhase.at(assembly.value),
                          ),
                          const SizedBox(height: 22),
                          Opacity(
                            opacity: name,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - name)),
                              child: Text(
                                'Feezer',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                  height: 1,
                                  decoration: TextDecoration.none,
                                  color: dark ? Colors.white : Brand.ink,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
