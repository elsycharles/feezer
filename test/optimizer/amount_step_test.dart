import 'dart:math';

import 'package:feezer/core/optimizer/fee_comparison.dart';
import 'package:feezer/core/optimizer/fee_optimizer.dart';
import 'package:feezer/core/optimizer/fee_tier.dart';
import 'package:feezer/core/optimizer/naive_strategy.dart';
import 'package:feezer/data/legacy_defaults.dart';
import 'package:feezer/model/fee_interval_model.dart';
import 'package:feezer/model/fee_minimizer_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fee_optimizer_test.dart' show expectValidPlan;
import 'reference_solver.dart';

List<FeeInterval> legacy(String name) =>
    LegacyDefaults.providers.firstWhere((p) => p.name == name).feeIntervals;

bool isMultiple(double amount, double step) =>
    (amount / step - (amount / step).roundToDouble()).abs() < 1e-9;

void expectStepped(FeeOptimizerResult result, double step, String reason) {
  for (final detail in result.details) {
    expect(
      isMultiple(detail.amount, step),
      isTrue,
      reason: '$reason: ${detail.amount} is not a multiple of $step',
    );
  }
}

/// Random fixed-fee table with integer bounds and fees.
List<FeeInterval> randomIntervals(Random random) {
  final count = 1 + random.nextInt(5);
  final rows = <FeeInterval>[];
  var start = 1 + random.nextInt(300);
  var fee = 1 + random.nextInt(60);
  for (var i = 0; i < count; i++) {
    final end = start + 50 + random.nextInt(3000);
    rows.add(
      FeeInterval(
        minAmount: start.toDouble(),
        maxAmount: end.toDouble(),
        fee: fee.toDouble(),
      ),
    );
    start = end + 1 + (random.nextInt(4) == 0 ? random.nextInt(400) : 0);
    fee += random.nextInt(4) == 0
        ? -min(fee - 1, random.nextInt(20))
        : random.nextInt(120);
  }
  return rows;
}

