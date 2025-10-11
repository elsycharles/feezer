import 'dart:math';
import '../../model/fee_interval_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import '../../model/fee_minimizer_detail_model.dart';
import '../../util/constant_util.dart';

class FeeOptimizerUtil {
  // Cache pour mémoriser les résultats récents
  static final _cache = LRUCache<String, FeeOptimizerResult>(100);
  
  // Limites de sécurité pour éviter les crashs
  static const int _maxSafeOperations = 10000;
  // static const int _maxIterationsPerOption = 100;
  static const double _maxSafeAmount = 1e15; // Quadrillion
  
  static FeeOptimizerResult calculateOptimalOperations(
    double totalAmount,
    List<FeeInterval> intervals, {
    double precision = ConstantUtil.defaultPrecision,
    int maxOperations = 0,
    int minOperations = 0,
  }) {
    // Validation et normalisation des entrées
    totalAmount = min(totalAmount, _maxSafeAmount);
    maxOperations = maxOperations > 0 ? min(maxOperations, _maxSafeOperations) : 0;
    minOperations = minOperations > 0 ? min(minOperations, maxOperations > 0 ? maxOperations : _maxSafeOperations) : 0;
    
    // Génération de la clé de cache
    final cacheKey = _generateCacheKey(totalAmount, intervals, precision, maxOperations, minOperations);
    
    // Vérifier le cache
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;
    
    try {
      _validateInput(totalAmount, intervals, maxOperations, minOperations);
      
      final options = _normalizeOptions(intervals);
      if (options.isEmpty) {
        return _buildResult(totalAmount, 0, 0, totalAmount, {});
      }
      
      // Stratégie adaptative selon le montant
      final result = _computeOptimalStrategy(
        totalAmount, 
        options, 
        precision, 
        maxOperations, 
        minOperations
      );
      
      // Mettre en cache le résultat
      _cache.put(cacheKey, result);
      
      return result;
    } catch (e) {
      // En cas d'erreur, retourner un résultat vide mais valide
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
    // Pour les très gros montants, utiliser une approche simplifiée
    if (totalAmount > 1e12) {
      return _ultraHighAmountStrategy(totalAmount, options, precision, maxOperations, minOperations);
    }
    
    // Pour les montants moyens à élevés
    if (totalAmount > 1e6) {
      return _highAmountStrategy(totalAmount, options, precision, maxOperations, minOperations);
    }
    
    // Pour les petits montants, approche exhaustive
    final unlimitedResult = totalAmount <= ConstantUtil.threshold
        ? _selectBest([
            _greedyOptimizedFast(totalAmount, options, precision),
            _repeatedOperationsOptimized(totalAmount, options, precision),
          ])
        : _greedyOptimizedFast(totalAmount, options, precision);

    return _applyConstraintsOptimized(
      unlimitedResult, totalAmount, options, precision, maxOperations, minOperations,
    );
  }

  static FeeOptimizerResult _ultraHighAmountStrategy(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    // Pour les montants extrêmes, utiliser uniquement l'option la plus efficiente
    final bestOption = _findMostEfficientOption(options);
    if (bestOption == null) {
      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }
    
    final operationCost = bestOption.max + bestOption.fee;
    final maxPossibleOps = (totalAmount / operationCost).floor();
    
    int targetOps = maxPossibleOps;
    if (maxOperations > 0) targetOps = min(targetOps, maxOperations);
    if (minOperations > 0) targetOps = max(targetOps, minOperations);
    
    final netAmount = bestOption.max * targetOps;
    final totalFees = bestOption.fee * targetOps;
    final remaining = totalAmount - (operationCost * targetOps);
    
    return _buildResult(
      totalAmount,
      netAmount,
      totalFees,
      remaining,
      {'${bestOption.max}-${bestOption.fee}': targetOps},
    );
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
    return _hybridOptimization(totalAmount, topOptions, precision, maxOperations, minOperations);
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
    
    // Limiter le nombre d'itérations pour éviter les boucles infinies
    while (budget > 0 && iterations < _maxSafeOperations) {
      final best = _findBestOperationFast(budget, options, precision);
      if (best == null) break;
      
      // Calculer combien de fois on peut répéter cette opération
      final operationCost = best.amount + best.fee;
      final repeatCount = min((budget / operationCost).floor(), 1000);
      
      if (repeatCount > 0) {
        final key = '${best.amount}-${best.fee}';
        counts[key] = (counts[key] ?? 0) + repeatCount;
        totalNet += best.amount * repeatCount;
        totalFees += best.fee * repeatCount;
        budget -= operationCost * repeatCount;
        iterations += repeatCount;
      } else {
        // Opération unique
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
    FeeOptimizerResult bestResult = _greedyOptimizedFast(totalAmount, options, precision);
    
    // Limiter le nombre d'options à tester pour les gros montants
    final optionsToTest = totalAmount > 1e9 ? options.take(3).toList() : options;
    
    for (final opt in optionsToTest) {
      // Utiliser une stratégie d'échantillonnage adaptatif
      final samples = _getAdaptiveSamples(opt, totalAmount, precision);
      
      for (final amount in samples) {
        if (amount < opt.min) continue;
        
        final cost = amount + opt.fee;
        final count = min((totalAmount / cost).floor(), _maxSafeOperations);
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

  static List<double> _getAdaptiveSamples(_FeeOption opt, double totalAmount, double precision) {
    final samples = <double>[];
    
    // Toujours tester le maximum
    samples.add(opt.max);
    
    // Pour les gros montants, réduire le nombre d'échantillons
    final numSamples = totalAmount > 1e9 ? 5 : (totalAmount > 1e6 ? 10 : 15);
    final step = max(precision, (opt.max - opt.min) / numSamples);
    
    for (int i = 1; i < numSamples; i++) {
      final amt = opt.max - (step * i);
      if (amt >= opt.min) {
        samples.add((amt / precision).floor() * precision);
      }
    }
    
    return samples;
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

    if (maxOperations == 0 && minOperations == 0) return unlimitedResult;
    if (_isWithinConstraints(actualCount, minOperations, maxOperations)) {
      return unlimitedResult;
    }

    if (actualCount < minOperations) {
      return _minConstrainedOperationsFast(totalAmount, options, precision, minOperations, maxOperations);
    }

    return _constrainedOperationsFast(totalAmount, options, precision, maxOperations, minOperations);
  }

  static bool _isWithinConstraints(int count, int min, int max) {
    if (min == 0 && max == 0) return true;
    if (min == 0 && max > 0) return count <= max;
    if (min > 0 && max == 0) return count >= min;
    return count >= min && count <= max;
  }

  static FeeOptimizerResult _constrainedOperationsFast(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int maxOperations,
    int minOperations,
  ) {
    // Pour les gros nombres d'opérations, utiliser une approche par batch
    if (maxOperations > 100) {
      return _batchConstrainedOperations(totalAmount, options, precision, maxOperations, minOperations);
    }
    
    final results = <FeeOptimizerResult>[];
    final start = max(1, minOperations);
    final end = min(maxOperations, 50);
    
    // Échantillonnage intelligent des nombres d'opérations
    final samples = _getOperationSamples(start, end);

    for (final numOperations in samples) {
      final result = _distributeOptimallyFast(totalAmount, options, precision, numOperations);
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
    // Utiliser l'option la plus efficiente pour remplir rapidement
    final bestOption = _findMostEfficientOption(options);
    if (bestOption == null) {
      return _buildResult(totalAmount, 0, 0, totalAmount, {});
    }
    
    final targetOps = min(maxOperations, (totalAmount / (bestOption.max + bestOption.fee)).floor());
    final actualOps = max(minOperations, targetOps);
    
    return _distributeWithMainOption(totalAmount, options, precision, actualOps, bestOption);
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
    
    // Remplir avec l'option principale
    final mainCost = mainOption.max + mainOption.fee;
    final mainCount = min(targetCount, (budget / mainCost).floor());
    
    if (mainCount > 0) {
      counts['${mainOption.max}-${mainOption.fee}'] = mainCount;
      budget -= mainCost * mainCount;
    }
    
    // Compléter avec d'autres options si nécessaire
    int remaining = targetCount - mainCount;
    for (final opt in options) {
      if (remaining <= 0 || budget <= 0) break;
      
      final cost = opt.max + opt.fee;
      if (cost > budget) continue;
      
      final count = min(remaining, (budget / cost).floor());
      if (count > 0) {
        counts['${opt.max}-${opt.fee}'] = count;
        budget -= cost * count;
        remaining -= count;
      }
    }
    
    return _buildResultFromCounts(totalAmount, counts);
  }

  static FeeOptimizerResult _minConstrainedOperationsFast(
    double totalAmount,
    List<_FeeOption> options,
    double precision,
    int minOperations,
    int maxOperations,
  ) {
    final targetOps = maxOperations > 0 
        ? min(maxOperations, minOperations + 10)
        : min(minOperations + 10, 100);
    
    return _distributeOptimallyFast(totalAmount, options, precision, targetOps) 
        ?? _buildResult(totalAmount, 0, 0, totalAmount, {});
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
        _findMostEfficientOption(options)!
      );
    }
    
    final counts = <String, int>{};
    double budget = totalAmount;
    
    // Stratégie : utiliser les meilleures options en priorité
    final sortedOptions = List<_FeeOption>.from(options)
      ..sort((a, b) => (b.max / b.fee).compareTo(a.max / a.fee));
    
    for (int i = 0; i < targetCount && budget > 0; i++) {
      _BestOperation? best;
      
      for (final opt in sortedOptions) {
        final maxAmount = min(opt.max, budget - opt.fee);
        if (maxAmount < opt.min) continue;
        
        final amount = (maxAmount / precision).floor() * precision;
        if (amount < opt.min) continue;
        
        final score = amount / opt.fee;
        if (best == null || score > best.score) {
          best = _BestOperation(amount: amount, fee: opt.fee, score: score);
        }
        
        // Sortir tôt si on a trouvé une très bonne option
        if (score > 100) break;
      }
      
      if (best == null) break;
      
      final key = '${best.amount}-${best.fee}';
      counts[key] = (counts[key] ?? 0) + 1;
      budget -= best.amount + best.fee;
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
    
    // Remplir avec les meilleures options
    for (final opt in options) {
      if (budget <= 0) break;
      if (maxOperations > 0 && totalOps >= maxOperations) break;
      
      final cost = opt.max + opt.fee;
      final maxCount = maxOperations > 0 
          ? min((budget / cost).floor(), maxOperations - totalOps)
          : (budget / cost).floor();
      
      if (maxCount > 0) {
        final count = min(maxCount, 1000); // Limiter pour éviter les overflow
        counts['${opt.max}-${opt.fee}'] = count;
        budget -= cost * count;
        totalOps += count;
      }
    }
    
    // S'assurer qu'on respecte minOperations
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

      final amount = (maxAmount / precision).floor() * precision;
      if (amount < opt.min) continue;

      // Optimisation : score simplifié pour les calculs rapides
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
    final intervalsHash = intervals.map((i) => 
      '${i.minAmount}-${i.maxAmount}-${i.fee}').join('|');
    return '$totalAmount-$intervalsHash-$precision-$maxOperations-$minOperations';
  }

  // Méthodes existantes optimisées
  static List<_FeeOption> _normalizeOptions(List<FeeInterval> intervals) {
    final validIntervals = intervals.where((interval) => interval.isValid).toList();
    if (validIntervals.isEmpty) return [];
    
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
    if (totalAmount > _maxSafeAmount) throw ArgumentError('Montant trop élevé');
    if (intervals.isEmpty) throw ArgumentError('Aucune option disponible');
    if (maxOperations < 0) throw ArgumentError('maxOperations doit être >= 0');
    if (minOperations < 0) throw ArgumentError('minOperations doit être >= 0');
    if (minOperations > 0 && maxOperations > 0 && minOperations > maxOperations) {
      throw ArgumentError('minOperations ne peut pas être supérieur à maxOperations');
    }
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
    if (results.isEmpty) return _buildResult(0, 0, 0, 0, {});
    
    return results.reduce((best, curr) {
      // Prioriser le montant net, puis les frais minimaux, puis le reste minimal
      if (curr.netAmount > best.netAmount) return curr;
      if (curr.netAmount == best.netAmount) {
        if (curr.totalFees < best.totalFees) return curr;
        if (curr.totalFees == best.totalFees && curr.remaining < best.remaining) {
          return curr;
        }
      }
      return best;
    });
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

// Classes internes optimisées
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