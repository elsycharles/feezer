import 'dart:convert';
import 'dart:io';

import 'package:feezer/data/app_database.dart';
import 'package:feezer/data/default_data.dart';
import 'package:feezer/data/legacy_defaults.dart';
import 'package:feezer/main.dart';
import 'package:feezer/provider/locale_provider.dart';
import 'package:feezer/provider/theme_provider.dart';
import 'package:feezer/util/preference_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/database_test.dart' show TextBundle;

/// Lets real asynchronous work (database, isolate) progress, then rebuilds.
Future<void> settle(WidgetTester tester, {int rounds = 20}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

const nbsp = ' ';

Map<String, Object?> legacyGrid(String legacyName, String name, String op) {
  final legacy = LegacyDefaults.providers.firstWhere(
    (p) => p.name == legacyName,
  );
  return {
    'name': name,
    'operation': op,
    'icon': 'phone_android',
    'source': {
      'type': 'official',
      'url': 'https://www.example.mg/tarifs',
      'effectiveDate': '2025-02-17',
    },
    'intervals': [
      for (final (min, max, fee) in legacy.tiers)
        {'min': min, 'max': max, 'fee': fee, 'type': 'fixed'},
    ],
  };
}

/// MVola with two operations, Orange Money with one.
final tables = jsonEncode({
  'schema': 2,
  'updatedAt': '2026-11-20',
  'checkedAt': '2026-11-20',
  'providers': [
    legacyGrid('YAS', 'MVola', 'transfer_same'),
    legacyGrid('AIRTEL', 'MVola', 'withdrawal'),
    legacyGrid('ORANGE', 'Orange Money', 'withdrawal'),
  ],
});

Finder tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  sqfliteFfiInit();

  for (final mode in [AppThemeMode.light, AppThemeMode.dark]) {
    testWidgets('main flow (${mode.name} theme)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'first_launch': false,
        'theme_mode': mode.index,
        'selected_locale': 'en',
        // Exact transfer amounts here; rounding is the default (see below).
        'amount_step_transfer': 0,
      });

      late Directory dir;
      final theme = ThemeProvider();
      final locale = LocaleProvider();
      await tester.runAsync(() async {
        dir = await Directory.systemTemp.createTemp('feezer_ui_test');
        AppDatabase.instance.overrideDatabase(
          databaseFactoryFfi.openDatabase(
            '${dir.path}/ui.db',
            options: OpenDatabaseOptions(
              version: Db.version,
              onCreate: AppDatabase.createSchema,
            ),
          ),
        );
        await DefaultData.ensureSeeded(bundle: TextBundle(tables));
        await theme.initializeTheme();
        await locale.initializeLocale();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: theme),
            ChangeNotifierProvider.value(value: locale),
          ],
          child: const FeezerApp(initialRoute: '/'),
        ),
      );
      await settle(tester);
      // Operators, then the operations of the selected one.
      expect(find.text('MVola'), findsOneWidget);
      expect(find.text('Orange Money'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Withdrawal'), findsOneWidget);
      expect(find.text('Official grid · example.mg · Feb 17, 2025'), findsOne);

      // Optimize 10 500 with the MVola transfer grid.
      await tester.enterText(find.byType(TextField).first, '10500');
      await tester.pump();
      final optimize = find.widgetWithText(FilledButton, 'Optimize');
      await tester.tap(optimize);
      await settle(tester, rounds: 40);
      expect(find.text('The recipient receives'), findsOneWidget);
      expect(find.text('10${nbsp}050'), findsWidgets);
      expect(find.text('+50 more received'), findsOneWidget);
      expect(find.text('Send 9${nbsp}950'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Limit: at most 1 transfer. The page scrolled to the result.
      final scrollable = find
          .descendant(
            of: find.byType(CustomScrollView).first,
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Number of transfers'),
        -300,
        scrollable: scrollable,
      );
      await tester.ensureVisible(find.text('Number of transfers'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Number of transfers'));
      await tester.pumpAndSettle();
      final plus = find.byIcon(Icons.add_rounded);
      await tester.ensureVisible(plus.last);
      await tester.tap(plus.last); // maximum
      await tester.pumpAndSettle();
      expect(find.text('At most 1'), findsOneWidget);
      await tester.ensureVisible(optimize);
      await tester.tap(optimize);
      await settle(tester, rounds: 40);
      expect(find.text('10${nbsp}000'), findsWidgets);
      expect(find.text('Your limit costs 50'), findsOneWidget);

      // Withdrawals use their own wording.
      await tester.scrollUntilVisible(
        find.text('Withdrawal'),
        -300,
        scrollable: scrollable,
      );
      await tester.ensureVisible(find.text('Withdrawal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Withdrawal'));
      await tester.pumpAndSettle();
      expect(find.text('Number of withdrawals'), findsOneWidget);
      // Remove the "at most 1" limit set above.
      final minus = find.byIcon(Icons.remove_rounded).last;
      await tester.ensureVisible(minus);
      await tester.pumpAndSettle();
      await tester.tap(minus);
      await tester.pumpAndSettle();
      expect(find.text('No limit'), findsOneWidget);
      await tester.ensureVisible(optimize);
      await tester.tap(optimize);
      await settle(tester, rounds: 40);
      expect(find.text('You receive in cash'), findsOneWidget);
      expect(find.text('Withdrawal plan'), findsOneWidget);
      // Withdrawals default to notes of 100.
      expect(find.text('10${nbsp}100'), findsWidgets);

      // Exact amounts: 10 125.
      final rounding = find.text('Round to the hundred');
      await tester.scrollUntilVisible(rounding, -300, scrollable: scrollable);
      await tester.ensureVisible(rounding);
      await tester.pumpAndSettle();
      expect(find.text('10${nbsp}000, never 10${nbsp}040'), findsOneWidget);
      await tester.tap(rounding);
      await tester.pumpAndSettle();
      expect(find.text('Exact amounts'), findsOneWidget);
      await tester.ensureVisible(optimize);
      await tester.tap(optimize);
      await settle(tester, rounds: 40);
      expect(find.text('10${nbsp}125'), findsWidgets);
      expect(tester.takeException(), isNull);

      // Operators tab: one card per operator, one row per operation.
      await tester.tap(tab('Operators'));
      await settle(tester);
      expect(find.text('2 grids  ·  example.mg'), findsOneWidget);
      expect(find.text('14 tiers  ·  fees from 100'), findsOneWidget);
      await tester.tap(find.text('Transfer'));
      await settle(tester);
      expect(find.text('Fee grid'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await settle(tester);

      // Settings tab.
      await tester.tap(tab('Settings'));
      await settle(tester);
      expect(find.text('Update the fees'), findsOneWidget);
      expect(find.text('Not checked yet'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.runAsync(() async {
        await (await AppDatabase.instance.database).close();
        await dir.delete(recursive: true);
      });
    });
  }
}
