import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../util/money.dart';
import '../../util/navigation_util.dart';
import '../../util/preference_util.dart';
import '../../widget/common.dart';
import '../settings/language_picker.dart';

/// Two-page introduction, shown on first launch and from the settings:
/// a real example of what Feezer saves, then how to use it in three steps.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 2;

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
    final last = _page == _pageCount - 1;
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
                  // Read the introduction in one's own language.
                  TextButton.icon(
                    onPressed: () => showLanguagePicker(context),
                    icon: const Icon(Icons.translate_rounded, size: 18),
                    label: Text(currentLanguageName(context)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  _Page(
                    title: l10n.onboardingTitle1,
                    subtitle: l10n.onboardingText1,
                    illustration: const _ExampleIllustration(),
                  ),
                  _Page(
                    title: l10n.onboardingTitle2,
                    illustration: const _StepsIllustration(),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pageCount; i++)
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

/// Title, optional one-line text, and the illustration below.
class _Page extends StatelessWidget {
  const _Page({required this.title, required this.illustration, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget illustration;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Space.xl),
    child: Column(
      children: [
        Space.gapXl,
        FadeSlideIn(
          child: Column(
            children: [
              Text(
                title,
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                Space.gapSm,
                Text(
                  subtitle!,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        Space.gapLg,
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: math.min(constraints.maxWidth, 380),
                  child: illustration,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// A real case, from the official MVola withdrawal fees: with 510 000 in the
/// account, one withdrawal hands out 501 200 (8 800 of fees), while
/// 500 000 + 5 000 hands out 505 000 (4 850 of fees).
class _ExampleIllustration extends StatelessWidget {
  const _ExampleIllustration();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: Text(
            l10n.onboardingExample(context.money(510000)),
            style: context.text.titleSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Space.gapLg,
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: _Option(
            label: l10n.onboardingOneGo,
            amount: context.money(501200),
            fees: context.money(8800),
          ),
        ),
        Space.gapMd,
        FadeSlideIn(
          delay: const Duration(milliseconds: 380),
          child: _Option(
            label: l10n.onboardingWithFeezer,
            amount: '${context.money(500000)} + ${context.money(5000)}',
            fees: context.money(4850),
            highlighted: true,
          ),
        ),
        Space.gapXl,
        Center(
          child: _Pop(
            delay: const Duration(milliseconds: 620),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.lg,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: palette.successContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                l10n.gainTitle(context.money(3800)),
                style: context.text.titleMedium?.copyWith(
                  color: palette.onSuccessContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One way of withdrawing the money: what is handed out, and its fees.
class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.amount,
    required this.fees,
    this.highlighted = false,
  });

  final String label;
  final String amount;
  final String fees;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final foreground = highlighted
        ? context.palette.onHighlight
        : context.colors.onSurface;
    final muted = highlighted
        ? foreground.withValues(alpha: 0.8)
        : context.colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: highlighted
            ? context.palette.highlight
            : context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.labelLarge?.copyWith(color: muted)),
          Space.gapXs,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: context.text.headlineSmall?.copyWith(
                    color: foreground,
                    fontFeatures: AppTheme.tabular,
                  ),
                ),
              ),
              Space.gapSm,
              Text(
                '${l10n.feesLabel} $fees',
                style: context.text.bodyMedium?.copyWith(
                  color: muted,
                  fontFeatures: AppTheme.tabular,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// How to use Feezer: operator, amount, plan.
class _StepsIllustration extends StatelessWidget {
  const _StepsIllustration();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    Widget box(Widget child) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusMd),
      ),
      child: child,
    );
    Widget planRow(double amount) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(Space.radiusSm),
            ),
            child: Text(
              '1×',
              style: context.text.labelLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ),
          Space.gapSm,
          Flexible(
            child: Text(
              l10n.withdrawAmount(context.money(amount)),
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium?.copyWith(
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Step(
          number: 1,
          title: l10n.onboardingStep1,
          index: 0,
          child: const Row(
            children: [
              _OperatorChip(name: 'MVola', selected: true),
              Space.gapSm,
              _OperatorChip(name: 'Orange Money'),
              Space.gapSm,
              _OperatorChip(name: 'Airtel Money'),
            ],
          ),
        ),
        _Step(
          number: 2,
          title: l10n.onboardingStep2,
          index: 1,
          child: box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.money(510000),
                  style: context.text.headlineSmall?.copyWith(
                    fontFeatures: AppTheme.tabular,
                  ),
                ),
                Text(l10n.amountHelper, style: context.text.bodySmall),
              ],
            ),
          ),
        ),
        _Step(
          number: 3,
          title: l10n.onboardingStep3,
          index: 2,
          last: true,
          child: box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [planRow(500000), planRow(5000)],
            ),
          ),
        ),
      ],
    );
  }
}

/// Numbered step on a vertical line: number, title, then [child].
class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.child,
    required this.index,
    this.last = false,
  });

  final int number;
  final String title;
  final Widget child;
  final int index;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FadeSlideIn(
      delay: Duration(milliseconds: 120 + 140 * index),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: context.text.titleSmall?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: Space.xs),
                      color: colors.outlineVariant,
                    ),
                  ),
              ],
            ),
            Space.gapMd,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(title, style: context.text.titleMedium),
                    ),
                    Space.gapMd,
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small operator pill, like the operator picker of the main screen.
class _OperatorChip extends StatelessWidget {
  const _OperatorChip({required this.name, this.selected = false});

  final String name;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatar = ProviderAvatar(name: name, iconName: 'business', size: 32);
    if (!selected) return avatar;
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, Space.lg, 5),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(Space.radiusMd),
        border: Border.all(color: colors.primary, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          Space.gapSm,
          Text(
            name,
            style: context.text.titleMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scales its child in with a small bounce, after [delay].
class _Pop extends StatefulWidget {
  const _Pop({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_Pop> createState() => _PopState();
}

class _PopState extends State<_Pop> with SingleTickerProviderStateMixin {
  static const _length = Duration(milliseconds: 460);

  // The delay is part of the animation, like FadeSlideIn.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + _length,
  )..forward();
  late final double _start =
      widget.delay.inMicroseconds / (widget.delay + _length).inMicroseconds;
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Interval(_start, 1, curve: Curves.easeOutBack),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Interval(_start, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: FadeTransition(opacity: _opacity, child: widget.child),
  );
}
