import 'dart:math';

import 'package:fee_minimizer/core/optimizer/fee_optimizer.dart';
import 'package:fee_minimizer/core/optimizer/fee_tier.dart';
import 'package:fee_minimizer/model/fee_interval_model.dart';
import 'package:fee_minimizer/model/fee_minimizer_result_model.dart';
import 'package:fee_minimizer/data/legacy_defaults.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reference_solver.dart';

List<FeeTier> tiersOf(List<List<num>> rows, {FeeType type = FeeType.fixed}) =>
    FeeTier.fromIntervals([
      for (final r in rows)
        FeeInterval(
          minAmount: r[0].toDouble(),
          maxAmount: r[1].toDouble(),
          fee: r[2].toDouble(),
          feeType: type,
        ),
    ]);

List<FeeTier> providerTiers(String name) => FeeTier.fromIntervals(
  LegacyDefaults.providers.firstWhere((p) => p.name == name).feeIntervals,
);

/// Checks that a plan is executable: every amount belongs to a tier with the
/// announced fee, and the budget is respected.
void expectValidPlan(FeeOptimizerResult result, List<FeeTier> tiers) {
  final tol = 1e-6 * (result.budget + 1);
  for (final d in result.details) {
    expect(d.count, greaterThan(0));
    final matching = tiers.where(
      (t) =>
          t.contains(d.amount, tol) &&
          (t.feeFor(d.amount) - d.fee).abs() <= tol,
    );
    expect(matching, isNotEmpty, reason: 'invalid transaction $d');
  }
  expect(result.totalSpent, lessThanOrEqualTo(result.budget + tol));
}

void main() {
  group('known scenarios', () {
    final yas = providerTiers('YAS');

    test('splits 10 500 Ar to send more than a single transaction', () {
      final result = FeeOptimizer.optimizeTiers(10500, yas);
      expect(result.netAmount, 10050);
      expect(result.totalFees, 450);
      expect(result.totalOperations, 2);
      expectValidPlan(result, yas);
    });

    test('single transaction when it is optimal', () {
      final result = FeeOptimizer.optimizeTiers(2000000, yas);
      expect(result.netAmount, 1985000);
      expect(result.totalOperations, 1);
    });

    test('large budget uses the most efficient tier', () {
      final result = FeeOptimizer.optimizeTiers(100000000, yas);
      expectValidPlan(result, yas);
      expect(result.isProvenOptimal, isTrue);
      // 19 x 5 000 000 (fee 30 000) + remainder: fees can't be below 19 fees.
      expect(result.totalFees, lessThan(20 * 30000));
      expect(result.netAmount, greaterThan(100000000 * 0.993));
    });

    test('budget below the cheapest transaction', () {
      final result = FeeOptimizer.optimizeTiers(150, yas);
      expect(result.status, OptimizationStatus.budgetTooSmall);
      expect(result.details, isEmpty);
    });

    test('no tiers', () {
      final result = FeeOptimizer.optimize(1000, const []);
      expect(result.status, OptimizationStatus.noFeeIntervals);
    });

    test('percentage tiers', () {
      final tiers = tiersOf([
        [0, 1000000, 2],
        [1000000, 10000000, 1],
      ], type: FeeType.percentage);
      final result = FeeOptimizer.optimizeTiers(5050000, tiers);
      expect(result.netAmount, closeTo(5000000, 1e-6));
      expect(result.totalFees, closeTo(50000, 1e-6));
      expectValidPlan(result, tiers);
    });

    test('impossible constraints are reported', () {
      final result = FeeOptimizer.optimizeTiers(1000, yas, minOperations: 10);
      expect(result.status, OptimizationStatus.constraintsUnsatisfiable);
      final inverted = FeeOptimizer.optimizeTiers(
        100000,
        yas,
        minOperations: 5,
        maxOperations: 2,
      );
      expect(inverted.status, OptimizationStatus.constraintsUnsatisfiable);
    });

    test('max operations constraint is respected', () {
      final result = FeeOptimizer.optimizeTiers(10500, yas, maxOperations: 1);
      expect(result.totalOperations, 1);
      expect(result.netAmount, 10000);
    });

    test('huge budgets stay fast', () {
      final watch = Stopwatch()..start();
      for (final name in ['YAS', 'ORANGE', 'AIRTEL']) {
        final tiers = providerTiers(name);
        for (final budget in [99999999999.0, 1e15, 123456789.0]) {
          final result = FeeOptimizer.optimizeTiers(budget, tiers);
          expectValidPlan(result, tiers);
        }
      }
      expect(watch.elapsedMilliseconds, lessThan(5000));
    });
  });

  group('exactness against brute force', () {
    test('default providers, many budgets', () {
      final random = Random(7);
      for (final name in ['YAS', 'ORANGE', 'AIRTEL']) {
        final tiers = providerTiers(name);
        final reference = ReferenceSolver(tiers);
        for (var i = 0; i < 25; i++) {
          final budget = 150 + random.nextInt(120000);
          final result = FeeOptimizer.optimizeTiers(budget.toDouble(), tiers);
          expect(
            result.netAmount,
            closeTo(reference.bestNet(budget), 1e-6),
            reason: '$name budget $budget',
          );
          expectValidPlan(result, tiers);
          expect(result.isProvenOptimal, isTrue);
        }
      }
    });

    test('random fee tables (unconstrained)', () {
      final random = Random(42);
      for (var trial = 0; trial < 120; trial++) {
        final tiers = randomTiers(random);
        final reference = ReferenceSolver(tiers);
        final budget = 50 + random.nextInt(40000);
        final result = FeeOptimizer.optimizeTiers(budget.toDouble(), tiers);
        final expected = reference.bestNet(budget);
        if (expected == 0) {
          expect(result.netAmount, 0, reason: 'trial $trial');
        } else {
          expect(
            result.netAmount,
            closeTo(expected, 1e-6),
            reason: 'trial $trial budget $budget tiers $tiers',
          );
          expectValidPlan(result, tiers);
        }
      }
    });

    test('random fee tables with min/max operations', () {
      final random = Random(1234);
      for (var trial = 0; trial < 150; trial++) {
        final tiers = randomTiers(random);
        final reference = ReferenceSolver(tiers);
        final budget = 50 + random.nextInt(15000);
        final minOps = random.nextBool() ? 0 : 1 + random.nextInt(6);
        final maxOps = random.nextBool() ? 0 : 1 + random.nextInt(6);
        double expected;
        if (maxOps > 0) {
          final byCount = reference.bestNetByCount(budget, maxOps);
          expected = double.negativeInfinity;
          for (var k = max(1, minOps); k <= maxOps; k++) {
            expected = max(expected, byCount[k]);
          }
        } else {
          expected = reference.bestNetAtLeast(budget, minOps);
        }
        final result = FeeOptimizer.optimizeTiers(
          budget.toDouble(),
          tiers,
          minOperations: minOps,
          maxOperations: maxOps,
        );
        final reason =
            'trial $trial budget $budget min $minOps max $maxOps tiers $tiers';
        if (expected == double.negativeInfinity || expected <= 0) {
          expect(result.details, isEmpty, reason: reason);
          continue;
        }
        expect(result.netAmount, closeTo(expected, 1e-6), reason: reason);
        expectValidPlan(result, tiers);
        final ops = result.totalOperations;
        if (minOps > 0) {
          expect(ops, greaterThanOrEqualTo(minOps), reason: reason);
        }
        if (maxOps > 0) {
          expect(ops, lessThanOrEqualTo(maxOps), reason: reason);
        }
      }
    });
  });

  group('mixed fixed / percentage tables', () {
    test('never worse than random valid plans', () {
      final random = Random(99);
      for (var trial = 0; trial < 60; trial++) {
        final tiers = randomTiers(random, allowPercentage: true);
        final budget = 100.0 + random.nextInt(50000);
        final result = FeeOptimizer.optimizeTiers(budget, tiers);
        if (result.details.isNotEmpty) expectValidPlan(result, tiers);
        for (var sample = 0; sample < 200; sample++) {
          final net = randomPlanNet(random, tiers, budget);
          expect(
            result.netAmount,
            greaterThanOrEqualTo(net - 1e-6),
            reason: 'trial $trial tiers $tiers budget $budget',
          );
        }
      }
    });
  });
}

