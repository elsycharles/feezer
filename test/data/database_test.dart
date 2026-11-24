import 'dart:io';

import 'package:fee_minimizer/data/app_database.dart';
import 'package:fee_minimizer/data/currency_repository.dart';
import 'package:fee_minimizer/data/fee_interval_repository.dart';
import 'package:fee_minimizer/data/provider_repository.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:fee_minimizer/model/fee_interval_model.dart';
import 'package:fee_minimizer/provider/currency_provider.dart';
import 'package:fee_minimizer/util/csv_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openV4(String path) => databaseFactoryFfi.openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: Db.version,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onCreate: AppDatabase.createSchema,
    onUpgrade: AppDatabase.upgradeSchema,
  ),
);

void main() {
  sqfliteFfiInit();
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('feezer_db_test');
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() => dir.delete(recursive: true));

  test('upgrade from version 3 keeps user data and cleans up', () async {
    final path = '${dir.path}/v3.db';
    // Schema and data as written by the previous app version.
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE providers (id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'name TEXT NOT NULL, description TEXT NOT NULL, '
            "icon_name TEXT DEFAULT 'business', creation_datetime INTEGER NOT NULL)",
          );
          await db.execute(
            'CREATE TABLE fee_intervals (id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'provider_id INTEGER NOT NULL, min_amount REAL NOT NULL, '
            'max_amount REAL NOT NULL, fee REAL NOT NULL, fee_type INTEGER DEFAULT 0, '
            'creation_datetime INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE optimization_results (id INTEGER PRIMARY KEY)',
          );
          await db.execute(
            'CREATE TABLE optimization_details (id INTEGER PRIMARY KEY)',
          );
          await db.execute(
            'CREATE TABLE currencies (id TEXT PRIMARY KEY, code TEXT NOT NULL UNIQUE, '
            'name TEXT NOT NULL, symbol TEXT NOT NULL, rate REAL NOT NULL, '
            'creation_datetime INTEGER NOT NULL)',
          );
          await db.insert('providers', {
            'id': 1732000000000,
            'name': 'YAS',
            'description': 'Opérateur',
            'creation_datetime': 0,
          });
          await db.insert('fee_intervals', {
            'provider_id': 1732000000000,
            'min_amount': 100,
            'max_amount': 1000,
            'fee': 100,
            'creation_datetime': 0,
          });
          // Orphan left by a provider deleted without its intervals.
          await db.insert('fee_intervals', {
            'provider_id': 42,
            'min_amount': 1,
            'max_amount': 2,
            'fee': 1,
            'creation_datetime': 0,
          });
          await db.insert('currencies', {
            'id': 'eur',
            'code': 'EUR',
            'name': 'Euro',
            'symbol': '€',
            'rate': 5200,
            'creation_datetime': '2025-01-01T00:00:00.000',
          });
        },
      ),
    );
    await old.close();

    AppDatabase.instance.overrideDatabase(openV4(path));
    final db = await AppDatabase.instance.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final names = tables.map((t) => t['name']).toSet();
    expect(names, isNot(contains('optimization_results')));
    expect(names, contains('fee_intervals'));

    final providers = await ProviderRepository().getAll();
    expect(providers.single.name, 'YAS');
    final intervals = await FeeIntervalRepository().getByProvider(
      providers.single.id,
    );
    expect(intervals, hasLength(1));
    expect(await db.query('fee_intervals'), hasLength(1)); // orphan removed

    final currency = await CurrencyRepository().getByCode('EUR');
    expect(currency!.creationDatetime.year, 2025);
    await db.close();
  });

  test('repositories, cascade delete and CSV round trip', () async {
    AppDatabase.instance.overrideDatabase(openV4('${dir.path}/fresh.db'));
    await AppDatabase.instance.seedDefaultData();
    await AppDatabase.instance.seedDefaultData(); // idempotent

    final providers = ProviderRepository();
    final intervals = FeeIntervalRepository();
    final all = await providers.getAll();
    expect(all.map((p) => p.name), ['YAS', 'ORANGE', 'AIRTEL']);
    expect(await providers.findByName(' yas '), isNotNull);

    final yas = all.first;
    final overlap = await intervals.findOverlap(
      yas.id,
      FeeInterval(minAmount: 900, maxAmount: 1500, fee: 50),
    );
    expect(overlap, isNotNull);

    final l10n = lookupAppLocalizations(const Locale('en'));
    final currency = CurrencyProvider();
    await currency.initializeCurrency();
    expect(currency.isBaseCurrency, isTrue);

    final export = await CsvUtil.buildExport(locale: 'fr', exchangeRate: 1);
    expect(export.providers, 3);
    expect(export.intervals, 14 + 19 + 23);

    // Re-importing the export only reports overlaps; a new provider is added.
    final csv =
        '${export.csv}\r\nNOUVEAU,Banque,account_balance,1,1000,1.5,percentage';
    final result = await CsvUtil.importFromCsv(csv, currency, l10n);
    expect(result.providersCount, 1);
    expect(result.feeIntervalsCount, 1);
    expect(result.errors, hasLength(14 + 19 + 23));
    final created = await providers.findByName('nouveau');
    final createdIntervals = await intervals.getByProvider(created!.id);
    expect(createdIntervals.single.feeType, FeeType.percentage);
    expect(createdIntervals.single.fee, 1.5);

    await providers.delete([yas.id]);
    expect(await intervals.getByProvider(yas.id), isEmpty);

    final currencies = CurrencyRepository();
    final base = await currencies.getByCode('MGA');
    await currencies.delete([base!.id]);
    expect(await currencies.getByCode('MGA'), isNotNull); // protected
    await (await AppDatabase.instance.database).close();
  });
}
