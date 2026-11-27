import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:feezer/l10n/app_localizations.dart';
import 'package:feezer/screen/onboarding/onboarding_screen.dart';
import 'package:feezer/screen/splash/launch_splash.dart';
import 'package:feezer/theme/app_theme.dart';
import 'package:feezer/util/preference_util.dart';
import 'package:feezer/widget/feezer_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thousands separator of the amounts (no-break space).
const nbsp = '\u00A0';

/// Counts how many times the app below the splash is created.
class _Probe extends StatefulWidget {
  const _Probe();

  static int created = 0;

  @override
  State<_Probe> createState() {
    created++;
    return _ProbeState();
  }
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('app'));
}

Future<Uint8List> _pixels(ui.Image image) async {
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  return data!.buffer.asUint8List();
}

void main() {
  test('the assembly goes from nothing to the whole mark', () {
    final start = LogoPhase.at(0);
    expect([start.top, start.middle, start.leg], [0, 0, 0]);
    expect(LogoPhase.at(1), LogoPhase.done);
    // Each part only moves forward, the top bar first and the leg last.
    var previous = start;
    for (var i = 1; i <= 100; i++) {
      final phase = LogoPhase.at(i / 100);
      expect(phase.top, greaterThanOrEqualTo(previous.top));
      expect(phase.middle, greaterThanOrEqualTo(previous.middle));
      expect(phase.leg, greaterThanOrEqualTo(previous.leg));
      expect(phase.top, greaterThanOrEqualTo(phase.middle));
      expect(phase.middle, greaterThanOrEqualTo(phase.leg));
      previous = phase;
    }
  });

  testWidgets('the drawn mark is the logo image', (tester) async {
    tester.view.physicalSize = const Size(512, 512);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: boundary,
          child: const Center(child: FeezerMark(size: 512)),
        ),
      ),
    );
    final (drawn, expected) = (await tester.runAsync(() async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final drawn = await _pixels(await render.toImage());
      final codec = await ui.instantiateImageCodec(
        File('assets/images/logo.png').readAsBytesSync(),
      );
      final expected = await _pixels((await codec.getNextFrame()).image);
      return (drawn, expected);
    }))!;
    expect(drawn.length, expected.length);
    var edges = 0;
    var colorGap = 0;
    for (var i = 0; i < drawn.length; i += 4) {
      final alpha = (drawn[i + 3] - expected[i + 3]).abs();
      if (alpha > 64) edges++;
      if (drawn[i + 3] > 250 && expected[i + 3] > 250) {
        for (var c = 0; c < 3; c++) {
          final gap = (drawn[i + c] - expected[i + c]).abs();
          if (gap > colorGap) colorGap = gap;
        }
      }
    }
    // Anti-aliasing may differ on a few edge pixels, nothing more.
    expect(edges, lessThan(drawn.length ~/ 4 ~/ 500));
    expect(colorGap, lessThan(40));
  });

  /// Advances the clock by [ms] in steps of 50 ms.
  Future<void> wait(WidgetTester tester, int ms) async {
    for (var t = 0; t < ms; t += 50) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('the splash plays first, then builds and reveals the app', (
    tester,
  ) async {
    _Probe.created = 0;
    final ready = Completer<int>();
    await tester.pumpWidget(
      LaunchSplash<int>(
        ready: ready.future,
        builder: (context, _) => const MaterialApp(home: _Probe()),
      ),
    );
    expect(find.byType(FeezerMark), findsOneWidget);
    expect(find.text('Feezer'), findsOneWidget);
    // The logo assembles; the app is not built while it is not ready.
    await wait(tester, 1500);
    expect(find.byType(FeezerMark), findsOneWidget);
    expect(_Probe.created, 0);
    ready.complete(1);
    await wait(tester, 1000);
    expect(find.byType(FeezerMark), findsNothing);
    expect(find.text('app'), findsOneWidget);
    // Built once, under the splash, and kept when the splash went away.
    expect(_Probe.created, 1);
  });

  testWidgets('the app waits for the end of the logo animation', (
    tester,
  ) async {
    _Probe.created = 0;
    await tester.pumpWidget(
      LaunchSplash<int>(
        ready: Future.value(1),
        builder: (context, _) => const MaterialApp(home: _Probe()),
      ),
    );
    await wait(tester, 500);
    expect(_Probe.created, 0); // still assembling
    await wait(tester, 1500);
    expect(find.byType(FeezerMark), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('reduced motion shows the app without the animation', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      LaunchSplash<int>(
        ready: Future.value(1),
        builder: (context, _) => const MaterialApp(home: _Probe()),
      ),
    );
    await wait(tester, 300);
    expect(find.byType(FeezerMark), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('onboarding: a real example, three steps, then the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/onboarding',
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
        ],
        onGenerateRoute: (settings) => settings.name == '/'
            ? MaterialPageRoute<void>(builder: (_) => const Text('home'))
            : null,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pay less in fees'), findsOneWidget);
    expect(find.text('Example: 510${nbsp}000 in your account'), findsOne);
    expect(find.text('501${nbsp}200'), findsOneWidget);
    expect(find.text('500${nbsp}000 + 5${nbsp}000'), findsOneWidget);
    expect(find.text('+3${nbsp}800 more received'), findsOneWidget);
    expect(find.text('English'), findsOneWidget); // language button

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('In 3 steps'), findsOneWidget);
    expect(find.text('Pick the operator'), findsOneWidget);
    expect(find.text('Enter the amount'), findsOneWidget);
    expect(find.text('Follow the plan'), findsOneWidget);
    expect(find.text('Withdraw 5${nbsp}000'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(await tester.runAsync(PreferenceUtil.isFirstLaunch), isFalse);
    expect(tester.takeException(), isNull);
  });
}