/// Random contiguous (sometimes gapped) tier table with integer values.
List<FeeTier> randomTiers(Random random, {bool allowPercentage = false}) {
  final count = 1 + random.nextInt(6);
  final rows = <FeeInterval>[];
  var start = 1 + random.nextInt(300);
  var fee = 1 + random.nextInt(60);
  for (var i = 0; i < count; i++) {
    final width = 50 + random.nextInt(4000);
    final end = start + width;
    final percentage = allowPercentage && random.nextInt(3) == 0;
    rows.add(
      FeeInterval(
        minAmount: start.toDouble(),
        maxAmount: end.toDouble(),
        fee: percentage ? (1 + random.nextInt(8)).toDouble() : fee.toDouble(),
        feeType: percentage ? FeeType.percentage : FeeType.fixed,
      ),
    );
    start = end + 1 + (random.nextInt(4) == 0 ? random.nextInt(500) : 0);
    fee += random.nextInt(4) == 0
        ? -min(fee - 1, random.nextInt(20))
        : random.nextInt(120);
  }
  return FeeTier.fromIntervals(rows);
}

/// Net amount of a random valid plan (random tier choices and amounts).
double randomPlanNet(Random random, List<FeeTier> tiers, double budget) {
  var remaining = budget;
  var net = 0.0;
  for (var i = 0; i < 8; i++) {
    final tier = tiers[random.nextInt(tiers.length)];
    final amount =
        tier.minAmount +
        random.nextDouble() * (tier.maxAmount - tier.minAmount);
    final cost = tier.costFor(amount);
    if (cost > remaining) continue;
    remaining -= cost;
    net += amount;
  }
  return net;
}
