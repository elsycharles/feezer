import 'dart:convert';
import 'dart:io';

import 'package:feezer/data/app_database.dart';
import 'package:feezer/data/default_data.dart';
import 'package:feezer/data/fee_interval_repository.dart';
import 'package:feezer/data/fee_table_service.dart';
import 'package:feezer/data/legacy_defaults.dart';
import 'package:feezer/data/provider_repository.dart';
import 'package:feezer/l10n/app_localizations.dart';
import 'package:feezer/model/fee_interval_model.dart';
import 'package:feezer/model/fee_operation.dart';
import 'package:feezer/model/provider_model.dart';
import 'package:feezer/util/csv_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openDb(String path) => databaseFactoryFfi.openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: Db.version,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onCreate: AppDatabase.createSchema,
    onUpgrade: AppDatabase.upgradeSchema,
  ),
);

/// Asset bundle serving one text file.
class TextBundle extends CachingAssetBundle {
  TextBundle(this.text);

  final String text;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
}

Map<String, Object?> grid(
  String name,
  String operation,
  List<List<num>> tiers, {
  String type = 'official',
  String url = 'https://www.example.mg/tarifs',
  String? date = '2025-02-17',
}) => {
  'name': name,
  'operation': operation,
  'description': '$name $operation',
  'icon': 'phone_android',
  'source': {'type': type, 'url': url, 'effectiveDate': date},
  'intervals': [
    for (final t in tiers)
      {'min': t[0], 'max': t[1], 'fee': t[2], 'type': 'fixed'},
  ],
};

/// Bundled fee tables used by the tests (schema 2).
final bundled = jsonEncode({
  'schema': 2,
  'updatedAt': '2026-11-20',
  'checkedAt': '2026-11-20',
  'providers': [
    grid('MVola', 'withdrawal', [
      [100, 1000, 50],
      [1001, 5000, 100],
      [5001, 10000, 200],
    ]),
    grid('MVola', 'transfer_same', [
      [100, 1000, 20],
      [1001, 5000, 50],
      [5001, 10000, 100],
    ]),
    grid(
      'Airtel Money',
      'withdrawal',
      [
        [300, 1000, 100],
        [1001, 5000, 200],
        [5001, 10000, 300],
      ],
      type: 'manual',
      date: null,
    ),
  ],
});

