import 'dart:math';
import '../../model/fee_interval_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import '../../model/fee_minimizer_detail_model.dart';
import '../../util/constant_util.dart';
import '../../l10n/app_localizations.dart';

class FeeOptimizerUtil {
  // Cache to memorize recent results
  static final _cache = LRUCache<String, FeeOptimizerResult>(100);

  // Safety limits to avoid crashes
  static const int _maxSafeOperations = 50000;
  static const double _maxSafeAmount = 1e15; // Quadrillion

  static FeeOptimizerResult calculateOptimalOperations(
    double totalAmount,
    List<FeeInterval> intervals, {
    double precision = ConstantUtil.defaultPrecision,
    int maxOperations = 0,
    int minOperations = 0,
    AppLocalizations? localizations,
  }) {
    // Validation and normalization of inputs
    totalAmount = min(totalAmount, _maxSafeAmount);
    maxOperations = maxOperations > 0
        ? min(maxOperations, _maxSafeOperations)
        : 0;
    minOperations = minOperations > 0
        ? min(
            minOperations,
            maxOperations > 0 ? maxOperations : _maxSafeOperations,
          )
        : 0;

    // Cache key generation
    final cacheKey = _generateCacheKey(
      totalAmount,
      intervals,
      precision,
      maxOperations,
      minOperations,
    );

    // Check cache
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;

    try {
      _validateInput(
        totalAmount,
        intervals,
        maxOperations,
        minOperations,
        amountMustBePositive:
            localizations?.amountMustBePositive ??
            'Le montant doit être positif',
        amountTooHigh: localizations?.amountTooHigh ?? 'Montant trop élevé',
        noOptionsAvailable:
            localizations?.noOptionsAvailable ?? 'Aucune option disponible',
        maxOperationsMustBePositive:
            localizations?.maxOperationsMustBePositive ??
            'maxOperations doit être >= 0',
        minOperationsMustBePositive:
            localizations?.minOperationsMustBePositive ??
            'minOperations doit être >= 0',
        minOperationsCannotBeGreaterThanMaxOperations:
            localizations?.minOperationsCannotBeGreaterThanMaxOperations ??
            'minOperations ne peut pas être supérieur à maxOperations',
      );

      final options = _normalizeOptions(intervals);
      if (options.isEmpty) {
        return _buildResult(totalAmount, 0, 0, totalAmount, {});
      }

      // Adaptive strategy based on amount
      final result = _computeOptimalStrategy(
        totalAmount,
        options,
        precision,
        maxOperations,
        minOperations,
      );

      // Filter out details with null or zero values
      final filteredDetails = result.details
          .where((detail) => detail.count > 0 && detail.amount > 0)
          .toList();

      // If after filtering nothing remains, recalculate with relaxed constraints
      if (filteredDetails.isEmpty && result.netAmount == 0) {
        final relaxedResult = _computeOptimalStrategy(
          totalAmount,
          options,
          precision,
          0, // No max limit
          0, // No min limit
        );

        final relaxedFiltered = relaxedResult.details
            .where((detail) => detail.count > 0 && detail.amount > 0)
            .toList();

        if (relaxedFiltered.isNotEmpty) {
          final finalResult = FeeOptimizerResult(
            totalAmount: relaxedResult.totalAmount,
            netAmount: relaxedResult.netAmount,
            totalFees: relaxedResult.totalFees,
            remaining: relaxedResult.remaining,
            details: relaxedFiltered,
          );
          _cache.put(cacheKey, finalResult);
          return finalResult;
        }
      }

      // Create final result with filtered details
      final finalResult = filteredDetails.isEmpty
          ? result
          : FeeOptimizerResult(
              totalAmount: result.totalAmount,
              netAmount: result.netAmount,
              totalFees: result.totalFees,
              remaining: result.remaining,
              details: filteredDetails,
            );

      // Cache the result
      _cache.put(cacheKey, finalResult);

      return finalResult;
    } catch (e) {
      // In case of error, try simplified optimization
      final options = _normalizeOptions(intervals);
      if (options.isNotEmpty) {
        final simpleResult = _greedyOptimizedFast(
          totalAmount,
          options,
          precision,
        );
        final filteredDetails = simpleResult.details
            .where((detail) => detail.count > 0 && detail.amount > 0)
            .toList();

        if (filteredDetails.isNotEmpty) {
          return FeeOptimizerResult(
            totalAmount: simpleResult.totalAmount,
            netAmount: simpleResult.netAmount,
            totalFees: simpleResult.totalFees,
            remaining: simpleResult.remaining,
            details: filteredDetails,
          );
        }
      }

      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }
  }

