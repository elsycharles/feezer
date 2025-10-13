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
            _findBestSingleOperation(totalAmount, options), // Nouvelle méthode
          ])
        : _selectBest([
            _greedyOptimizedFast(totalAmount, options, precision),
            _findBestSingleOperation(totalAmount, options), // Nouvelle méthode
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
        // totalAmount = netAmount + netAmount * (feeValue / 100)
        netAmount = totalAmount / (1 + opt.feeValue / 100);
        fee = netAmount * (opt.feeValue / 100);
      } else {
        netAmount = totalAmount - opt.feeValue;
        fee = opt.feeValue;
      }

      if (netAmount >= opt.min && netAmount <= opt.max && 
          netAmount > 0 && (netAmount + fee) <= totalAmount) { // AJOUT
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

    // ✅ Essayer d'abord une solution optimale avec une seule option
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

    // ✅ Si pas possible, utiliser la distribution mixte
    return _mixedDistribution(totalAmount, options, precision, targetCount);
  }

  // ✅ Nouvelle fonction : Distribution avec une seule option
  static FeeOptimizerResult? _trySingleOptionDistribution(
    double totalAmount,
    _FeeOption opt,
    double precision,
    int targetCount,
  ) {
    // ✅ Calcul correct selon le type de frais
    double amountPerOp;
    
    if (opt.feeType == FeeType.percentage) {
      // Pour un pourcentage : totalAmount = targetCount * (amount + amount * fee/100)
      // totalAmount = targetCount * amount * (1 + fee/100)
      amountPerOp = totalAmount / (targetCount * (1 + opt.feeValue / 100));
    } else {
      // Pour un frais fixe : totalAmount = targetCount * (amount + fee)
      amountPerOp = (totalAmount - (opt.feeValue * targetCount)) / targetCount;
    }
    
    // Arrondir à la précision
    amountPerOp = (amountPerOp / precision).floor() * precision;

    // Vérifier les contraintes
    if (amountPerOp < opt.min || amountPerOp > opt.max) return null;

    final fee = opt.getFeeForAmount(amountPerOp);
    final totalCost = (amountPerOp + fee) * targetCount;

    // Tolérance pour les erreurs d'arrondi (0.01 = 1 centime)
    if (totalCost > totalAmount + 0.01) return null;

    return _buildResult(
      totalAmount,
      amountPerOp * targetCount,
      fee * targetCount,
      totalAmount - totalCost,
      {'$amountPerOp-$fee': targetCount},
    );
  }

  // ✅ Nouvelle fonction : Distribution mixte optimisée
  static FeeOptimizerResult? _mixedDistribution(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int targetCount,
  ) {
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
      double bestScore = -1;

      for (final opt in options) {
        // ✅ Calculer le montant optimal pour cette option
        double amount;
        
        if (opt.feeType == FeeType.percentage) {
          // Pour un pourcentage, résoudre : amount + amount*(fee/100) = targetAmount
          amount = targetAmount / (1 + opt.feeValue / 100);
        } else {
          amount = targetAmount - opt.feeValue;
        }

        // Arrondir et contraindre
        amount = (amount / precision).floor() * precision;
        amount = max(opt.min, min(opt.max, amount));

        final fee = opt.getFeeForAmount(amount);
        final totalCost = amount + fee;

        // Vérifier si cette opération est valide
        if (totalCost > remaining || amount < opt.min) continue;

        // ✅ Calculer le score uniquement pour les opérations valides
        final efficiency = amount / (fee + 0.0001); // Éviter division par zéro
        final utilization = amount / opt.max; // Favoriser l'utilisation complète
        final costFit = (targetAmount - totalCost).abs(); // Proximité au budget cible
        
        // Score amélioré : privilégier efficacité, utilisation et adéquation au budget
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

    // ✅ Calculer le frais réel au montant maximum
    final realFee = bestOption.getFeeForAmount(bestOption.max);
    final operationCost = bestOption.max + realFee;
    
    final maxPossibleOps = (totalAmount / operationCost).floor();

    int targetOps = maxPossibleOps;
    if (maxOperations > 0) targetOps = min(targetOps, maxOperations);
    if (minOperations > 0) targetOps = max(targetOps, minOperations);

    final netAmount = bestOption.max * targetOps;
    final totalFees = realFee * targetOps;
    final remaining = totalAmount - (operationCost * targetOps);

    return _buildResult(totalAmount, netAmount, totalFees, remaining, {
      '${bestOption.max}-$realFee': targetOps,
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
    // D'abord, essayer de trouver une solution en une seule opération
    _BestOperation? bestSingleOp;

    for (final opt in options) {
      final minAmount = opt.min;
      final maxAmount = opt.max;

      // Calculer le montant net si on utilise tout le budget
      double netAmount;
      double fee;

      if (opt.feeType == FeeType.percentage) {
        // totalAmount = netAmount + netAmount * (feeValue / 100)
        // totalAmount = netAmount * (1 + feeValue / 100)
        netAmount = totalAmount / (1 + opt.feeValue / 100);
        fee = netAmount * (opt.feeValue / 100);
      } else {
        netAmount = totalAmount - opt.feeValue;
        fee = opt.feeValue;
      }

      // Vérifier si ce montant net est dans l'intervalle
      if (netAmount >= minAmount && netAmount <= maxAmount && 
          netAmount > 0 && (netAmount + fee) <= totalAmount) { // AJOUT
        final efficiency = netAmount / fee;

        if (bestSingleOp == null || efficiency > bestSingleOp.score) {
          bestSingleOp = _BestOperation(
            amount: netAmount,
            fee: fee,
            score: efficiency,
          );
        }
      }
    }

    // Si on a trouvé une solution en une seule opération, comparer avec multi-opérations
    if (bestSingleOp != null) {
      final singleOpResult = _buildResult(
        totalAmount,
        bestSingleOp.amount,
        bestSingleOp.fee,
        totalAmount - bestSingleOp.amount - bestSingleOp.fee,
        {'${bestSingleOp.amount}-${bestSingleOp.fee}': 1},
      );

      // Comparer avec l'approche multi-opérations
      final multiOpResult = _greedyMultiOperations(totalAmount, options, precision);

      // Retourner le meilleur résultat (priorité au montant net, puis frais minimaux)
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

    return _buildResult(totalAmount, totalNet, totalFees, budget, counts);
  }

  static FeeOptimizerResult _repeatedOperationsOptimized(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
  ) {
    FeeOptimizerResult bestResult = _buildResult(totalAmount, 0, 0, totalAmount, {});

    // Tester d'abord une opération unique utilisant tout le budget
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
          totalAmount,
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

    // Tester également l'approche multi-opérations
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

        final cost = amount + opt.getFeeForAmount(amount);
        final count = min(
          (totalAmount / cost).floor(),
          _maxSafeOperations,
        );
        if (count == 0) continue;

        final net = amount * count;
        final fees = opt.getFeeForAmount(amount) * count;
        final remaining = totalAmount - cost * count;

        if (net > bestResult.netAmount ||
            (net == bestResult.netAmount && fees < bestResult.totalFees)) {
          final counts = <String, int>{'$amount-${opt.getFeeForAmount(amount)}': count};
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
        // ✅ RESTAURER l'arrondi pour respecter la précision
        final rounded = (amt / precision).floor() * precision;
        if (rounded >= opt.min) {
          samples.add(rounded);
        }
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

    // ✅ Utiliser le frais réel
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

    // ✅ Utiliser le frais réel
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

      // ✅ Calculer le frais réel pour chaque option
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

      // ✅ Utiliser le frais réel
      final optFee = opt.getFeeForAmount(opt.max);
      final cost = opt.max + optFee;
      
      final maxCount = maxOperations > 0
          ? min((budget / cost).floor(), maxOperations - totalOps)
          : (budget / cost).floor();

      if (maxCount > 0) {
        final count = min(maxCount, _maxSafeOperations - totalOps);
        counts['${opt.max}-$optFee'] = count;
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
      // ✅ Calculer l'efficacité au montant maximum
      final fee = opt.getFeeForAmount(opt.max);
      final efficiency = opt.max / (fee + 0.0001);
      
      if (efficiency > bestEfficiency) {
        bestEfficiency = efficiency;
        best = opt;
      }
    }

    return best;
  }

  static List<_FeeOption> _getTopOptions(List<_FeeOption> options, int count) {
    final sorted = List<_FeeOption>.from(options)
      ..sort((a, b) {
        // ✅ Calculer l'efficacité réelle au montant maximum
        final feeA = a.getFeeForAmount(a.max);
        final feeB = b.getFeeForAmount(b.max);
        final effA = a.max / (feeA + 0.0001);
        final effB = b.max / (feeB + 0.0001);
        return effB.compareTo(effA);
      });
    return sorted.take(count).toList();
  }

  static _BestOperation? _findBestOperationFast(
    double budget,
    List<_FeeOption> options,
    double precision,
  ) {
    _BestOperation? best;
    double bestScore = -1;

    for (final opt in options) {
      double maxAmount;
      
      if (opt.feeType == FeeType.percentage) {
        // ✅ Pour un pourcentage : budget = amount + amount*(fee/100)
        maxAmount = budget / (1 + opt.feeValue / 100);
      } else {
        maxAmount = budget - opt.feeValue;
      }

      maxAmount = min(maxAmount, opt.max);
      if (maxAmount < opt.min) continue;

      // ✅ RESTAURER l'arrondi
      final amount = (maxAmount / precision).floor() * precision;
      if (amount < opt.min) continue;

      final fee = opt.getFeeForAmount(amount);
      final score = amount / (fee + 0.0001);

      if (score > bestScore) {
        bestScore = score;
        best = _BestOperation(amount: amount, fee: fee, score: score);
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
      // ✅ Ne plus approximer, stocker directement le type
      return _FeeOption(
        min: interval.minAmount!,
        max: interval.maxAmount!,
        fee: interval.fee!, // Valeur brute (% ou fixe)
        feeValue: interval.fee!,
        feeType: interval.feeType,
      );
    }).toList();

    // ✅ Tri dynamique basé sur l'efficacité réelle au max
    options.sort((a, b) {
      final effA = _calculateEfficiency(a.max, a);
      final effB = _calculateEfficiency(b.max, b);
      return effB.compareTo(effA);
    });
    
    return options;
  }

  // ✅ Fonction helper pour calculer l'efficacité réelle
  static double _calculateEfficiency(double amount, _FeeOption opt) {
    final fee = opt.getFeeForAmount(amount);
    return amount / (fee + 0.0001); // Éviter division par zéro
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
    required this.fee, // ✅ Maintenant stocke la valeur brute
    required this.feeValue,
    required this.feeType,
  });
  
  final double min;
  final double max;
  final double fee; // Valeur brute (% ou fixe)
  final double feeValue;
  final FeeType feeType;

  double getFeeForAmount(double amount) {
    if (feeType == FeeType.percentage) {
      return amount * (feeValue / 100.0);
    } else {
      return feeValue;
    }
  }
  
  // ✅ Nouvelle méthode : calculer le montant net à partir d'un budget
  double getNetAmountFromBudget(double budget) {
    if (feeType == FeeType.percentage) {
      return budget / (1 + feeValue / 100.0);
    } else {
      return budget - feeValue;
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
