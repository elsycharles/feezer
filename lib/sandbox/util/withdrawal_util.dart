import 'dart:math';
import '../model/withdrawal_model.dart';
import '../model/withdrawal_option_model.dart';
import '../model/withdrawal_detail_model.dart';
import '../model/optimal_withdrawal_result_model.dart';

/// Utility for optimizing withdrawals and minimizing fees
class WithdrawalUtil {
  /// Calculate optimal withdrawals to minimize fees
  static OptimalWithdrawalResult calculateOptimalWithdrawals(
    double totalAmount,
    List<Withdrawal> options, {
    double precision = 1.0,
    int maxWithdrawals = 0,
    int minWithdrawals = 0,
  }) {
    // Validations
    if (totalAmount <= 0) {
      throw ArgumentError('Amount must be positive');
    }
    if (options.isEmpty) {
      throw ArgumentError('No withdrawal options available');
    }
    if (maxWithdrawals < 0) {
      throw ArgumentError('maxWithdrawals must be >= 0');
    }
    if (minWithdrawals < 0) {
      throw ArgumentError('minWithdrawals must be >= 0');
    }
    if (minWithdrawals > 0 &&
        maxWithdrawals > 0 &&
        minWithdrawals > maxWithdrawals) {
      throw ArgumentError(
          'minWithdrawals cannot be greater than maxWithdrawals');
    }

    final normalizedOptions = normalizeOptions(options);
    const threshold = 500000.0;

    OptimalWithdrawalResult unlimitedResult;

    if (totalAmount <= threshold) {
      unlimitedResult = _selectBest([
        _greedyOptimized(totalAmount, normalizedOptions, precision),
        _repeatedWithdrawals(totalAmount, normalizedOptions, precision),
      ]);
    } else {
      unlimitedResult =
          _greedyOptimized(totalAmount, normalizedOptions, precision);
    }

    final actualCount = unlimitedResult.totalWithdrawals;

    // Case without constraints
    if (maxWithdrawals == 0 && minWithdrawals == 0) {
      return unlimitedResult;
    }

    // Case with max constraint only
    if (maxWithdrawals > 0 && minWithdrawals == 0) {
      if (actualCount <= maxWithdrawals) {
        return unlimitedResult;
      }
      return _constrainedWithdrawals(
          totalAmount, normalizedOptions, precision, maxWithdrawals, 0);
    }

    // Case with min constraint only
    if (minWithdrawals > 0 && maxWithdrawals == 0) {
      if (actualCount >= minWithdrawals) {
        return unlimitedResult;
      }
      return _minConstrainedWithdrawals(
          totalAmount, normalizedOptions, precision, minWithdrawals);
    }

    // Case with both min and max constraints
    if (actualCount >= minWithdrawals && actualCount <= maxWithdrawals) {
      return unlimitedResult;
    }

    if (actualCount < minWithdrawals) {
      return _minConstrainedWithdrawals(
          totalAmount, normalizedOptions, precision, minWithdrawals, maxWithdrawals);
    }

    return _constrainedWithdrawals(
        totalAmount, normalizedOptions, precision, maxWithdrawals, minWithdrawals);
  }

  /// Find the best option for a given amount
  static WithdrawalOption? findBestOption(
      double amount, List<WithdrawalOption> options) {
    WithdrawalOption? best;
    double bestEfficiency = -1;

    for (final option in options) {
      if (amount >= option.min && amount <= option.max) {
        final efficiency = (amount - option.fee) / option.fee;
        if (efficiency > bestEfficiency) {
          bestEfficiency = efficiency;
          best = option;
        }
      }
    }

    return best;
  }

  /// Normalize withdrawal options
  static List<WithdrawalOption> normalizeOptions(List<Withdrawal> options) {
    final normalized = options
        .where((o) => o.min != null && o.max != null && o.fee != null && o.max! > 0)
        .map((o) => WithdrawalOption(
              min: o.min!,
              max: o.max!,
              fee: o.fee!,
            ))
        .toList();

    // Sort by descending efficiency (max/fee)
    normalized.sort((a, b) => b.efficiency.compareTo(a.efficiency));
    return normalized;
  }

  /// Optimized greedy algorithm
  static OptimalWithdrawalResult _greedyOptimized(
    double totalAmount,
    List<WithdrawalOption> options,
    double precision,
  ) {
    final counts = <String, int>{};
    double budget = totalAmount;
    double totalNet = 0;
    double totalFees = 0;

    while (budget > 0) {
      final best = _findBestWithdrawal(budget, options, precision);
      if (best == null) break;

      final key = '${best.amount}-${best.fee}';
      counts[key] = (counts[key] ?? 0) + 1;

      totalNet += best.amount;
      totalFees += best.fee;
      budget -= best.amount + best.fee;
    }

    return _buildResult(totalAmount, totalNet, totalFees, budget, counts);
  }

