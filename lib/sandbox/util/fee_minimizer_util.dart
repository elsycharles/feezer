import 'dart:math';
import '../model/fee_interval_model.dart';
import '../model/fee_minimizer_result_model.dart';
import '../model/fee_minimizer_detail_model.dart';
import 'constant_util.dart';

class FeeOptimizerUtil {
  static FeeOptimizerResult calculateOptimalOperations(
    double totalAmount,
    List<FeeInterval> intervals, {
    double precision = ConstantUtil.defaultPrecision,
    int maxOperations = 0,
    int minOperations = 0,
  }) {
    _validateInput(totalAmount, intervals, maxOperations, minOperations);
    
    final options = _normalizeOptions(intervals);
    final unlimitedResult = totalAmount <= ConstantUtil.threshold
        ? _selectBest([
            _greedyOptimized(totalAmount, options, precision),
            _repeatedOperations(totalAmount, options, precision),
          ])
        : _greedyOptimized(totalAmount, options, precision);

    return _applyConstraints(
      unlimitedResult, totalAmount, options, precision, maxOperations, minOperations,
    );
  }

  static FeeInterval? findBestOption(double amount, List<FeeInterval> intervals) {
    final validIntervals = intervals.where((interval) => interval.isValid).toList();
    
    FeeInterval? best;
    double bestEfficiency = -1;

    for (final interval in validIntervals) {
      if (amount >= interval.minAmount! && amount <= interval.maxAmount!) {
        final efficiency = (amount - interval.fee!) / interval.fee!;
        if (efficiency > bestEfficiency) {
          bestEfficiency = efficiency;
          best = interval;
        }
      }
    }

    return best;
  }

  // Méthodes privées
  static List<_FeeOption> _normalizeOptions(List<FeeInterval> intervals) {
    final validIntervals = intervals.where((interval) => interval.isValid).toList();
    
    final options = validIntervals.map((interval) => _FeeOption(
      min: interval.minAmount!,
      max: interval.maxAmount!,
      fee: interval.fee!,
    )).toList();

    options.sort((a, b) => (b.max / b.fee).compareTo(a.max / a.fee));
    return options;
  }

  static void _validateInput(
    double totalAmount, 
    List<FeeInterval> intervals, 
    int maxOperations, 
    int minOperations,
  ) {
    if (totalAmount <= 0) throw ArgumentError('Le montant doit être positif');
    if (intervals.isEmpty) throw ArgumentError('Aucune option disponible');
    if (maxOperations < 0) throw ArgumentError('maxOperations doit être >= 0');
    if (minOperations < 0) throw ArgumentError('minOperations doit être >= 0');
    if (minOperations > 0 && maxOperations > 0 && minOperations > maxOperations) {
      throw ArgumentError('minOperations ne peut pas être supérieur à maxOperations');
    }
  }

  static FeeOptimizerResult _applyConstraints(
    FeeOptimizerResult unlimitedResult,
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    final actualCount = unlimitedResult.totalOperations;

    if (maxOperations == 0 && minOperations == 0) return unlimitedResult;
    if (maxOperations > 0 && minOperations == 0 && actualCount <= maxOperations) {
      return unlimitedResult;
    }
    if (minOperations > 0 && maxOperations == 0 && actualCount >= minOperations) {
      return unlimitedResult;
    }
    if (actualCount >= minOperations && actualCount <= maxOperations) return unlimitedResult;

    if (actualCount < minOperations) {
      return _minConstrainedOperations(totalAmount, options, precision, minOperations, maxOperations);
    }

    return _constrainedOperations(totalAmount, options, precision, maxOperations, minOperations);
  }

  static FeeOptimizerResult _greedyOptimized(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
  ) {
    final counts = <String, int>{};
    double budget = totalAmount;
    double totalNet = 0;
    double totalFees = 0;

    while (budget > 0) {
      final best = _findBestOperation(budget, options, precision);
      if (best == null) break;

      final key = '${best.amount}-${best.fee}';
      counts[key] = (counts[key] ?? 0) + 1;
      totalNet += best.amount;
      totalFees += best.fee;
      budget -= best.amount + best.fee;
    }

    return _buildResult(totalAmount, totalNet, totalFees, budget, counts);
  }

  static FeeOptimizerResult _repeatedOperations(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
  ) {
    FeeOptimizerResult bestResult = _greedyOptimized(totalAmount, options, precision);

    for (final opt in options) {
      final step = max(precision, (opt.max - opt.min) / 15);

      for (double amt = opt.max; amt >= opt.min; amt -= step) {
        final amount = (amt / precision).floor() * precision;
        if (amount < opt.min) continue;

        final cost = amount + opt.fee;
        final count = (totalAmount / cost).floor();
        if (count == 0) continue;

        final net = amount * count;
        final fees = opt.fee * count;
        final remaining = totalAmount - cost * count;

        if (net > bestResult.netAmount || 
            (net == bestResult.netAmount && fees < bestResult.totalFees)) {
          final counts = <String, int>{'$amount-${opt.fee}': count};
          bestResult = _buildResult(totalAmount, net, fees, remaining, counts);
        }
      }
    }

    return bestResult;
  }