  static FeeOptimizerResult _computeOptimalStrategy(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    // For very large amounts, use a simplified approach
    if (totalAmount > 1e12) {
      return _ultraHighAmountStrategy(
        totalAmount,
        options,
        precision,
        maxOperations,
        minOperations,
      );
    }

    // For medium to high amounts
    if (totalAmount > 1e9) {
      return _highAmountStrategy(
        totalAmount,
        options,
        precision,
        maxOperations,
        minOperations,
      );
    }

    // For small amounts, exhaustive approach
    final unlimitedResult = totalAmount <= ConstantUtil.threshold
        ? _selectBest([
            _greedyOptimizedFast(totalAmount, options, precision),
            _repeatedOperationsOptimized(totalAmount, options, precision),
          ])
        : _greedyOptimizedFast(totalAmount, options, precision);

    return _applyConstraintsOptimized(
      unlimitedResult,
      totalAmount,
      options,
      precision,
      maxOperations,
      minOperations,
    );
  }

  static FeeOptimizerResult _applyConstraintsOptimized(
    FeeOptimizerResult unlimitedResult,
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    final actualCount = unlimitedResult.totalOperations;

    // No constraints
    if (maxOperations == 0 && minOperations == 0) {
      return unlimitedResult;
    }

    // Only maxOperations
    if (maxOperations > 0 && minOperations == 0) {
      if (actualCount <= maxOperations) {
        return unlimitedResult;
      }
      return _constrainedOperationsFast(
        totalAmount,
        options,
        precision,
        maxOperations,
        0,
      );
    }

    // Only minOperations
    if (minOperations > 0 && maxOperations == 0) {
      if (actualCount >= minOperations) {
        return unlimitedResult;
      }
      return _minConstrainedOperationsFast(
        totalAmount,
        options,
        precision,
        minOperations,
        0,
      );
    }

    // Both constraints
    if (actualCount >= minOperations && actualCount <= maxOperations) {
      return unlimitedResult;
    }

    if (actualCount < minOperations) {
      return _minConstrainedOperationsFast(
        totalAmount,
        options,
        precision,
        minOperations,
        maxOperations,
      );
    }

    return _constrainedOperationsFast(
      totalAmount,
      options,
      precision,
      maxOperations,
      minOperations,
    );
  }

  static FeeOptimizerResult _minConstrainedOperationsFast(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int minOperations,
    int maxOperations,
  ) {
    final results = <FeeOptimizerResult>[];
    final end = maxOperations > 0 ? min(maxOperations, 100) : 100;

    // Test several numbers of operations starting from minimum
    for (
      int numOperations = minOperations;
      numOperations <= end;
      numOperations++
    ) {
      final result = _distributeOptimallyFast(
        totalAmount,
        options,
        precision,
        numOperations,
      );
      if (result != null) {
        results.add(result);
      }
    }

    if (results.isEmpty) {
      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }

    // Select the best result
    return results.reduce((best, curr) {
      if (curr.netAmount > best.netAmount) return curr;
      if (curr.netAmount < best.netAmount) return best;

      if (curr.totalFees < best.totalFees) return curr;
      if (curr.totalFees > best.totalFees) return best;

      final currCount = curr.totalOperations;
      final bestCount = best.totalOperations;
      return currCount < bestCount ? curr : best;
    });
  }

