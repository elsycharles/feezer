import 'package:feezer/core/optimizer/fee_comparison.dart';
import 'package:feezer/core/optimizer/fee_optimizer.dart';
import 'package:feezer/model/fee_interval_model.dart';
import 'package:feezer/model/provider_model.dart';
import 'package:feezer/data/legacy_defaults.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeeInterval', () {
    test('round trip and tolerant parsing', () {
      final interval = FeeInterval(
        id: '7',
        minAmount: 100,
        maxAmount: 1000,
        fee: 2.5,
        feeType: FeeType.percentage,
      );
      final copy = FeeInterval.fromMap(FeeInterval.toMap(interval, '3'));
      expect(copy.id, '7');
      expect(copy.feeType, FeeType.percentage);
      expect(copy.fee, 2.5);
      expect(
        FeeInterval.fromMap({'id': 1, 'fee_type': 9}).feeType,
        FeeType.fixed,
      );
    });

    test('new intervals let SQLite assign the id', () {
      final map = FeeInterval.toMap(
        FeeInterval(minAmount: 1, maxAmount: 2, fee: 1),
        '3',
      );
      expect(map.containsKey('id'), isFalse);
    });

    test('inclusive overlap', () {
      FeeInterval i(double a, double b) =>
          FeeInterval(minAmount: a, maxAmount: b, fee: 1);
      expect(i(0, 1000).overlaps(i(1000, 2000)), isTrue);
      expect(i(0, 1000).overlaps(i(1001, 2000)), isFalse);
      expect(i(0, 5000).overlaps(i(100, 200)), isTrue);
    });

    test('validity', () {
      expect(
        FeeInterval(
          minAmount: 1,
          maxAmount: 2,
          fee: 101,
          feeType: FeeType.percentage,
        ).isValid,
        isFalse,
      );
      expect(FeeInterval(minAmount: 2, maxAmount: 2, fee: 1).isValid, isFalse);
      expect(FeeInterval(minAmount: 1, maxAmount: 2).isValid, isFalse);
    });

    test('equality without ids does not merge different intervals', () {
      final a = FeeInterval(minAmount: 1, maxAmount: 2, fee: 1);
      final b = FeeInterval(minAmount: 1, maxAmount: 3, fee: 1);
      expect(a == b, isFalse);
    });
  });

  test('Provider without id is inserted with an automatic id', () {
    expect(
      Provider.toMap(Provider(id: '', name: 'X')).containsKey('id'),
      isFalse,
    );
  });

  group('comparison', () {
    final intervals = LegacyDefaults.providers.first.feeIntervals;

    test('optimization never sends less than the naive strategy', () {
      for (final budget in [10500.0, 25700.0, 2058989.0, 31234567.0]) {
        final optimized = FeeOptimizer.optimize(budget, intervals);
        final comparison = FeeComparison.compute(optimized, intervals);
        expect(comparison.extraNetAmount, greaterThanOrEqualTo(-1e-6));
        final saved = comparison.feesSavedForSameNet;
        if (saved != null) expect(saved, greaterThanOrEqualTo(-1e-6));
      }
    });

    test('known example: 10 500 Ar', () {
      final optimized = FeeOptimizer.optimize(10500, intervals);
      final comparison = FeeComparison.compute(optimized, intervals);
      expect(comparison.withoutOptimization.netAmount, 10000);
      expect(comparison.extraNetAmount, 50);
      // Sending 10 050 by hand: one 10 050 transaction (fee 700).
      expect(comparison.sameNetWithoutOptimization!.totalFees, 700);
      expect(comparison.sameNetExceedsBudget, isTrue);
    });
  });
}