  static FeeOptimizerResult _constrainedOperations(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    final results = <FeeOptimizerResult>[];
    final start = max(1, minOperations);
    final end = min(maxOperations, 50);

    for (int numOperations = start; numOperations <= end; numOperations++) {
      final counts = <String, int>{};
      double budget = totalAmount;
      double net = 0;
      double fees = 0;

      for (int i = 0; i < numOperations; i++) {
        if (budget <= 0) break;
        final best = _findBestOperation(budget, options, precision);
        if (best == null) break;

        final key = '${best.amount}-${best.fee}';
        counts[key] = (counts[key] ?? 0) + 1;
        net += best.amount;
        fees += best.fee;
        budget -= best.amount + best.fee;
      }

      if (net > 0) {
        results.add(_buildResult(totalAmount, net, fees, budget, counts));
      }
    }

    return results.isEmpty 
        ? _buildResult(totalAmount, 0, 0, totalAmount, {})
        : _selectBest(results);
  }

  static FeeOptimizerResult _minConstrainedOperations(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int minOperations, [
    int maxOperations = 0,
  ]) {
    final results = <FeeOptimizerResult>[];
    final end = maxOperations > 0 ? min(maxOperations, 100) : 100;

    for (int numOperations = minOperations; numOperations <= end; numOperations++) {
      final result = _distributeOptimally(totalAmount, options, precision, numOperations);
      if (result != null) results.add(result);
    }

    return results.isEmpty
        ? _buildResult(totalAmount, 0, 0, totalAmount, {})
        : _selectBest(results);
  }

  static FeeOptimizerResult? _distributeOptimally(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int targetCount,
  ) {
    final counts = <String, int>{};
    double net = 0;
    double fees = 0;
    double budget = totalAmount;

    for (int i = 0; i < targetCount; i++) {
      final remaining = budget;
      final remainingOperations = targetCount - i;
      final targetAmount = remaining / remainingOperations;

      _BestOperation? best;

      for (final opt in options) {
        final maxAmount = min(opt.max, remaining - opt.fee);
        if (maxAmount < opt.min) continue;

        double amount = min(maxAmount, max(opt.min, targetAmount - opt.fee));
        amount = (amount / precision).floor() * precision;

        if (amount < opt.min) amount = opt.min;
        if (amount > maxAmount) continue;

        final efficiency = amount / opt.fee;
        final proximity = 1 / (1 + (amount - targetAmount).abs());
        final score = efficiency * 10 + proximity * amount;

        if (best == null || score > best.score) {
          best = _BestOperation(amount: amount, fee: opt.fee, score: score);
        }
      }

      if (best == null) {
        final fallback = _findBestOperation(remaining, options, precision);
        if (fallback == null) break;
        best = _BestOperation(amount: fallback.amount, fee: fallback.fee, score: 0);
      }

      final key = '${best.amount}-${best.fee}';
      counts[key] = (counts[key] ?? 0) + 1;
      net += best.amount;
      fees += best.fee;
      budget -= best.amount + best.fee;
    }

    final actualCount = counts.values.fold(0, (sum, count) => sum + count);
    return actualCount < targetCount ? null : _buildResult(totalAmount, net, fees, budget, counts);
  }

  static _BestOperation? _findBestOperation(
    double budget,
    List<_FeeOption> options,
    double precision,
  ) {
    _BestOperation? best;

    for (final opt in options) {
      final maxAmount = min(opt.max, budget - opt.fee);
      if (maxAmount < opt.min) continue;

      final amount = (maxAmount / precision).floor() * precision;
      if (amount < opt.min) continue;

      final score = (amount * amount) / opt.fee;

      if (best == null || score > best.score) {
        best = _BestOperation(amount: amount, fee: opt.fee, score: score);
      }
    }

    return best;
  }

  static FeeOptimizerResult _buildResult(
    double totalAmount,
    double netAmount,
    double totalFees,
    double remaining,
    Map<String, int> counts,
  ) {
    final details = counts.entries.map((entry) {
      final parts = entry.key.split('-');
      return FeeOptimizerDetail(
        amount: double.parse(parts[0]),
        fee: double.parse(parts[1]),
        count: entry.value,
      );
    }).toList();

    return FeeOptimizerResult(
      totalAmount: totalAmount,
      netAmount: netAmount,
      totalFees: totalFees,
      remaining: remaining,
      details: details,
    );
  }

  static FeeOptimizerResult _selectBest(List<FeeOptimizerResult> results) {
    return results.reduce((best, curr) {
      if (curr.netAmount > best.netAmount) return curr;
      if (curr.netAmount == best.netAmount && curr.totalFees < best.totalFees) return curr;
      if (curr.netAmount == best.netAmount && 
          curr.totalFees == best.totalFees && 
          curr.remaining < best.remaining) return curr;
      return best;
    });
  }
}

// Classes internes pour l'optimisation
class _FeeOption {
  _FeeOption({required this.min, required this.max, required this.fee});
  final double min;
  final double max;
  final double fee;
}

class _BestOperation {
  _BestOperation({required this.amount, required this.fee, required this.score});
  final double amount;
  final double fee;
  final double score;
}