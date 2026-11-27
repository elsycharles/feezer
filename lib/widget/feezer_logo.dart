import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'logo_geometry.dart';

/// How far each part of the mark has appeared, from 0 (hidden) to 1 (in place).
@immutable
class LogoPhase {
  const LogoPhase({this.top = 1, this.middle = 1, this.leg = 1});

  final double top;
  final double middle;
  final double leg;

  static const LogoPhase done = LogoPhase();

  /// The assembly at [t], from 0 to 1: the top bar slides in, the middle bar
  /// follows, then the leg unfolds from the fold down to its tip.
  factory LogoPhase.at(double t) {
    double part(double begin, double end, Curve curve) =>
        curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));
    return LogoPhase(
      top: part(0, 0.5, Curves.easeOutCubic),
      middle: part(0.14, 0.64, Curves.easeOutCubic),
      // Quick start, gentle landing: the leg drops into place.
      leg: part(0.44, 1, Curves.easeOutCubic),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LogoPhase &&
      other.top == top &&
      other.middle == middle &&
      other.leg == leg;

  @override
  int get hashCode => Object.hash(top, middle, leg);
}

/// The Feezer mark, drawn from its exact geometry (tool/brand/make_logo.py),
/// in a [size] square.
class FeezerMark extends StatelessWidget {
  const FeezerMark({super.key, this.size = 48, this.phase = LogoPhase.done});

  final double size;
  final LogoPhase phase;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Feezer',
    image: true,
    child: CustomPaint(size: Size.square(size), painter: _MarkPainter(phase)),
  );
}

/// The mark that assembles itself when it appears, and again when tapped.
class AnimatedFeezerMark extends StatefulWidget {
  const AnimatedFeezerMark({
    super.key,
    this.size = 48,
    this.playOnStart = true,
    this.duration = const Duration(milliseconds: 760),
  });

  final double size;
  final bool playOnStart;
  final Duration duration;

  @override
  State<AnimatedFeezerMark> createState() => _AnimatedFeezerMarkState();
}

class _AnimatedFeezerMarkState extends State<AnimatedFeezerMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.playOnStart ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.playOnStart) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _controller.forward(from: 0),
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          FeezerMark(size: widget.size, phase: LogoPhase.at(_controller.value)),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.phase);

  final LogoPhase phase;

  static final Path _top = LogoGeometry.topBar();
  static final Path _stem = LogoGeometry.stem();
  static final Path _upper = LogoGeometry.upperSide();

  /// The leg: the stem below the fold, raised a little so that it slips
  /// under the middle bar and no seam shows between them. Computed once, so
  /// drawing it needs a single simple clip (some GPU renderers mishandle
  /// stacked clips).
  static final Path _leg = Path.combine(
    PathOperation.difference,
    _stem,
    _upper.shift(const Offset(0, -2)),
  );

  /// Distance the bars slide in from, in artwork units (the mark is ~1000).
  static const double _slide = 360;

  @override
  void paint(Canvas canvas, Size size) {
    const box = LogoGeometry.bounds;
    final scale =
        math.min(size.width, size.height) / math.max(box.width, box.height);
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(scale)
      ..translate(-box.center.dx, -box.center.dy);
    final paint = Paint()..isAntiAlias = true;

    // The leg first: the middle bar is drawn over its top edge.
    final leg = phase.leg.clamp(0.0, 1.0);
    if (leg > 0) {
      canvas.save();
      if (leg < 1) canvas.clipPath(_reveal(leg));
      canvas
        ..drawPath(_leg, paint..color = LogoGeometry.dark)
        ..restore();
    }
    _bar(canvas, paint, phase.middle, LogoGeometry.mid, _stem, clip: _upper);
    _bar(canvas, paint, phase.top, LogoGeometry.light, _top);
    canvas.restore();
  }

  /// A bar sliding in from the right while it fades in.
  void _bar(
    Canvas canvas,
    Paint paint,
    double progress,
    Color color,
    Path path, {
    Path? clip,
  }) {
    final t = progress.clamp(0.0, 1.0);
    if (t <= 0) return;
    canvas
      ..save()
      ..translate((1 - t) * _slide, 0);
    if (clip != null) canvas.clipPath(clip);
    canvas
      ..drawPath(
        path,
        paint..color = color.withValues(alpha: math.min(1, t / 0.55)),
      )
      ..restore();
  }

  /// Half-plane of the leg already unfolded: up to [t] of its length.
  static Path _reveal(double t) {
    const d = LogoGeometry.legDirection;
    final across = Offset(-d.dy, d.dx);
    final end =
        LogoGeometry.legFrom + (LogoGeometry.legTo - LogoGeometry.legFrom) * t;
    const far = 3000.0;
    Offset at(double along, double side) => d * along + across * side;
    final a = at(-far, -far);
    final b = at(-far, far);
    final c = at(end, far);
    final e = at(end, -far);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(e.dx, e.dy)
      ..close();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.phase != phase;
}