void main() {
  sqfliteFfiInit();
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('feezer_db_test');
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await (await AppDatabase.instance.database).close();
    await dir.delete(recursive: true);
  });

  test('upgrade from version 3 keeps user data and cleans up', () async {
    final path = '${dir.path}/v3.db';
    // Schema and data as written by the first versions of the app.
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

    AppDatabase.instance.overrideDatabase(openDb(path));
    final db = await AppDatabase.instance.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final names = tables.map((t) => t['name']).toSet();
    expect(names, isNot(contains('optimization_results')));
    expect(names, isNot(contains('currencies')));
    expect(names, containsAll(['fee_intervals', Db.meta]));

    final provider = (await ProviderRepository().getAll()).single;
    expect(provider.name, 'YAS');
    expect(provider.operation, isNull);
    expect(provider.sourceType, isNull);
    expect(
      await FeeIntervalRepository().getByProvider(provider.id),
      hasLength(1),
    );
    expect(await db.query('fee_intervals'), hasLength(1)); // orphan removed

    await AppDatabase.instance.setMeta('key', 'value');
    expect(await AppDatabase.instance.getMeta('key'), 'value');
  });

  test(
    'bundled grids are installed once, unmodified 1.x grids replaced',
    () async {
      AppDatabase.instance.overrideDatabase(openDb('${dir.path}/seed.db'));
      final providers = ProviderRepository();
      final intervals = FeeIntervalRepository();
      // Grids of version 1.x: YAS untouched, ORANGE changed by the user.
      for (final legacy in LegacyDefaults.providers.take(2)) {
        final provider = await providers.insert(
          Provider(id: '', name: legacy.name, iconName: legacy.iconName),
        );
        final tiers = legacy.feeIntervals;
        if (legacy.name == 'ORANGE') {
          tiers[0] = FeeInterval(
            minAmount: tiers[0].minAmount,
            maxAmount: tiers[0].maxAmount,
            fee: 1,
          );
        }
        for (final tier in tiers) {
          await intervals.insert(tier, provider.id);
        }
      }

      await DefaultData.ensureSeeded(bundle: TextBundle(bundled));
      await DefaultData.ensureSeeded(bundle: TextBundle(bundled)); // runs once

      final all = await providers.getAll();
      expect(all.map((p) => '${p.name}|${p.operation?.key}').toSet(), {
        'ORANGE|null',
        'MVola|withdrawal',
        'MVola|transfer_same',
        'Airtel Money|withdrawal',
      });
      final withdrawal = await providers.findByName(
        ' mvola ',
        operation: FeeOperation.withdrawal,
      );
      expect(withdrawal!.sourceType, Provider.officialSource);
      expect(withdrawal.sourceUrl, 'https://www.example.mg/tarifs');
      expect(withdrawal.effectiveDate, DateTime(2025, 2, 17));
      expect(await intervals.getByProvider(withdrawal.id), hasLength(3));
      final airtel = await providers.findByName(
        'Airtel Money',
        operation: FeeOperation.withdrawal,
      );
      expect(airtel!.sourceType, Provider.manualSource);
      expect(airtel.effectiveDate, isNull);

      // A grid deleted by the user is not installed again.
      await providers.delete([withdrawal.id]);
      await DefaultData.ensureSeeded(bundle: TextBundle(bundled));
      expect(
        await providers.findByName('MVola', operation: FeeOperation.withdrawal),
        isNull,
      );
      // Seeding is not a download from the internet.
      expect(await FeeTableService.lastUpdate(), isNull);
      expect(await FeeTableService.lastCheck(), isNull);
    },
  );

  test('repositories, cascade delete and CSV round trip', () async {
    AppDatabase.instance.overrideDatabase(openDb('${dir.path}/csv.db'));
    await DefaultData.ensureSeeded(bundle: TextBundle(bundled));
    final providers = ProviderRepository();
    final intervals = FeeIntervalRepository();

    final withdrawal = await providers.findByName(
      'MVOLA',
      operation: FeeOperation.withdrawal,
    );
    expect(withdrawal, isNotNull);
    expect(await providers.findByName('MVola'), isNull); // no operation
    final overlap = await intervals.findOverlap(
      withdrawal!.id,
      FeeInterval(minAmount: 900, maxAmount: 1500, fee: 50),
    );
    expect(overlap, isNotNull);

    final export = await CsvUtil.buildExport(locale: 'fr');
    expect(export.providers, 3);
    expect(export.intervals, 9);

    // Re-importing the export only reports overlaps; new rows are added.
    final csv =
        '${export.csv}\r\n'
        'NOUVEAU,Banque,account_balance,1,1000,1.5,percentage,\r\n'
        'MVola,,,10001,20000,300,fixed,withdrawal';
    final l10n = lookupAppLocalizations(const Locale('en'));
    final result = await CsvUtil.importFromCsv(csv, l10n);
    expect(result.providersCount, 1);
    expect(result.feeIntervalsCount, 2);
    expect(result.errors, hasLength(9));

    final created = await providers.findByName('nouveau');
    expect(created!.operation, isNull);
    final createdIntervals = await intervals.getByProvider(created.id);
    expect(createdIntervals.single.feeType, FeeType.percentage);
    expect(createdIntervals.single.fee, 1.5);

    // The official grid that received a tier is no longer the published one.
    final edited = await providers.findByName(
      'MVola',
      operation: FeeOperation.withdrawal,
    );
    expect(edited!.sourceType, Provider.editedSource);
    expect(await intervals.getByProvider(edited.id), hasLength(4));
    // Grids entered in the app have no source to mark.
    await providers.markEdited(created.id);
    expect((await providers.findByName('nouveau'))!.sourceType, isNull);

    await providers.delete([edited.id]);
    expect(await intervals.getByProvider(edited.id), isEmpty);
  });

  test('official grids are downloaded, compared and applied', () async {
    AppDatabase.instance.overrideDatabase(openDb('${dir.path}/update.db'));
    await DefaultData.ensureSeeded(bundle: TextBundle(bundled));
    final providers = ProviderRepository();
    final mine = await providers.insert(Provider(id: '', name: 'My bank'));
    final withdrawal = await providers.findByName(
      'MVola',
      operation: FeeOperation.withdrawal,
    );
    await providers.markEdited(withdrawal!.id);

    final body = jsonEncode({
      'schema': 2,
      'updatedAt': '2026-11-22',
      'checkedAt': '2026-11-24',
      'providers': [
        grid('MVola', 'withdrawal', [
          [100, 1000, 60],
          [1001, 5000, 100],
          [5001, 10000, 200],
        ], date: '2026-11-01'),
        grid('MVola', 'transfer_same', [
          [100, 1000, 20],
          [1001, 5000, 50],
          [5001, 10000, 100],
        ]),
        grid('Orange Money', 'withdrawal', [
          [100, 1000, 50],
          [1001, 5000, 100],
          [5001, 10000, 150],
        ]),
        // Operation unknown to this version of the app: skipped.
        grid('MVola', 'teleportation', [
          [1, 10, 1],
          [11, 20, 2],
          [21, 30, 3],
        ]),
      ],
    });
    final service = FeeTableService(
      client: MockClient(
        (request) async => http.Response.bytes(utf8.encode(body), 200),
      ),
    );
    final tables = await service.fetch();
    expect(tables.updatedAt, DateTime(2026, 11, 22));
    expect(tables.checkedAt, DateTime(2026, 11, 24));
    expect(tables.grids, hasLength(3));

    String label(RemoteGrid g) => '${g.name}|${g.operation?.key}';
    final plan = await service.plan(tables);
    expect(plan.updated.map(label), ['MVola|withdrawal']);
    expect(plan.created.map(label), ['Orange Money|withdrawal']);
    expect(plan.unchanged.map(label), ['MVola|transfer_same']);
    expect(plan.hasChanges, isTrue);

    await service.apply(tables);
    final updated = await providers.findByName(
      'MVola',
      operation: FeeOperation.withdrawal,
    );
    expect(updated!.sourceType, Provider.officialSource); // edit replaced
    expect(updated.effectiveDate, DateTime(2026, 11, 1));
    final tiers = await FeeIntervalRepository().getByProvider(updated.id);
    expect(tiers.first.fee, 60);
    // Grids that are not published are kept.
    expect(
      await providers.findByName(
        'Airtel Money',
        operation: FeeOperation.withdrawal,
      ),
      isNotNull,
    );
    expect(await providers.findByName(mine.name), isNotNull);
    expect((await service.plan(tables)).hasChanges, isFalse);
    expect(await FeeTableService.lastUpdate(), isNotNull);
    expect(await FeeTableService.lastCheck(), DateTime(2026, 11, 24));

    expect(
      () => FeeTableService.parse(
        '{"providers": [{"name": "X", "intervals": '
        '[{"min": 1, "max": 10, "fee": 1}, {"min": 5, "max": 20, "fee": 1}]}]}',
      ),
      throwsFormatException,
    );
    expect(
      () => FeeTableService.parse(
        '{"providers": [{"name": "X", "operation": "withdrawal"}, '
        '{"name": "x", "operation": "withdrawal"}]}',
      ),
      throwsFormatException,
    );
    final failing = FeeTableService(
      client: MockClient((_) async => http.Response('nope', 404)),
    );
    await expectLater(failing.fetch(), throwsA(isA<http.ClientException>()));
  });
}
