import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../util/navigation_util.dart';
import '../../util/preference_util.dart';
import '../../widget/common.dart';

/// Three-page introduction, shown on first launch and from the settings.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await PreferenceUtil.setFirstLaunchCompleted();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(); // replayed from the settings
    } else {
      navigator.pushReplacementNamed(NavigationUtil.homeRoute);
    }
  }

  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 420),
    curve: Curves.easeInOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      (
        const _SplitIllustration(),
        l10n.onboardingTitle1,
        l10n.onboardingDescription1,
      ),
      (
        const _OperatorsIllustration(),
        l10n.onboardingTitle2,
        l10n.onboardingDescription2,
      ),
      (
        const _OperationsIllustration(),
        l10n.onboardingTitle3,
        l10n.onboardingDescription3,
      ),
    ];
    final last = _page == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.sm,
                Space.sm,
                0,
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 30, height: 30),
                  Space.gapSm,
                  Text('Feezer', style: context.text.titleLarge),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: last ? 0 : 1,
                    duration: Motion.medium,
                    child: TextButton(
                      onPressed: last ? null : _finish,
                      child: Text(l10n.skip),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) {
                  final (illustration, title, description) = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: FadeSlideIn(
                              offset: 20,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: illustration,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: FadeSlideIn(
                            delay: const Duration(milliseconds: 90),
                            child: Column(
                              children: [
                                Text(
                                  title,
                                  style: context.text.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                Space.gapMd,
                                Text(
                                  description,
                                  style: context.text.bodyLarge?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: Motion.slow,
                    curve: Motion.curve,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? context.colors.primary
                          : context.colors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(Space.page),
              child: AppButton(
                label: last ? l10n.getStarted : l10n.next,
                onPressed: last ? _finish : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded bar used by the illustrations.
class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.color, this.height = 14});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(height / 2),
    ),
  );
}

/// One amount split into smaller transactions, with less fees.
class _SplitIllustration extends StatelessWidget {
  const _SplitIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    Widget part(double width) => Container(
      width: 84,
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: width, color: colors.primary, height: 10),
          Space.gapSm,
          _Bar(width: 28, color: palette.success, height: 8),
        ],
      ),
    );
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.all(Space.xl),
            decoration: BoxDecoration(
              color: palette.highlight,
              borderRadius: BorderRadius.circular(Space.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bar(
                  width: 90,
                  height: 10,
                  color: palette.onHighlight.withValues(alpha: 0.5),
                ),
                Space.gapMd,
                _Bar(width: 170, height: 22, color: palette.onHighlight),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            width: 300,
            child: CustomPaint(painter: _ForkPainter(colors.outline)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [part(56), part(56), part(36)],
          ),
        ],
      ),
    );
  }
}

/// Lines from the amount to the three parts.
class _ForkPainter extends CustomPainter {
  const _ForkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final top = Offset(size.width / 2, 0);
    for (final x in [42.0, size.width / 2, size.width - 42]) {
      final path = Path()
        ..moveTo(top.dx, top.dy)
        ..cubicTo(
          top.dx,
          size.height * 0.6,
          x,
          size.height * 0.4,
          x,
          size.height,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ForkPainter oldDelegate) => oldDelegate.color != color;
}

/// The operators and their official grids.
class _OperatorsIllustration extends StatelessWidget {
  const _OperatorsIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget row(String name, double width) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        children: [
          ProviderAvatar(name: name, iconName: 'business', size: 40),
          Space.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.text.titleSmall),
                Space.gapXs,
                _Bar(
                  width: width,
                  color: colors.surfaceContainerHighest,
                  height: 8,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: context.palette.success),
        ],
      ),
    );
    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        Space.lg,
        Space.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row('MVola', 120),
          const Divider(),
          row('Orange Money', 96),
          const Divider(),
          row('Airtel Money', 108),
        ],
      ),
    );
  }
}

/// Choosing the operation: withdrawal or transfers.
class _OperationsIllustration extends StatelessWidget {
  const _OperationsIllustration();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    Widget pill(String label, bool selected) => Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusMd),
        border: Border.all(
          color: selected ? colors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: context.text.titleSmall?.copyWith(
          color: selected ? colors.onPrimaryContainer : colors.onSurface,
        ),
      ),
    );
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            alignment: WrapAlignment.center,
            children: [
              pill(l10n.opWithdrawal, true),
              pill(l10n.opTransferSame, false),
              pill(l10n.opTransferOther, false),
            ],
          ),
          Space.gapXl,
          Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(Space.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(Space.radiusSm),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                Space.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bar(
                        width: 150,
                        color: colors.surfaceContainerHighest,
                        height: 10,
                      ),
                      Space.gapSm,
                      _Bar(
                        width: 100,
                        color: colors.surfaceContainerHighest,
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
