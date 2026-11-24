import 'dart:io';

import 'package:fee_minimizer/data/app_database.dart';
import 'package:fee_minimizer/data/currency_repository.dart';
import 'package:fee_minimizer/main.dart';
import 'package:fee_minimizer/provider/currency_provider.dart';
import 'package:fee_minimizer/provider/locale_provider.dart';
import 'package:fee_minimizer/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Lets real asynchronous work (database, isolate) progress, then rebuilds.
Future<void> settle(WidgetTester tester, {int rounds = 20}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  sqfliteFfiInit();

  testWidgets('optimizes an amount and survives a currency switch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'first_launch': false});

    late Directory dir;
    late CurrencyProvider currency;
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
      await AppDatabase.instance.seedDefaultData();
      currency = CurrencyProvider();
      await currency.initializeCurrency();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider.value(value: currency),
        ],
        child: const FeezerApp(initialRoute: '/'),
      ),
    );
    await settle(tester);
    expect(find.text('YAS'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '10500');
    await tester.pump();
    await tester.tap(find.text('Optimize'));
    await settle(tester, rounds: 40);

    expect(find.text('10 050 Ar'), findsWidgets); // net amount
    expect(find.text('450 Ar'), findsWidgets); // fees
    expect(tester.takeException(), isNull);

    // Switch to euros: amounts are converted, not reinterpreted.
    await tester.runAsync(() async {
      final euro = await CurrencyRepository().getByCode('EUR');
      await currency.setSelectedCurrency(euro!);
    });
    await tester.pumpAndSettle();
    expect(
      find.text('2.02 €'),
      findsWidgets,
    ); // 10 500 Ar budget shown as 2.02 €
    expect(tester.takeException(), isNull);

    await tester.runAsync(() async {
      await (await AppDatabase.instance.database).close();
      await dir.delete(recursive: true);
    });
  });
}