void main() {
  group('tiers', () {
    test('bounds are rounded inwards to the step', () {
      final tiers = FeeTier.fromIntervals([
        FeeInterval(minAmount: 0, maxAmount: 1000, fee: 50),
        FeeInterval(minAmount: 1001, maxAmount: 5000, fee: 100),
        FeeInterval(minAmount: 5001, maxAmount: 5050, fee: 150),
      ], step: 100);
      expect(tiers.map((t) => (t.minAmount, t.maxAmount)), [
        (100, 1000),
        (1100, 5000),
      ]);
    });

    test('a step accepted by no tier is reported', () {
      final result = FeeOptimizer.optimize(100000, [
        FeeInterval(minAmount: 100, maxAmount: 900, fee: 50),
      ], step: 1000);
      expect(result.status, OptimizationStatus.stepTooLarge);
    });
  });

  group('known grids', () {
    test('every amount is a multiple of the step', () {
      final random = Random(3);
      for (final name in ['YAS', 'ORANGE', 'AIRTEL']) {
        final intervals = legacy(name);
        for (final step in [100.0, 500.0, 1000.0]) {
          final tiers = FeeTier.fromIntervals(intervals, step: step);
          for (var i = 0; i < 15; i++) {
            final budget = (1000 + random.nextInt(3000000)).toDouble();
            final result = FeeOptimizer.optimize(budget, intervals, step: step);
            final reason = '$name step $step budget $budget';
            expectStepped(result, step, reason);
            expectValidPlan(result, tiers);
            expect(result.isProvenOptimal, isTrue, reason: reason);
            final comparison = FeeComparison.compute(
              result,
              intervals,
              step: step,
            );
            expectStepped(comparison.withoutOptimization, step, reason);
            expect(
              comparison.extraNetAmount,
              greaterThanOrEqualTo(-1e-6),
              reason: reason,
            );
          }
        }
      }
    });

    test('a withdrawal of 10 500 in notes of 100', () {
      final result = FeeOptimizer.optimize(10500, legacy('YAS'), step: 100);
      expect(result.netAmount, 10000);
      expect(result.details.every((d) => isMultiple(d.amount, 100)), isTrue);
      final free = FeeOptimizer.optimize(10500, legacy('YAS'));
      expect(free.netAmount, 10050);
    });

    test('huge budgets stay fast', () {
      final watch = Stopwatch()..start();
      final percentage = [
        FeeInterval(
          minAmount: 1,
          maxAmount: 1000000,
          fee: 2,
          feeType: FeeType.percentage,
        ),
        FeeInterval(
          minAmount: 1000001,
          maxAmount: 10000000,
          fee: 1.5,
          feeType: FeeType.percentage,
        ),
      ];
      for (final intervals in [
        legacy('YAS'),
        legacy('ORANGE'),
        legacy('AIRTEL'),
        percentage,
      ]) {
        for (final budget in [99999999999.0, 1e15, 123456789.0]) {
          for (final step in [100.0, 5000.0]) {
            final result = FeeOptimizer.optimize(
              budget,
              intervals,
              step: step,
              minOperations: budget < 1e9 ? 3 : 0,
            );
            expectStepped(result, step, 'budget $budget step $step');
          }
        }
      }
      expect(watch.elapsedMilliseconds, lessThan(8000));
    });

    test('naive plans use the step too', () {
      final tiers = FeeTier.fromIntervals(legacy('ORANGE'), step: 500);
      for (final naive in NaiveStrategy.maxNetPlan(123456, tiers, step: 500)) {
        expect(isMultiple(naive.amount, 500), isTrue);
      }
    });
  });

  group('exactness against brute force', () {
    test('random tables and steps (unconstrained)', () {
      final random = Random(11);
      for (var trial = 0; trial < 80; trial++) {
        final intervals = randomIntervals(random);
        final step = [10, 50, 100, 200][random.nextInt(4)];
        final tiers = FeeTier.fromIntervals(intervals, step: step.toDouble());
        if (tiers.isEmpty) continue;
        final budget = 100 + random.nextInt(12000);
        final expected = SteppedReference(tiers, step).bestNet(budget);
        final result = FeeOptimizer.optimize(
          budget.toDouble(),
          intervals,
          step: step.toDouble(),
        );
        final reason = 'trial $trial step $step budget $budget tiers $tiers';
        if (expected <= 0) {
          expect(result.details, isEmpty, reason: reason);
          continue;
        }
        expect(result.netAmount, closeTo(expected, 1e-6), reason: reason);
        expectStepped(result, step.toDouble(), reason);
        expectValidPlan(result, tiers);
        expect(result.isProvenOptimal, isTrue, reason: reason);
      }
    });

    test('random tables and steps with min/max operations', () {
      final random = Random(5);
      for (var trial = 0; trial < 80; trial++) {
        final intervals = randomIntervals(random);
        final step = [10, 50, 100, 200][random.nextInt(4)];
        final tiers = FeeTier.fromIntervals(intervals, step: step.toDouble());
        if (tiers.isEmpty) continue;
        final budget = 100 + random.nextInt(6000);
        final minOps = random.nextBool() ? 0 : 1 + random.nextInt(4);
        final maxOps = random.nextBool() ? 0 : 1 + random.nextInt(5);
        final expected = SteppedReference(
          tiers,
          step,
        ).bestNet(budget, minCount: minOps, maxCount: maxOps);
        final result = FeeOptimizer.optimize(
          budget.toDouble(),
          intervals,
          minOperations: minOps,
          maxOperations: maxOps,
          step: step.toDouble(),
        );
        final reason =
            'trial $trial step $step budget $budget min $minOps max $maxOps '
            'tiers $tiers';
        if (expected == double.negativeInfinity || expected <= 0) {
          expect(result.details, isEmpty, reason: reason);
          continue;
        }
        expect(result.netAmount, closeTo(expected, 1e-6), reason: reason);
        expectStepped(result, step.toDouble(), reason);
        expectValidPlan(result, tiers);
        final ops = result.totalOperations;
        if (minOps > 0)
          expect(ops, greaterThanOrEqualTo(minOps), reason: reason);
        if (maxOps > 0) expect(ops, lessThanOrEqualTo(maxOps), reason: reason);
      }
    });
  });

  test(
    'percentage tiers: stepped, valid and never worse than random plans',
    () {
      final random = Random(21);
      for (var trial = 0; trial < 60; trial++) {
        final step = [50.0, 100.0, 500.0][random.nextInt(3)];
        final intervals = [
          for (final interval in randomIntervals(random))
            random.nextInt(3) == 0
                ? FeeInterval(
                    minAmount: interval.minAmount,
                    maxAmount: interval.maxAmount,
                    fee: (1 + random.nextInt(8)).toDouble(),
                    feeType: FeeType.percentage,
                  )
                : interval,
        ];
        final tiers = FeeTier.fromIntervals(intervals, step: step);
        if (tiers.isEmpty) continue;
        final budget = 200.0 + random.nextInt(40000);
        final result = FeeOptimizer.optimize(budget, intervals, step: step);
        final reason = 'trial $trial step $step budget $budget tiers $tiers';
        if (result.details.isEmpty) continue;
        expectStepped(result, step, reason);
        expectValidPlan(result, tiers);
        for (var sample = 0; sample < 200; sample++) {
          var remaining = budget;
          var net = 0.0;
          for (var i = 0; i < 8; i++) {
            final tier = tiers[random.nextInt(tiers.length)];
            final units = ((tier.maxAmount - tier.minAmount) / step).round();
            final amount = tier.minAmount + random.nextInt(units + 1) * step;
            final cost = tier.costFor(amount);
            if (cost > remaining) continue;
            remaining -= cost;
            net += amount;
          }
          expect(
            result.netAmount,
            greaterThanOrEqualTo(net - 1e-6),
            reason: reason,
          );
        }
      }
    },
  );
}
