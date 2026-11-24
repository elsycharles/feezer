// ignore_for_file: invalid_use_of_visible_for_testing_member
// Renders the main screens to PNG files for visual review, with the bundled
// official fee grids.
//
//   flutter test tool/screenshots_test.dart
//
// Output: build/screenshots/*.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:fee_minimizer/data/app_database.dart';
import 'package:fee_minimizer/data/default_data.dart';
import 'package:fee_minimizer/main.dart';
import 'package:fee_minimizer/provider/locale_provider.dart';
import 'package:fee_minimizer/provider/theme_provider.dart';
import 'package:fee_minimizer/util/navigation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _materialIcons =
    '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';

Future<void> _loadFonts() async {
  Future<ByteData> read(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());
  final inter = FontLoader('Inter')
    ..addFont(read('assets/fonts/Inter/Inter-VariableFont_opsz,wght.ttf'));
  await inter.load();
  final icons = FontLoader('MaterialIcons')..addFont(read(_materialIcons));
  await icons.load();
}

Future<void> _settle(WidgetTester tester, [int rounds = 15]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }
  await tester.pump(const Duration(seconds: 1));
}

final _boundary = GlobalKey();

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final render =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await render.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/screenshots').createSync(recursive: true);
    File(
      'build/screenshots/$name.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  sqfliteFfiInit();

  for (final dark in [false, true]) {
    testWidgets('screens ${dark ? 'dark' : 'light'}', (tester) async {
      final suffix = dark ? 'dark' : 'light';
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'first_launch': false,
        'theme_mode': dark ? 1 : 0,
        'selected_locale': 'fr',
      });
      await tester.runAsync(_loadFonts);
      late Directory dir;
      final theme = ThemeProvider();
      final locale = LocaleProvider();
      await tester.runAsync(() async {
        dir = await Directory.systemTemp.createTemp('feezer_shots');
        AppDatabase.instance.overrideDatabase(
          databaseFactoryFfi.openDatabase(
            '${dir.path}/s.db',
            options: OpenDatabaseOptions(
              version: Db.version,
              onCreate: AppDatabase.createSchema,
            ),
          ),
        );
        await DefaultData.ensureSeeded();
        await theme.initializeTheme();
        await locale.initializeLocale();
      });
      await tester.pumpWidget(
        RepaintBoundary(
          key: _boundary,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: theme),
              ChangeNotifierProvider.value(value: locale),
            ],
            child: const FeezerApp(initialRoute: '/'),
          ),
        ),
      );
      await _settle(tester);
      await _shot(tester, '01_optimize_$suffix');

      final optimize = find.widgetWithText(FilledButton, 'Optimiser');
      await tester.enterText(find.byType(TextField).first, '2058989');
      await tester.tap(optimize);
      await _settle(tester, 40);
      await _shot(tester, '02_result_$suffix');
      final scroll = find.byType(CustomScrollView).first;
      await tester.drag(scroll, const Offset(0, -650));
      await _settle(tester, 5);
      await _shot(tester, '03_plan_$suffix');
      await tester.drag(scroll, const Offset(0, -700));
      await _settle(tester, 5);
      await _shot(tester, '04_compare_$suffix');

      await tester.drag(scroll, const Offset(0, 3000));
      await _settle(tester, 5);
      await tester.tap(find.text('Retrait').first);
      await _settle(tester, 5);
      await tester.ensureVisible(optimize);
      await tester.tap(optimize);
      await _settle(tester, 40);
      await _shot(tester, '05_withdrawal_$suffix');

      await tester.tap(_tab('Opérateurs'));
      await _settle(tester);
      await _shot(tester, '06_operators_$suffix');
      await tester.tap(find.text('Retrait').first);
      await _settle(tester);
      await _shot(tester, '07_grid_$suffix');
      await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
      await _settle(tester);
      await _shot(tester, '08_tier_form_$suffix');
      Navigator.of(tester.element(find.byType(BottomSheet))).pop();
      await _settle(tester);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await _settle(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await _settle(tester);
      await _shot(tester, '09_grid_form_$suffix');
      Navigator.of(tester.element(find.byType(BottomSheet))).pop();
      await _settle(tester);

      await tester.tap(_tab('Paramètres'));
      await _settle(tester);
      await _shot(tester, '10_settings_$suffix');
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      for (final (route, name) in [
        (NavigationUtil.dataRoute, '15_data'),
        (NavigationUtil.helpRoute, '16_help'),
        (NavigationUtil.termsRoute, '17_terms'),
      ]) {
        navigator.pushNamed(route);
        await _settle(tester);
        await _shot(tester, '${name}_$suffix');
        navigator.pop();
        await _settle(tester);
      }
      // Tests cannot reach the internet: this shows the failure state.
      await tester.tap(find.text('Mettre à jour les frais'));
      await _settle(tester, 30);
      await _shot(tester, '11_update_$suffix');
      Navigator.of(tester.element(find.byType(BottomSheet))).pop();
      await _settle(tester);

      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed(NavigationUtil.onboardingRoute);
      await _settle(tester);
      await _shot(tester, '12_onboarding1_$suffix');
      await tester.tap(find.text('Suivant'));
      await _settle(tester);
      await _shot(tester, '13_onboarding2_$suffix');
      await tester.tap(find.text('Suivant'));
      await _settle(tester);
      await _shot(tester, '14_onboarding3_$suffix');

      await tester.runAsync(() async {
        await (await AppDatabase.instance.database).close();
        await dir.delete(recursive: true);
      });
    });
  }
}
