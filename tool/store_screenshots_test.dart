// ignore_for_file: invalid_use_of_visible_for_testing_member
// Renders the Google Play screenshots (1080 x 1920) from the real screens,
// with the official fee grids bundled with the app, in French and English.
//
//   flutter test tool/store_screenshots_test.dart
//   python3 tool/store/compose_store_assets.py
//
// Output: build/store/raw/<locale>/*.png, then framed images with captions in
// fastlane/metadata/android/<locale>/images/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:feezer/data/app_database.dart';
import 'package:feezer/data/default_data.dart';
import 'package:feezer/main.dart';
import 'package:feezer/provider/locale_provider.dart';
import 'package:feezer/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _materialIcons =
    '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';

/// 1080 x 1920 pixels, like a 411 dp wide phone.
const _ratio = 2.625;

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

Future<void> _shot(WidgetTester tester, String locale, String name) async {
  await tester.runAsync(() async {
    final render =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await render.toImage(pixelRatio: _ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/store/raw/$locale')
      ..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Texts of the screens, per language.
class _Words {
  const _Words(
    this.withdrawal,
    this.transfer,
    this.optimize,
    this.operators,
    this.cash,
    this.recipient,
    this.transferPlan,
  );
  final String withdrawal;
  final String transfer;
  final String optimize;
  final String operators;
  final String cash;
  final String recipient;
  final String transferPlan;
}

const _words = {
  'fr': _Words(
    'Retrait',
    'Transfert',
    'Optimiser',
    'Opérateurs',
    'Vous recevez en espèces',
    'Le destinataire reçoit',
    "Votre plan d'envoi",
  ),
  'en': _Words(
    'Withdrawal',
    'Transfer',
    'Optimize',
    'Operators',
    'You receive in cash',
    'The recipient receives',
    'Your transfer plan',
  ),
};

Future<void> _pumpApp(
  WidgetTester tester, {
  required String locale,
  required bool dark,
  required Directory dir,
}) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = _ratio;
  // Room for the status bar.
  tester.view.padding = const FakeViewPadding(top: 63);
  SharedPreferences.setMockInitialValues({
    'first_launch': false,
    'theme_mode': dark ? 1 : 0,
    'selected_locale': locale,
  });
  final theme = ThemeProvider();
  final localeProvider = LocaleProvider();
  await tester.runAsync(() async {
    AppDatabase.instance.overrideDatabase(
      databaseFactoryFfi.openDatabase(
        '${dir.path}/$locale-$dark.db',
        options: OpenDatabaseOptions(
          version: Db.version,
          onCreate: AppDatabase.createSchema,
        ),
      ),
    );
    await DefaultData.ensureSeeded();
    await theme.initializeTheme();
    await localeProvider.initializeLocale();
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: theme),
          ChangeNotifierProvider.value(value: localeProvider),
        ],
        child: const FeezerApp(initialRoute: '/'),
      ),
    ),
  );
  await _settle(tester);
}

Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> _scrollTo(WidgetTester tester, double offset) async {
  final position = tester.state<ScrollableState>(_scrollable).position;
  position.jumpTo(offset.clamp(0, position.maxScrollExtent));
  await _settle(tester, 5);
}

Finder get _scrollable => find
    .descendant(
      of: find.byType(CustomScrollView).first,
      matching: find.byType(Scrollable),
    )
    .first;

/// Scrolls so that [text] is near the top of the screen.
Future<void> _alignTop(WidgetTester tester, String text, double margin) async {
  await Scrollable.ensureVisible(tester.element(find.text(text).first));
  await tester.pump();
  final position = tester.state<ScrollableState>(_scrollable).position;
  position.jumpTo(
    (position.pixels - margin).clamp(0, position.maxScrollExtent),
  );
  await _settle(tester, 5);
}

Future<void> _optimize(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.scrollUntilVisible(button, 300, scrollable: _scrollable);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await _settle(tester, 40);
}

void main() {
  sqfliteFfiInit();

  for (final locale in ['fr', 'en']) {
    final w = _words[locale]!;

    testWidgets('store screenshots $locale', (tester) async {
      addTearDown(tester.view.reset);
      await tester.runAsync(_loadFonts);
      late Directory dir;
      await tester.runAsync(() async {
        dir = await Directory.systemTemp.createTemp('feezer_store');
      });
      await _pumpApp(tester, locale: locale, dark: false, dir: dir);

      // 1. Operator and operation: MVola withdrawal of 510 000.
      await tester.tap(find.text('MVola'));
      await _settle(tester, 5);
      await tester.tap(find.text(w.withdrawal));
      await _settle(tester, 5);
      await tester.enterText(find.byType(TextField).first, '510000');
      await _settle(tester, 5);
      await _scrollTo(tester, 0);
      await _shot(tester, locale, '1_choose');

      // 2. Withdrawal plan, rounded to the hundred: 3 800 more in cash.
      await _optimize(tester, w.optimize);
      await _alignTop(tester, w.cash, 44);
      await _shot(tester, locale, '2_withdrawal');

      // 3. Transfer that beats the usual way: 1 230 more received.
      await _scrollTo(tester, 0);
      await tester.tap(find.text(w.transfer).first);
      await _settle(tester, 5);
      await tester.enterText(find.byType(TextField).first, '505000');
      await _optimize(tester, w.optimize);
      await _alignTop(tester, w.recipient, 44);
      await _shot(tester, locale, '3_transfer');

      // 4. Comparison with the usual way.
      await _alignTop(tester, w.transferPlan, 16);
      await _shot(tester, locale, '4_compare');

      // 5. Operators and their official grids.
      await tester.tap(_tab(w.operators));
      await _settle(tester);
      await _shot(tester, locale, '5_operators');

      // 6. One grid with its official source.
      await tester.tap(find.text(w.withdrawal).at(1));
      await _settle(tester);
      await _shot(tester, locale, '6_grid');

      await tester.runAsync(() async {
        await (await AppDatabase.instance.database).close();
      });

      // 7. Dark theme (fresh app).
      await tester.pumpWidget(const SizedBox());
      await _pumpApp(tester, locale: locale, dark: true, dir: dir);
      await tester.tap(find.text('Orange Money'));
      await _settle(tester, 5);
      await tester.tap(find.text(w.withdrawal));
      await _settle(tester, 5);
      await tester.enterText(find.byType(TextField).first, '515000');
      await _optimize(tester, w.optimize);
      await _alignTop(tester, w.cash, 44);
      await _shot(tester, locale, '7_dark');

      await tester.runAsync(() async {
        await (await AppDatabase.instance.database).close();
        await dir.delete(recursive: true);
      });
    });
  }
}
