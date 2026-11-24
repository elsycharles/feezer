import '../model/fee_interval_model.dart';

/// A provider shipped with the application (seeded on first launch).
class DefaultProvider {
  const DefaultProvider({
    required this.name,
    required this.description,
    required this.iconName,
    required this.tiers,
  });

  final String name;
  final String description;
  final String iconName;

  /// `(minAmount, maxAmount, fixedFee)` in Ariary.
  final List<(double, double, double)> tiers;

  List<FeeInterval> get feeIntervals => [
    for (final (min, max, fee) in tiers)
      FeeInterval(minAmount: min, maxAmount: max, fee: fee),
  ];
}

/// Default providers with their fee intervals (fixed fees, in Ariary).
class ProviderData {
  const ProviderData._();

  static const List<DefaultProvider> defaultProviders = [
    DefaultProvider(
      name: 'YAS',
      description:
          'Principal opérateur télécom de Madagascar, anciennement Telma, offrant la 5G, la fibre et la plus large couverture nationale sous le groupe Axian Telecom.',
      iconName: 'phone_android',
      // Updated fee intervals for YAS (values supplied by user) - 14/10/2025
      tiers: [
        (100.0, 1000.0, 100.0),
        (1001.0, 5000.0, 175.0),
        (5001.0, 10000.0, 350.0),
        (10001.0, 20000.0, 700.0),
        (20001.0, 25000.0, 700.0),
        (25001.0, 50000.0, 1500.0),
        (50001.0, 100000.0, 2000.0),
        (100001.0, 250000.0, 3500.0),
        (250001.0, 500000.0, 4800.0),
        (500001.0, 1000000.0, 9000.0),
        (1000001.0, 2000000.0, 15000.0),
        (2000001.0, 3000000.0, 20000.0),
        (3000001.0, 4000000.0, 25000.0),
        (4000001.0, 5000000.0, 30000.0),
      ],
    ),
    DefaultProvider(
      name: 'ORANGE',
      description:
          'Groupe mondial de télécommunications offrant à Madagascar des services mobiles et Internet complets pour particuliers et entreprises.',
      iconName: 'phone_android',
      tiers: [
        (200.0, 1000.0, 100.0),
        (1001.0, 5000.0, 140.0),
        (5001.0, 10000.0, 275.0),
        (10001.0, 20000.0, 500.0),
        (20001.0, 25000.0, 650.0),
        (25001.0, 50000.0, 1300.0),
        (50001.0, 100000.0, 1900.0),
        (100001.0, 250000.0, 3400.0),
        (250001.0, 500000.0, 4800.0),
        (500001.0, 1000000.0, 8700.0),
        (1000001.0, 2000000.0, 14700.0),
        (2000001.0, 3000000.0, 19600.0),
        (3000001.0, 4000000.0, 24500.0),
        (4000001.0, 5000000.0, 29400.0),
        (5000001.0, 6000000.0, 34300.0),
        (6000001.0, 7000000.0, 39200.0),
        (7000001.0, 8000000.0, 44100.0),
        (8000001.0, 9000000.0, 49000.0),
        (9000001.0, 10000000.0, 53900.0),
      ],
    ),
    DefaultProvider(
      name: 'AIRTEL',
      description:
          'Opérateur majeur en Afrique, misant sur la 4G et les services financiers mobiles, présent activement à Madagascar.',
      iconName: 'phone_android',
      tiers: [
        (300.0, 1000.0, 100.0),
        (1001.0, 5000.0, 140.0),
        (5001.0, 10000.0, 275.0),
        (10001.0, 20000.0, 550.0),
        (20001.0, 25000.0, 650.0),
        (25001.0, 30000.0, 1300.0),
        (30001.0, 35000.0, 1300.0),
        (35001.0, 40000.0, 1300.0),
        (40001.0, 50000.0, 1300.0),
        (50001.0, 60000.0, 1900.0),
        (60001.0, 100000.0, 1900.0),
        (100001.0, 250000.0, 3400.0),
        (250001.0, 500000.0, 4800.0),
        (500001.0, 1000000.0, 8800.0),
        (1000001.0, 2000000.0, 14700.0),
        (2000001.0, 3000000.0, 19600.0),
        (3000001.0, 4000000.0, 24500.0),
        (4000001.0, 5000000.0, 29400.0),
        (5000001.0, 6000000.0, 34300.0),
        (6000001.0, 7000000.0, 39200.0),
        (7000001.0, 8000000.0, 44100.0),
        (8000001.0, 9000000.0, 49000.0),
        (9000001.0, 10000000.0, 53900.0),
      ],
    ),
  ];
}