  static FeeOptimizerResult? _distributeOptimallyFast(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int targetCount,
  ) {
    if (targetCount > _maxSafeOperations) {
      return _distributeWithMainOption(
        totalAmount,
        options,
        precision,
        targetCount,
        _findMostEfficientOption(options)!,
      );
    }

    final counts = <String, int>{};
    double budget = totalAmount;
    double totalNet = 0;
    double totalFees = 0;

    for (int i = 0; i < targetCount; i++) {
      if (budget <= 0) break;

      final remaining = budget;
      final remainingOperations = targetCount - i;
      final targetAmount = remaining / remainingOperations;

      _BestOperation? best;

      for (final opt in options) {
        final maxAmount = min(opt.max, remaining - opt.fee);
        if (maxAmount < opt.min) continue;

        // REMOVED rounding: amount = (amount / precision).floor() * precision;
        double amount = min(maxAmount, max(opt.min, targetAmount - opt.fee));

        if (amount < opt.min) {
          amount = opt.min;
        }
        if (amount > maxAmount) continue;

        final efficiency = amount / opt.fee;
        final proximity = 1 / (1 + (amount - targetAmount).abs());
        final score = efficiency * 10 + proximity * amount;

        if (best == null || score > best.score) {
          best = _BestOperation(amount: amount, fee: opt.fee, score: score);
        }
      }

      if (best == null) {
        final fallback = _findBestOperationFast(remaining, options, precision);
        if (fallback == null) break;
        best = fallback;
      }

      final key = '${best.amount}-${best.fee}';
      counts[key] = (counts[key] ?? 0) + 1;
      totalNet += best.amount;
      totalFees += best.fee;
      budget -= best.amount + best.fee;
    }

    final actualCount = counts.values.fold(0, (sum, count) => sum + count);

    if (actualCount < targetCount) {
      return null;
    }

    return _buildResult(totalAmount, totalNet, totalFees, budget, counts);
  }

  static FeeOptimizerResult _ultraHighAmountStrategy(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    final bestOption = _findMostEfficientOption(options);
    if (bestOption == null) {
      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }

    final operationCost = bestOption.max + bestOption.fee;
    final maxPossibleOps = (totalAmount / operationCost)
        .toInt(); // CHANGED: .floor() to .toInt()

    int targetOps = maxPossibleOps;
    if (maxOperations > 0) targetOps = min(targetOps, maxOperations);
    if (minOperations > 0) targetOps = max(targetOps, minOperations);

    final netAmount = bestOption.max * targetOps;
    final totalFees = bestOption.fee * targetOps;
    final remaining = totalAmount - (operationCost * targetOps);

    return _buildResult(totalAmount, netAmount, totalFees, remaining, {
      '${bestOption.max}-${bestOption.fee}': targetOps,
    });
  }

  static FeeOptimizerResult _highAmountStrategy(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    // Utiliser une combinaison des 2-3 meilleures options
    final topOptions = _getTopOptions(options, 3);
    return _hybridOptimization(
      totalAmount,
      topOptions,
      precision,
      maxOperations,
      minOperations,
    );
  }

  static FeeOptimizerResult _greedyOptimizedFast(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
  ) {
    final counts = <String, int>{};
    double budget = totalAmount;
    double totalNet = 0;
    double totalFees = 0;
    int iterations = 0;

    while (budget > 0 && iterations < _maxSafeOperations) {
      final best = _findBestOperationFast(budget, options, precision);
      if (best == null) break;

      final operationCost = best.amount + best.fee;
      // REMOVED .floor() - Use exact value
      final repeatCount = min(
        (budget / operationCost).toInt(),
        _maxSafeOperations,
      );

      if (repeatCount > 0) {
        final key = '${best.amount}-${best.fee}';
        counts[key] = (counts[key] ?? 0) + repeatCount;
        totalNet += best.amount * repeatCount;
        totalFees += best.fee * repeatCount;
        budget -= operationCost * repeatCount;
        iterations += repeatCount;
      } else {
        final key = '${best.amount}-${best.fee}';
        counts[key] = (counts[key] ?? 0) + 1;
        totalNet += best.amount;
        totalFees += best.fee;
        budget -= operationCost;
        iterations++;
      }
    }

    return _buildResult(totalAmount, totalNet, totalFees, budget, counts);
  }