  /// Algorithm with repeated withdrawals
  static OptimalWithdrawalResult _repeatedWithdrawals(
    double totalAmount,
    List<WithdrawalOption> options,
    double precision,
  ) {
    OptimalWithdrawalResult bestResult =
        _greedyOptimized(totalAmount, options, precision);

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

  /// Algorithm with constraint on maximum number of withdrawals
  static OptimalWithdrawalResult _constrainedWithdrawals(
    double totalAmount,
    List<WithdrawalOption> options,
    double precision,
    int maxWithdrawals,
    int minWithdrawals,
  ) {
    final results = <OptimalWithdrawalResult>[];
    final start = max(1, minWithdrawals);
    final end = min(maxWithdrawals, 50);

    for (int numWithdrawals = start; numWithdrawals <= end; numWithdrawals++) {
      final counts = <String, int>{};
      double budget = totalAmount;
      double net = 0;
      double fees = 0;

      for (int i = 0; i < numWithdrawals; i++) {
        if (budget <= 0) break;
        final best = _findBestWithdrawal(budget, options, precision);
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

    if (results.isEmpty) {
      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }

    return results.reduce((best, curr) {
      if (curr.netAmount > best.netAmount) return curr;
      if (curr.netAmount < best.netAmount) return best;
      
      final currCount = curr.totalWithdrawals;
      final bestCount = best.totalWithdrawals;
      if (currCount < bestCount) return curr;
      if (currCount > bestCount) return best;
      
      return curr.totalFees < best.totalFees ? curr : best;
    });
  }

  /// Algorithm with constraint on minimum number of withdrawals
  static OptimalWithdrawalResult _minConstrainedWithdrawals(
    double totalAmount,
    List<WithdrawalOption> options,
    double precision,
    int minWithdrawals, [
    int maxWithdrawals = 0,
  ]) {
    final results = <OptimalWithdrawalResult>[];
    final end = maxWithdrawals > 0 ? min(maxWithdrawals, 100) : 100;

    for (int numWithdrawals = minWithdrawals;
        numWithdrawals <= end;
        numWithdrawals++) {
      final result = _distributeOptimally(
          totalAmount, options, precision, numWithdrawals);
      if (result != null) {
        results.add(result);
      }
    }

    if (results.isEmpty) {
      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }

    return results.reduce((best, curr) {
      if (curr.netAmount > best.netAmount) return curr;
      if (curr.netAmount < best.netAmount) return best;

      if (curr.totalFees < best.totalFees) return curr;
      if (curr.totalFees > best.totalFees) return best;

      final currCount = curr.totalWithdrawals;
      final bestCount = best.totalWithdrawals;
      return currCount < bestCount ? curr : best;
    });
  }

  /// Optimal distribution for a target number of withdrawals
  static OptimalWithdrawalResult? _distributeOptimally(
    double totalAmount,
    List<WithdrawalOption> options,
    double precision,
    int targetCount,
  ) {
    final counts = <String, int>{};
    double net = 0;
    double fees = 0;
    double budget = totalAmount;

    for (int i = 0; i < targetCount; i++) {
      final remaining = budget;
      final remainingWithdrawals = targetCount - i;
      final targetAmount = remaining / remainingWithdrawals;

      _BestWithdrawal? best;

      for (final opt in options) {
        final maxAmount = min(opt.max, remaining - opt.fee);
        if (maxAmount < opt.min) continue;

        double amount = min(maxAmount, max(opt.min, targetAmount - opt.fee));
        amount = (amount / precision).floor() * precision;

        if (amount < opt.min) {
          amount = opt.min;
        }
        if (amount > maxAmount) continue;

        final efficiency = amount / opt.fee;
        final proximity = 1 / (1 + (amount - targetAmount).abs());
        final score = efficiency * 10 + proximity * amount;

        if (best == null || score > best.score) {
          best = _BestWithdrawal(amount: amount, fee: opt.fee, score: score);
        }
      }

      if (best == null) {
        final fallback = _findBestWithdrawal(remaining, options, precision);
        if (fallback == null) break;
        best = _BestWithdrawal(
            amount: fallback.amount, fee: fallback.fee, score: 0);
      }

      final key = '${best.amount}-${best.fee}';
      counts[key] = (counts[key] ?? 0) + 1;
      net += best.amount;
      fees += best.fee;
      budget -= best.amount + best.fee;
    }

    final actualCount = counts.values.fold(0, (sum, count) => sum + count);

    if (actualCount < targetCount) {
      return null;
    }

    return _buildResult(totalAmount, net, fees, budget, counts);
  }

  /// Find the best withdrawal for a given budget
  static _BestWithdrawal? _findBestWithdrawal(
    double budget,
    List<WithdrawalOption> options,
    double precision,
  ) {
    _BestWithdrawal? best;

    for (final opt in options) {
      final maxAmount = min(opt.max, budget - opt.fee);
      if (maxAmount < opt.min) continue;

      final amount = (maxAmount / precision).floor() * precision;
      if (amount < opt.min) continue;

      final score = (amount * amount) / opt.fee;

      if (best == null || score > best.score) {
        best = _BestWithdrawal(amount: amount, fee: opt.fee, score: score);
      }
    }

    return best;
  }

  /// Build result from counters
  static OptimalWithdrawalResult _buildResult(
    double totalAmount,
    double netAmount,
    double totalFees,
    double remaining,
    Map<String, int> counts,
  ) {
    final withdrawals = <WithdrawalDetail>[];

    for (final entry in counts.entries) {
      final parts = entry.key.split('-');
      final amount = double.parse(parts[0]);
      final fee = double.parse(parts[1]);
      final count = entry.value;

      withdrawals.add(WithdrawalDetail(
        amount: amount,
        fee: fee,
        netAmount: amount,
        count: count,
      ));
    }

    return OptimalWithdrawalResult(
      totalAmount: totalAmount,
      netAmount: netAmount,
      totalFees: totalFees,
      remaining: remaining,
      withdrawals: withdrawals,
      efficiency: netAmount / totalAmount,
    );
  }

  /// Select the best result from multiple options
  static OptimalWithdrawalResult _selectBest(List<OptimalWithdrawalResult> results) {
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

/// Internal class to represent the best withdrawal found
class _BestWithdrawal {
  final double amount;
  final double fee;
  final double score;

  const _BestWithdrawal({
    required this.amount,
    required this.fee,
    required this.score,
  });
}