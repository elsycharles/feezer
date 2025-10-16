import 'dart:math';
import 'package:decimal/decimal.dart';
import '../../model/fee_interval_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import '../../model/fee_minimizer_detail_model.dart';
import '../../util/constant_util.dart';
import '../../util/decimal_util.dart';
import '../../util/cache_util.dart';
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

      // ✅ CRITICAL VALIDATION: Check that fees are not zero
      if (result.details.isNotEmpty) {
        bool hasInvalidFees = false;
        for (final detail in result.details) {
          // If the amount exists but fees are 0 AND it's not normal
          if (detail.amount > 0 && detail.fee == 0) {
            // Recalculate the fee to verify
            final option = options.firstWhere(
              (opt) => detail.amount >= opt.min && detail.amount <= opt.max,
              orElse: () => options.first,
            );
            final expectedFee = option.getFeeForAmount(detail.amount);
            if (expectedFee > 0) {
              hasInvalidFees = true;
              break;
            }
          }
        }

        // If invalid fees are detected, recalculate
        if (hasInvalidFees) {
          // print('⚠️ Invalid fees detected, recalculating...'); // Debug only
          // Force a simple recalculation
          final correctedResult = _greedyOptimizedFast(totalAmount, options, precision);
          _cache.put(cacheKey, correctedResult);
          return correctedResult;
        }
      }

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
            _findBestSingleOperation(totalAmount, options), // New method
          ])
        : _selectBest([
            _greedyOptimizedFast(totalAmount, options, precision),
            _findBestSingleOperation(totalAmount, options), // New method
          ]);

    return _applyConstraintsOptimized(
      unlimitedResult,
      totalAmount,
      options,
      precision,
      maxOperations,
      minOperations,
    );
  }

  static FeeOptimizerResult _findBestSingleOperation(
    double totalAmount,
    List<_FeeOption> options,
  ) {
    FeeOptimizerResult? bestResult;

    for (final opt in options) {
      double netAmount;
      double fee;

      if (opt.feeType == FeeType.percentage) {
        netAmount = totalAmount / (1 + opt.feeValue / 100);
        fee = netAmount * (opt.feeValue / 100);
      } else {
        netAmount = totalAmount - opt.feeValue;
        fee = opt.feeValue;
      }

      // ✅ FIX: Use dynamic tolerance instead of hardcoded 0.01
      final totalAmountDecimal = DecimalUtil.toDecimal(totalAmount);
      final netAmountDecimal = DecimalUtil.toDecimal(netAmount);
      final feeDecimal = DecimalUtil.toDecimal(fee);
      final totalCostDecimal = netAmountDecimal + feeDecimal;
      final tolerance = ConstantUtil.calculateTolerance(totalAmountDecimal);

      if (netAmount >= opt.min && netAmount <= opt.max &&
          netAmount > 0 && DecimalUtil.isLessOrEqual(totalCostDecimal, totalAmountDecimal, tolerance: tolerance)) {
        final result = _buildResult(
          totalAmount,
          netAmount,
          fee,
          totalAmount - netAmount - fee,
          {'$netAmount-$fee': 1},
        );

        if (bestResult == null ||
            result.netAmount > bestResult.netAmount ||
            (result.netAmount == bestResult.netAmount &&
             result.totalFees < bestResult.totalFees)) {
          bestResult = result;
        }
      }
    }

    return bestResult ?? _buildResult(totalAmount, 0, 0, totalAmount, {});
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

    // ✅ Try first an optimal solution with a single option
    for (final opt in options) {
      final result = _trySingleOptionDistribution(
        totalAmount,
        opt,
        precision,
        targetCount,
      );
      if (result != null && result.totalOperations == targetCount) {
        return result;
      }
    }

    // ✅ If not possible, use mixed distribution
    return _mixedDistribution(totalAmount, options, precision, targetCount);
  }

  // Distribution with a single option
  static FeeOptimizerResult? _trySingleOptionDistribution(
    double totalAmount,
    _FeeOption opt,
    double precision,
    int targetCount,
  ) {
    final totalDecimal = DecimalUtil.toDecimal(totalAmount);
    final countDecimal = Decimal.fromInt(targetCount);

    // Calculate with unlimited precision
    final Decimal amountPerOpDecimal;

    if (opt.feeType == FeeType.percentage) {
      final hundred = Decimal.fromInt(100);
      final one = Decimal.fromInt(1);
      final denominator = countDecimal * (one + (opt._feeValueDecimal / hundred).toDecimal(scaleOnInfinitePrecision: 10));
      amountPerOpDecimal = (totalDecimal / denominator).toDecimal(scaleOnInfinitePrecision: 10);
    } else {
      final totalFees = opt._feeValueDecimal * countDecimal;
      amountPerOpDecimal = ((totalDecimal - totalFees) / countDecimal).toDecimal(scaleOnInfinitePrecision: 10);
    }

    // Check constraints
    if (amountPerOpDecimal < opt._minDecimal ||
        amountPerOpDecimal > opt._maxDecimal) {
      return null;
    }

    final feeDecimal = opt.getFeeForAmountDecimal(amountPerOpDecimal);
    final totalCostRational = (amountPerOpDecimal + feeDecimal) * countDecimal;
    final totalCostDecimal = totalCostRational;

    // ✅ FIXED: Use dynamic tolerance instead of hardcoded 0.01
    final tolerance = ConstantUtil.calculateTolerance(totalDecimal);
    if (ConstantUtil.isDecimalGreater(totalCostDecimal, totalDecimal, tolerance: tolerance)) {
      return null;
    }

    // Convert to double for result
    final amountPerOp = DecimalUtil.toDouble(amountPerOpDecimal);
    final fee = DecimalUtil.toDouble(feeDecimal);
    final totalNet = amountPerOp * targetCount;
    final totalFees = fee * targetCount;
    final totalCost = DecimalUtil.toDouble(totalCostDecimal);

    return _buildResult(
      totalNet + totalFees,
      totalNet,
      totalFees,
      totalAmount - totalCost,
      {'$amountPerOp-$fee': targetCount},
    );
  }

  // ✅ New function: Optimized mixed distribution
  static FeeOptimizerResult? _mixedDistribution(
    double totalAmount,
    List<_FeeOption> options,
    double precision, // Gardé pour signature mais non utilisé
    int targetCount,
  ) {
    final counts = <String, int>{};
    double budget = totalAmount;
    double totalNet = 0;
    double totalFees = 0;

    for (int i = 0; i < targetCount; i++) {
      final budgetDecimal = DecimalUtil.toDecimal(budget);
      final tolerance = ConstantUtil.calculateTolerance(budgetDecimal);

      // Stop if remaining budget is negligible
      if (budgetDecimal <= tolerance) break;

      final remaining = budget;
      final remainingOperations = targetCount - i;
      final targetAmount = remaining / remainingOperations;

      _BestOperation? best;
      double bestScore = -1;

      for (final opt in options) {
        double amount;

        if (opt.feeType == FeeType.percentage) {
          amount = targetAmount / (1 + opt.feeValue / 100);
        } else {
          amount = targetAmount - opt.feeValue;
        }

        // ✅ NO ROUNDING - just constrain to limits
        amount = max(opt.min, min(opt.max, amount));

        final fee = opt.getFeeForAmount(amount);
        final totalCost = amount + fee;

        // ✅ FIXED: Use dynamic tolerance for comparison
        final costDecimal = DecimalUtil.toDecimal(totalCost);
        final remainingDecimal = DecimalUtil.toDecimal(remaining);
        final costTolerance = ConstantUtil.calculateTolerance(remainingDecimal);

        if (ConstantUtil.isDecimalGreater(costDecimal, remainingDecimal, tolerance: costTolerance) ||
            amount < opt.min) {
          continue;
        }

        final efficiency = amount / (fee + 0.0001);
        final utilization = amount / opt.max;
        final costFit = (targetAmount - totalCost).abs();

        final score = efficiency * 10 + utilization * 5 - costFit * 0.1;

        if (score > bestScore) {
          bestScore = score;
          best = _BestOperation(amount: amount, fee: fee, score: score);
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
    if (actualCount < targetCount) return null;

    return _buildResult(totalNet + totalFees, totalNet, totalFees, budget, counts);
  }

  static FeeOptimizerResult _ultraHighAmountStrategy(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    // ✅ Use greedy approach instead of simplified single-option strategy
    final greedyResult = _greedyOptimizedFast(totalAmount, options, precision);

    // Apply constraints if needed
    return _applyConstraintsOptimized(
      greedyResult,
      totalAmount,
      options,
      precision,
      maxOperations,
      minOperations,
    );
  }

  static FeeOptimizerResult _highAmountStrategy(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    // ✅ Try multiple strategies and select best
    final results = <FeeOptimizerResult>[
      _greedyOptimizedFast(totalAmount, options, precision),
      _repeatedOperationsOptimized(totalAmount, options, precision),
    ];

    final bestResult = _selectBest(results);

    return _applyConstraintsOptimized(
      bestResult,
      totalAmount,
      options,
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
    _BestOperation? bestSingleOp;

    for (final opt in options) {
      final minAmount = opt.min;
      final maxAmount = opt.max;

      double netAmount;
      double fee;

      if (opt.feeType == FeeType.percentage) {
        netAmount = totalAmount / (1 + opt.feeValue / 100);
        fee = netAmount * (opt.feeValue / 100);
      } else {
        netAmount = totalAmount - opt.feeValue;
        fee = opt.feeValue;
      }

      // ✅ FIX: Use dynamic tolerance instead of hardcoded 0.01
      final totalAmountDecimal = DecimalUtil.toDecimal(totalAmount);
      final netAmountDecimal = DecimalUtil.toDecimal(netAmount);
      final feeDecimal = DecimalUtil.toDecimal(fee);
      final totalCostDecimal = netAmountDecimal + feeDecimal;
      final tolerance = ConstantUtil.calculateTolerance(totalAmountDecimal);

      if (netAmount >= minAmount && netAmount <= maxAmount &&
          netAmount > 0 && DecimalUtil.isLessOrEqual(totalCostDecimal, totalAmountDecimal, tolerance: tolerance)) {
        final efficiency = netAmount / (fee + 0.0001);

        if (bestSingleOp == null || efficiency > bestSingleOp.score) {
          bestSingleOp = _BestOperation(
            amount: netAmount,
            fee: fee,
            score: efficiency,
          );
        }
      }
    }

    if (bestSingleOp != null) {
      final singleOpResult = _buildResult(
        bestSingleOp.amount + bestSingleOp.fee,
        bestSingleOp.amount,
        bestSingleOp.fee,
        totalAmount - bestSingleOp.amount - bestSingleOp.fee,
        {'${bestSingleOp.amount}-${bestSingleOp.fee}': 1},
      );

      final multiOpResult = _greedyMultiOperations(totalAmount, options, precision);

      if (singleOpResult.netAmount > multiOpResult.netAmount ||
          (singleOpResult.netAmount == multiOpResult.netAmount &&
           singleOpResult.totalFees < multiOpResult.totalFees)) {
        return singleOpResult;
      }
      return multiOpResult;
    }

    return _greedyMultiOperations(totalAmount, options, precision);
  }

  static FeeOptimizerResult _greedyMultiOperations(
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

    return _buildResult(totalNet + totalFees, totalNet, totalFees, budget, counts);
  }

  static FeeOptimizerResult _repeatedOperationsOptimized(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
  ) {
    FeeOptimizerResult bestResult = _buildResult(totalAmount, 0, 0, totalAmount, {});

    // ✅ Test with a single operation (without rounding)
    for (final opt in options) {
      double netAmount;
      double fee;

      if (opt.feeType == FeeType.percentage) {
        netAmount = totalAmount / (1 + opt.feeValue / 100);
        fee = netAmount * (opt.feeValue / 100);
      } else {
        netAmount = totalAmount - opt.feeValue;
        fee = opt.feeValue;
      }

      if (netAmount >= opt.min && netAmount <= opt.max && netAmount > 0) {
        final singleOpResult = _buildResult(
          netAmount + fee,
          netAmount,
          fee,
          totalAmount - netAmount - fee,
          {'$netAmount-$fee': 1},
        );

        if (singleOpResult.netAmount > bestResult.netAmount ||
            (singleOpResult.netAmount == bestResult.netAmount &&
             singleOpResult.totalFees < bestResult.totalFees)) {
          bestResult = singleOpResult;
        }
      }
    }

    final multiOpResult = _greedyMultiOperations(totalAmount, options, precision);
    if (multiOpResult.netAmount > bestResult.netAmount ||
        (multiOpResult.netAmount == bestResult.netAmount &&
         multiOpResult.totalFees < bestResult.totalFees)) {
      bestResult = multiOpResult;
    }

    final optionsToTest = totalAmount > 1e9
        ? options.take(3).toList()
        : options;

    for (final opt in optionsToTest) {
      final samples = _getAdaptiveSamples(opt, totalAmount, precision);

      for (final amount in samples) {
        if (amount < opt.min) continue;

        final fee = opt.getFeeForAmount(amount);
        final cost = amount + fee;
        final count = min(
          (totalAmount / cost).floor(),
          _maxSafeOperations,
        );
        if (count == 0) continue;

        final net = amount * count;
        final fees = fee * count;
        final remaining = totalAmount - cost * count;

        if (net > bestResult.netAmount ||
            (net == bestResult.netAmount && fees < bestResult.totalFees)) {
          final counts = <String, int>{'$amount-$fee': count};
          bestResult = _buildResult(net + fees, net, fees, remaining, counts);
        }
      }
    }

    return bestResult;
  }

  static List<double> _getAdaptiveSamples(
    _FeeOption opt,
    double totalAmount,
    double precision, // Gardé pour signature mais non utilisé
  ) {
    final samples = <double>[];

    samples.add(opt.max);

    final numSamples = totalAmount > 1e9 ? 5 : (totalAmount > 1e6 ? 10 : 15);
    final step = max(precision, (opt.max - opt.min) / numSamples);

    for (int i = 1; i < numSamples; i++) {
      final amt = opt.max - (step * i);
      if (amt >= opt.min) {
        // ✅ NO ROUNDING - exact value
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

    // Logarithmic sampling for large ranges
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

    // ✅ Use real fee
    final realFee = bestOption.getFeeForAmount(bestOption.max);
    final targetOps = min(
      maxOperations,
      (totalAmount / (bestOption.max + realFee)).floor(),
    );
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

    // ✅ Use real fee
    final mainFee = mainOption.getFeeForAmount(mainOption.max);
    final mainCost = mainOption.max + mainFee;
    final mainCount = min(targetCount, (budget / mainCost).floor());

    if (mainCount > 0) {
      counts['${mainOption.max}-$mainFee'] = mainCount;
      budget -= mainCost * mainCount;
    }

    int remaining = targetCount - mainCount;
    for (final opt in options) {
      if (remaining <= 0 || budget <= 0) break;

      // ✅ Calculate real fee for each option
      final optFee = opt.getFeeForAmount(opt.max);
      final cost = opt.max + optFee;
      if (cost > budget) continue;

      final count = min(remaining, (budget / cost).floor());
      if (count > 0) {
        counts['${opt.max}-$optFee'] = count;
        budget -= cost * count;
        remaining -= count;
      }
    }

    return _buildResultFromCounts(totalAmount, counts);
  }

  static _FeeOption? _findMostEfficientOption(List<_FeeOption> options) {
    if (options.isEmpty) return null;

    _FeeOption? best;
    double bestEfficiency = 0;

    for (final opt in options) {
      // ✅ Calculate efficiency at maximum amount
      final fee = opt.getFeeForAmount(opt.max);
      final efficiency = opt.max / (fee + 0.0001);
      
      if (efficiency > bestEfficiency) {
        bestEfficiency = efficiency;
        best = opt;
      }
    }

    return best;
  }

  static _BestOperation? _findBestOperationFast(
    double budget,
    List<_FeeOption> options,
    double precision,
  ) {
    _BestOperation? best;
    double bestScore = -1;

    final budgetDecimal = DecimalUtil.toDecimal(budget);

    for (final opt in options) {
      // Calculate with unlimited precision
      final netAmountDecimal = DecimalUtil.calculateNetAmount(
        budget: budgetDecimal,
        feeValue: opt._feeValueDecimal,
        isPercentage: opt.feeType == FeeType.percentage,
      );

      // Limit to maximum amount
      Decimal amountDecimal = netAmountDecimal;
      if (amountDecimal > opt._maxDecimal) {
        amountDecimal = opt._maxDecimal;
      }
      if (amountDecimal < opt._minDecimal) continue;

      final feeDecimal = opt.getFeeForAmountDecimal(amountDecimal);
      final totalCostDecimal = DecimalUtil.calculateTotalCost(
        amount: amountDecimal,
        fee: feeDecimal,
      );

      // ✅ FIXED: Use dynamic tolerance
      final tolerance = ConstantUtil.calculateTolerance(budgetDecimal);
      if (ConstantUtil.isDecimalGreater(totalCostDecimal, budgetDecimal, tolerance: tolerance)) {
        continue;
      }

      // Calculate score
      final minFee = DecimalUtil.toDecimal(1e-15);
      final safeFee = feeDecimal > minFee ? feeDecimal : minFee;
      final scoreRational = amountDecimal / safeFee;
      final score = scoreRational.toDouble();

      if (score > bestScore) {
        bestScore = score;
        best = _BestOperation(
          amount: DecimalUtil.toDouble(amountDecimal),
          fee: DecimalUtil.toDouble(feeDecimal),
          score: score,
        );
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
    return _buildResult(netAmount + totalFees, netAmount, totalFees, remaining, counts);
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
      // ✅ No longer approximate, store type directly
      return _FeeOption(
        min: interval.minAmount!,
        max: interval.maxAmount!,
        fee: interval.fee!, // Raw value (% or fixed)
        feeValue: interval.fee!,
        feeType: interval.feeType,
      );
    }).toList();

    // ✅ Dynamic sorting based on real efficiency at max
    options.sort((a, b) {
      final effA = _calculateEfficiency(a.max, a);
      final effB = _calculateEfficiency(b.max, b);
      return effB.compareTo(effA);
    });
    
    return options;
  }

  // ✅ Helper function to calculate real efficiency
  static double _calculateEfficiency(double amount, _FeeOption opt) {
    final fee = opt.getFeeForAmount(amount);
    return amount / (fee + 0.0001); // Avoid division by zero
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

  // ========================================
  // 5. Improve _buildResult to handle extremely small values
  // ========================================

  static FeeOptimizerResult _buildResult(
    double totalAmount,
    double netAmount,
    double totalFees,
    double remaining,
    Map<String, int> counts,
  ) {
    // Convert to Decimal for precise calculations
    final totalDecimal = Decimal.parse(totalAmount.toString());
    final netDecimal = Decimal.parse(netAmount.toString());
    final feesDecimal = Decimal.parse(totalFees.toString());
    
    // Calculate the remaining with precision
    final remainingDecimal = totalDecimal - netDecimal - feesDecimal;
    
    // If very close to zero or negative, set to zero
    final zero = Decimal.zero;
    final tolerance = Decimal.parse('1e-10');
    
    double finalRemaining;
    if (remainingDecimal.abs() < tolerance || remainingDecimal < zero) {
      finalRemaining = 0.0;
    } else {
      finalRemaining = remainingDecimal.toDouble();
    }

    // Filter entries with count = 0 or truly zero amount
    final filteredCounts = Map<String, int>.from(counts)
      ..removeWhere((key, value) {
        if (value <= 0) return true;

        final parts = key.split('-');
        final amountDecimal = Decimal.parse(parts[0]);

        // Only filter if amount is truly zero (not just very small)
        return amountDecimal == zero;
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
      remaining: finalRemaining,
      details: details,
    );
  }

  static FeeOptimizerResult _selectBest(List<FeeOptimizerResult> results) {
    if (results.isEmpty) return _buildResult(0, 0, 0, 0, {});

    return results.reduce((best, curr) {
      // Prioritize net amount, then minimum fees, then minimum remainder
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

  // Calculate maximum net amount by greedily splitting across intervals
  static Map<String, dynamic> _calculateMaxNetBySplitting(
    double totalAmount,
    List<FeeInterval> intervals,
  ) {
    if (totalAmount <= 0 || intervals.isEmpty) {
      return {'netAmount': 0.0, 'totalFees': 0.0, 'operations': 0, 'details': <FeeOptimizerDetail>[]};
    }

    // Sort intervals by max amount descending (largest intervals first)
    final sortedIntervals = intervals
        .where((interval) => (interval.minAmount ?? 0) >= 0)
        .toList()
      ..sort((a, b) => (b.maxAmount ?? double.infinity).compareTo(a.maxAmount ?? double.infinity));

    double remainingBudget = totalAmount;
    double totalNetAmount = 0;
    double totalFees = 0;
    int operations = 0;
    final List<FeeOptimizerDetail> details = [];

    for (final interval in sortedIntervals) {
      final minAmount = interval.minAmount ?? 0;
      final maxAmount = interval.maxAmount ?? double.infinity;
      final feeValue = interval.fee ?? 0;

      // Keep taking from this interval until we can't anymore
      while (remainingBudget >= minAmount && remainingBudget > 0) {
        // Calculate how much we can take in this interval
        double takeAmount = remainingBudget;

        // For percentage fees, we need to solve for net amount
        if (interval.feeType == FeeType.percentage) {
          // budget = net + net * (fee/100) = net * (1 + fee/100)
          // net = budget / (1 + fee/100)
          final netFromBudget = remainingBudget / (1 + feeValue / 100.0);
          takeAmount = min(netFromBudget, maxAmount);
        } else {
          // For fixed fees, net = budget - fee, but ensure we can afford the fee
          if (remainingBudget > feeValue) {
            takeAmount = min(remainingBudget - feeValue, maxAmount);
          } else {
            break; // Can't afford the fee, move to next interval
          }
        }

        // Ensure we meet minimum
        if (takeAmount < minAmount) break;

        // Calculate actual fee and cost
        final actualFee = interval.feeType == FeeType.percentage
            ? takeAmount * (feeValue / 100.0)
            : feeValue;
        final totalCost = takeAmount + actualFee;

        // Check if we can afford this
        if (totalCost > remainingBudget + 0.01) break;

        // Take this amount
        totalNetAmount += takeAmount;
        totalFees += actualFee;
        remainingBudget -= totalCost;
        operations++;

        // Add detail for this operation
        details.add(FeeOptimizerDetail(
          amount: takeAmount,
          fee: actualFee,
          count: 1,
        ));
      }
    }

    return {
      'netAmount': totalNetAmount,
      'totalFees': totalFees,
      'operations': operations,
      'details': details,
    };
  }

  // Calculate minimum cost to achieve a target net amount by splitting across intervals
  // Same logic as max amount but with fixed net target instead of fixed budget
  static Map<String, dynamic> _calculateMinCostForNetAmount(
    double targetNetAmount,
    List<FeeInterval> intervals,
  ) {
    if (targetNetAmount <= 0 || intervals.isEmpty) {
      return {'totalFees': 0.0, 'operations': 0, 'details': <FeeOptimizerDetail>[]};
    }

    // Sort intervals by max amount descending (largest intervals first) - SAME AS MAX AMOUNT
    final sortedIntervals = intervals
        .where((interval) => (interval.minAmount ?? 0) >= 0)
        .toList()
      ..sort((a, b) => (b.maxAmount ?? double.infinity).compareTo(a.maxAmount ?? double.infinity));

    double remainingNet = targetNetAmount;
    double totalFees = 0;
    int operations = 0;
    final List<FeeOptimizerDetail> details = [];

    for (final interval in sortedIntervals) {
      final minAmount = interval.minAmount ?? 0;
      final maxAmount = interval.maxAmount ?? double.infinity;
      final feeValue = interval.fee ?? 0;

      // Keep taking from this interval until remaining net is too small
      while (remainingNet >= minAmount && remainingNet > 0) {
        // Calculate how much net we can take in this interval
        double takeNetAmount = min(remainingNet, maxAmount);

        // Ensure we meet minimum
        if (takeNetAmount < minAmount) break;

        // Calculate fee for this amount
        final actualFee = interval.feeType == FeeType.percentage
            ? takeNetAmount * (feeValue / 100.0)
            : feeValue;

        // Take this amount
        totalFees += actualFee;
        remainingNet -= takeNetAmount;
        operations++;

        // Add detail for this operation
        details.add(FeeOptimizerDetail(
          amount: takeNetAmount,
          fee: actualFee,
          count: 1,
        ));
      }
    }

    // If we couldn't achieve the target net amount, return invalid result
    if (remainingNet > 0.01) {
      return {'totalFees': 0.0, 'operations': 0, 'details': <FeeOptimizerDetail>[]};
    }

    return {
      'totalFees': totalFees,
      'operations': operations,
      'details': details,
    };
  }

  static Map<String, dynamic>? calculateNonOptimizedComparison(
    double amountInAriary,
    List<FeeInterval> intervals,
    FeeOptimizerResult optimizedResult,
  ) {
    // Calculate maximum net amount by splitting across intervals (greedy approach)
    final splitResult = _calculateMaxNetBySplitting(amountInAriary, intervals);
    final maxNetAmount = splitResult['netAmount'] as double;
    final maxFee = splitResult['totalFees'] as double;
    final maxOperations = splitResult['operations'] as int;
    final maxDetails = splitResult['details'] as List<FeeOptimizerDetail>;
    final foundValidMaxInterval = maxNetAmount > 0;

    // Calculate if we take the same net amount as optimization by splitting
    final optimizedNetAmount = optimizedResult.netAmount;
    final sameNetResult = _calculateMinCostForNetAmount(optimizedNetAmount, intervals);
    final sameNetFee = sameNetResult['totalFees'] as double;
    final sameNetTotalAmount = optimizedNetAmount + sameNetFee;
    final sameNetOperations = sameNetResult['operations'] as int;
    final sameNetDetails = sameNetResult['details'] as List<FeeOptimizerDetail>;
    final foundValidSameNetInterval = sameNetOperations > 0;

    // Always return data with validity flags
    return {
      'maxNetAmount': maxNetAmount,
      'maxFee': maxFee,
      'maxOperations': maxOperations,
      'maxDetails': maxDetails,
      'sameNetFee': sameNetFee,
      'sameNetTotalAmount': sameNetTotalAmount,
      'sameNetOperations': sameNetOperations,
      'sameNetDetails': sameNetDetails,
      'hasValidMaxInterval': foundValidMaxInterval,
      'hasValidSameNetInterval': foundValidSameNetInterval,
    };
  }
}

// Optimized internal classes
class _FeeOption {
  _FeeOption({
    required this.min,
    required this.max,
    required this.fee, // Raw value (% or fixed)
    required this.feeValue,
    required this.feeType,
  }) {
    // Convert to Decimal for unlimited precision calculations
    _minDecimal = DecimalUtil.toDecimal(min);
    _maxDecimal = DecimalUtil.toDecimal(max);
    _feeValueDecimal = DecimalUtil.toDecimal(feeValue);
  }

  final double min;
  final double max;
  final double fee; // Raw value (% or fixed)
  final double feeValue;
  final FeeType feeType;

  // Decimal versions for precise calculations
  late final Decimal _minDecimal;
  late final Decimal _maxDecimal;
  late final Decimal _feeValueDecimal;

  double getFeeForAmount(double amount) {
    final amountDecimal = DecimalUtil.toDecimal(amount);
    final feeDecimal = DecimalUtil.calculateFee(
      amount: amountDecimal,
      feeValue: _feeValueDecimal,
      isPercentage: feeType == FeeType.percentage,
    );
    return DecimalUtil.toDouble(feeDecimal);
  }

  // Calculate net amount from budget with unlimited precision
  double getNetAmountFromBudget(double budget) {
    final budgetDecimal = DecimalUtil.toDecimal(budget);
    final netDecimal = DecimalUtil.calculateNetAmount(
      budget: budgetDecimal,
      feeValue: _feeValueDecimal,
      isPercentage: feeType == FeeType.percentage,
    );
    return DecimalUtil.toDouble(netDecimal);
  }

  // Decimal version for internal calculations
  Decimal getFeeForAmountDecimal(Decimal amount) {
    return DecimalUtil.calculateFee(
      amount: amount,
      feeValue: _feeValueDecimal,
      isPercentage: feeType == FeeType.percentage,
    );
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