  static FeeOptimizerResult _repeatedOperationsOptimized(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
  ) {
    FeeOptimizerResult bestResult = _greedyOptimizedFast(
      totalAmount,
      options,
      precision,
    );

    final optionsToTest = totalAmount > 1e9
        ? options.take(3).toList()
        : options;

    for (final opt in optionsToTest) {
      final samples = _getAdaptiveSamples(opt, totalAmount, precision);

      for (final amount in samples) {
        if (amount < opt.min) continue;

        final cost = amount + opt.fee;
        final count = min(
          (totalAmount / cost).toInt(),
          _maxSafeOperations,
        ); // CHANGED: .floor() to .toInt()
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

  static List<double> _getAdaptiveSamples(
    _FeeOption opt,
    double totalAmount,
    double precision,
  ) {
    final samples = <double>[];

    samples.add(opt.max);

    final numSamples = totalAmount > 1e9 ? 5 : (totalAmount > 1e6 ? 10 : 15);
    final step = max(precision, (opt.max - opt.min) / numSamples);

    for (int i = 1; i < numSamples; i++) {
      final amt = opt.max - (step * i);
      if (amt >= opt.min) {
        // REMOVED rounding: (amt / precision).floor() * precision
        samples.add(amt);
      }
    }

    return samples;
  }

  static FeeOptimizerResult _constrainedOperationsFast(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    // For large numbers of operations, use batch approach
    if (maxOperations > 100) {
      return _batchConstrainedOperations(
        totalAmount,
        options,
        precision,
        maxOperations,
        minOperations,
      );
    }

    final results = <FeeOptimizerResult>[];
    final start = max(1, minOperations);
    final end = min(maxOperations, 50);

    // Intelligent sampling of operation counts
    final samples = _getOperationSamples(start, end);

    for (final numOperations in samples) {
      final result = _distributeOptimallyFast(
        totalAmount,
        options,
        precision,
        numOperations,
      );
      if (result != null) results.add(result);
    }

    return results.isEmpty
        ? _buildResult(totalAmount, 0, 0, totalAmount, {})
        : _selectBest(results);
  }

  static List<int> _getOperationSamples(int start, int end) {
    if (end - start <= 20) {
      return List.generate(end - start + 1, (i) => start + i);
    }

    // Échantillonnage logarithmique pour les grandes plages
    final samples = <int>{start, end};
    final step = max(1, (end - start) ~/ 20);

    for (int i = start + step; i < end; i += step) {
      samples.add(i);
    }

    return samples.toList()..sort();
  }

  static FeeOptimizerResult _batchConstrainedOperations(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    final bestOption = _findMostEfficientOption(options);
    if (bestOption == null) {
      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }

    final targetOps = min(
      maxOperations,
      (totalAmount / (bestOption.max + bestOption.fee)).toInt(),
    ); // CHANGED
    final actualOps = max(minOperations, targetOps);

    return _distributeWithMainOption(
      totalAmount,
      options,
      precision,
      actualOps,
      bestOption,
    );
  }

  static FeeOptimizerResult _distributeWithMainOption(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int targetCount,
    _FeeOption mainOption,
  ) {
    final counts = <String, int>{};
    double budget = totalAmount;

    final mainCost = mainOption.max + mainOption.fee;
    final mainCount = min(targetCount, (budget / mainCost).toInt()); // CHANGED

    if (mainCount > 0) {
      counts['${mainOption.max}-${mainOption.fee}'] = mainCount;
      budget -= mainCost * mainCount;
    }

    int remaining = targetCount - mainCount;
    for (final opt in options) {
      if (remaining <= 0 || budget <= 0) break;

      final cost = opt.max + opt.fee;
      if (cost > budget) continue;

      final count = min(remaining, (budget / cost).toInt()); // CHANGED
      if (count > 0) {
        counts['${opt.max}-${opt.fee}'] = count;
        budget -= cost * count;
        remaining -= count;
      }
    }

    return _buildResultFromCounts(totalAmount, counts);
  }

  static FeeOptimizerResult _hybridOptimization(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    final counts = <String, int>{};
    double budget = totalAmount;
    int totalOps = 0;

    for (final opt in options) {
      if (budget <= 0) break;
      if (maxOperations > 0 && totalOps >= maxOperations) break;

      final cost = opt.max + opt.fee;
      final maxCount = maxOperations > 0
          ? min((budget / cost).toInt(), maxOperations - totalOps) // CHANGED
          : (budget / cost).toInt(); // CHANGED

      if (maxCount > 0) {
        final count = min(maxCount, _maxSafeOperations - totalOps);
        counts['${opt.max}-${opt.fee}'] = count;
        budget -= cost * count;
        totalOps += count;
      }
    }

    while (totalOps < minOperations && budget > 0) {
      final best = _findBestOperationFast(budget, options, precision);
      if (best == null) break;

      final key = '${best.amount}-${best.fee}';
      counts[key] = (counts[key] ?? 0) + 1;
      budget -= best.amount + best.fee;
      totalOps++;
    }

    return _buildResultFromCounts(totalAmount, counts);
  }

  static _FeeOption? _findMostEfficientOption(List<_FeeOption> options) {
    if (options.isEmpty) return null;

    _FeeOption? best;
    double bestEfficiency = 0;

    for (final opt in options) {
      final efficiency = opt.max / opt.fee;
      if (efficiency > bestEfficiency) {
        bestEfficiency = efficiency;
        best = opt;
      }
    }

    return best;
  }

  static List<_FeeOption> _getTopOptions(List<_FeeOption> options, int count) {
    final sorted = List<_FeeOption>.from(options)
      ..sort((a, b) => (b.max / b.fee).compareTo(a.max / a.fee));
    return sorted.take(count).toList();
  }

  static _BestOperation? _findBestOperationFast(
    double budget,
    List<_FeeOption> options,
    double precision,
  ) {
    _BestOperation? best;

    for (final opt in options) {
      final maxAmount = min(opt.max, budget - opt.fee);
      if (maxAmount < opt.min) continue;

      // REMOVED rounding: (maxAmount / precision).floor() * precision
      final amount = maxAmount;
      if (amount < opt.min) continue;

      final score = amount / opt.fee;

      if (best == null || score > best.score) {
        best = _BestOperation(amount: amount, fee: opt.fee, score: score);
      }
    }

    return best;
  }

  static FeeOptimizerResult _buildResultFromCounts(
    double totalAmount,
    Map<String, int> counts,
  ) {
    double netAmount = 0;
    double totalFees = 0;

    for (final entry in counts.entries) {
      final parts = entry.key.split('-');
      final amount = double.parse(parts[0]);
      final fee = double.parse(parts[1]);
      netAmount += amount * entry.value;
      totalFees += fee * entry.value;
    }

    final remaining = totalAmount - netAmount - totalFees;
    return _buildResult(totalAmount, netAmount, totalFees, remaining, counts);
  }

  static String _generateCacheKey(
    double totalAmount,
    List<FeeInterval> intervals,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    final intervalsHash = intervals
        .map((i) => '${i.minAmount}-${i.maxAmount}-${i.fee}')
        .join('|');
    return '$totalAmount-$intervalsHash-$precision-$maxOperations-$minOperations';
  }

  static List<_FeeOption> _normalizeOptions(List<FeeInterval> intervals) {
    final validIntervals = intervals
        .where((interval) => interval.isValid)
        .toList();
    if (validIntervals.isEmpty) return [];

    final options = validIntervals.map((interval) {
      final approximatedFee = interval.feeType == FeeType.percentage
          ? interval.maxAmount! * (interval.fee! / 100.0)
          : interval.fee!;
      return _FeeOption(
        min: interval.minAmount!,
        max: interval.maxAmount!,
        fee: approximatedFee,
        feeValue: interval.fee!,
        feeType: interval.feeType,
      );
    }).toList();

    options.sort((a, b) => (b.max / b.fee).compareTo(a.max / a.fee));
    return options;
  }

  static void _validateInput(
    double totalAmount,
    List<FeeInterval> intervals,
    int maxOperations,
    int minOperations, {
    String amountMustBePositive = 'Le montant doit être positif',
    String amountTooHigh = 'Montant trop élevé',
    String noOptionsAvailable = 'Aucune option disponible',
    String maxOperationsMustBePositive = 'maxOperations doit être >= 0',
    String minOperationsMustBePositive = 'minOperations doit être >= 0',
    String minOperationsCannotBeGreaterThanMaxOperations =
        'minOperations ne peut pas être supérieur à maxOperations',
  }) {
    if (totalAmount <= 0) throw ArgumentError(amountMustBePositive);
    if (totalAmount > _maxSafeAmount) throw ArgumentError(amountTooHigh);
    if (intervals.isEmpty) throw ArgumentError(noOptionsAvailable);
    if (maxOperations < 0) throw ArgumentError(maxOperationsMustBePositive);
    if (minOperations < 0) throw ArgumentError(minOperationsMustBePositive);
    if (minOperations > 0 &&
        maxOperations > 0 &&
        minOperations > maxOperations) {
      throw ArgumentError(minOperationsCannotBeGreaterThanMaxOperations);
    }
  }

  static FeeOptimizerResult _buildResult(
    double totalAmount,
    double netAmount,
    double totalFees,
    double remaining,
    Map<String, int> counts,
  ) {
    // Filter entries with count = 0 or amount = 0
    final filteredCounts = Map<String, int>.from(counts)
      ..removeWhere((key, value) {
        if (value <= 0) return true;
        final parts = key.split('-');
        final amount = double.parse(parts[0]);
        return amount <= 0;
      });

    final details = filteredCounts.entries.map((entry) {
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
    if (results.isEmpty) return _buildResult(0, 0, 0, 0, {});

    return results.reduce((best, curr) {
      // Prioriser le montant net, puis les frais minimaux, puis le reste minimal
      if (curr.netAmount > best.netAmount) return curr;
      if (curr.netAmount == best.netAmount) {
        if (curr.totalFees < best.totalFees) return curr;
        if (curr.totalFees == best.totalFees &&
            curr.remaining < best.remaining) {
          return curr;
        }
      }
      return best;
    });
  }

  static FeeInterval? findBestOption(
    double amount,
    List<FeeInterval> intervals,
  ) {
    final validIntervals = intervals
        .where((interval) => interval.isValid)
        .toList();

    FeeInterval? best;
    double bestEfficiency = -1;

    for (final interval in validIntervals) {
      if (amount >= interval.minAmount! && amount <= interval.maxAmount!) {
        final fee = interval.feeType == FeeType.percentage
            ? amount * (interval.fee! / 100.0)
            : interval.fee!;
        final efficiency = (amount - fee) / fee;
        if (efficiency > bestEfficiency) {
          bestEfficiency = efficiency;
          best = interval;
        }
      }
    }

    return best;
  }
}

// Cache LRU simple et efficace
class LRUCache<K, V> {
  final int capacity;
  final _cache = <K, V>{};

  LRUCache(this.capacity);

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;
    if (_cache.length > capacity) {
      _cache.remove(_cache.keys.first);
    }
  }

  void clear() => _cache.clear();
}

// Optimized internal classes
class _FeeOption {
  _FeeOption({
    required this.min,
    required this.max,
    required this.fee,
    required this.feeValue,
    required this.feeType,
  });
  final double min;
  final double max;
  final double fee; // Approximated fee for sorting
  final double feeValue;
  final FeeType feeType;

  double getFeeForAmount(double amount) {
    if (feeType == FeeType.percentage) {
      return amount * (feeValue / 100.0);
    } else {
      return feeValue;
    }
  }
}

class _BestOperation {
  _BestOperation({
    required this.amount,
    required this.fee,
    required this.score,
  });
  final double amount;
  final double fee;
  final double score;
}
