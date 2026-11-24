import 'dart:collection';

import 'package:feezer/core/optimizer/fee_tier.dart';

/// Brute-force reference: exact dynamic programming over integer costs, for
/// fixed-fee tiers with integer bounds. Slow (O(budget * tiers)) but simple.
class ReferenceSolver {
  ReferenceSolver(this.tiers) : assert(tiers.every((t) => !t.isPercentage));

  final List<FeeTier> tiers;

  /// Best net amount with total cost <= [budget] and any number of
  /// transactions.
  double bestNet(int budget) {
    final best = List<double>.filled(budget + 1, 0);
    final windows = [for (final _ in tiers) _MaxWindow()];
    for (var b = 1; b <= budget; b++) {
      var value = best[b - 1];
      for (var t = 0; t < tiers.length; t++) {
        final tier = tiers[t];
        final lo = tier.minCost.round();
        final hi = tier.maxCost.round();
        final window = windows[t];
        final entering = b - lo;
        if (entering >= 0) window.push(entering, best[entering] - entering);
        window.dropBefore(b - hi);
        if (!window.isEmpty) {
          final candidate = b - tier.fixedFee + window.max;
          if (candidate > value) value = candidate;
        }
      }
      best[b] = value;
    }
    return best[budget];
  }

  /// Best net amount for every exact number of transactions in `0..maxK`
  /// (`-infinity` when impossible).
  List<double> bestNetByCount(int budget, int maxK) {
    var previous = List<double>.filled(budget + 1, 0);
    final result = <double>[0];
    for (var k = 1; k <= maxK; k++) {
      final current = List<double>.filled(budget + 1, double.negativeInfinity);
      final windows = [for (final _ in tiers) _MaxWindow()];
      for (var b = 0; b <= budget; b++) {
        var value = b > 0 ? current[b - 1] : double.negativeInfinity;
        for (var t = 0; t < tiers.length; t++) {
          final tier = tiers[t];
          final lo = tier.minCost.round();
          final hi = tier.maxCost.round();
          final window = windows[t];
          final entering = b - lo;
          if (entering >= 0 && previous[entering] > double.negativeInfinity) {
            window.push(entering, previous[entering] - entering);
          }
          window.dropBefore(b - hi);
          if (!window.isEmpty) {
            final candidate = b - tier.fixedFee + window.max;
            if (candidate > value) value = candidate;
          }
        }
        current[b] = value;
      }
      result.add(current[budget]);
      previous = current;
    }
    return result;
  }
}

extension ReferenceAtLeast on ReferenceSolver {
  /// Best net amount using at least [minCount] transactions (any number above).
  double bestNetAtLeast(int budget, int minCount) {
    if (minCount <= 0) return bestNet(budget);
    var previous = List<double>.filled(budget + 1, 0);
    for (var layer = 1; layer <= minCount; layer++) {
      final last = layer == minCount;
      final current = List<double>.filled(budget + 1, double.negativeInfinity);
      final windows = [for (final _ in tiers) _MaxWindow()];
      for (var b = 0; b <= budget; b++) {
        var value = b > 0 ? current[b - 1] : double.negativeInfinity;
        for (var t = 0; t < tiers.length; t++) {
          final tier = tiers[t];
          final entering = b - tier.minCost.round();
          if (entering >= 0) {
            var source = previous[entering];
            if (last && current[entering] > source) source = current[entering];
            if (source > double.negativeInfinity) {
              windows[t].push(entering, source - entering);
            }
          }
          windows[t].dropBefore(b - tier.maxCost.round());
          if (!windows[t].isEmpty) {
            final candidate = b - tier.fixedFee + windows[t].max;
            if (candidate > value) value = candidate;
          }
        }
        current[b] = value;
      }
      previous = current;
    }
    return previous[budget];
  }
}

class _MaxWindow {
  final _keys = Queue<int>();
  final _values = Queue<double>();

  bool get isEmpty => _keys.isEmpty;
  double get max => _values.first;

  void push(int key, double value) {
    while (_values.isNotEmpty && _values.last <= value) {
      _values.removeLast();
      _keys.removeLast();
    }
    _keys.addLast(key);
    _values.addLast(value);
  }

  void dropBefore(int key) {
    while (_keys.isNotEmpty && _keys.first < key) {
      _keys.removeFirst();
      _values.removeFirst();
    }
  }
}

/// Brute-force reference with an amount step: every transaction amount is a
/// multiple of [step] (tiers already rounded with the same step), fixed
/// integer fees. Dynamic programming over integer costs.
class SteppedReference {
  SteppedReference(this.tiers, this.step)
    : assert(tiers.every((t) => !t.isPercentage)) {
    for (final tier in tiers) {
      for (
        var amount = tier.minAmount.round();
        amount <= tier.maxAmount.round();
        amount += step
      ) {
        _items.add((amount + tier.fixedFee.round(), amount));
      }
    }
  }

  final List<FeeTier> tiers;
  final int step;

  /// `(cost, amount)` of every possible transaction.
  final List<(int, int)> _items = [];

  static const double _none = double.negativeInfinity;

  /// Adds any number of transactions on top of [base] (best net per budget).
  List<double> _unbounded(List<double> base) {
    final best = List.of(base);
    for (var b = 1; b < best.length; b++) {
      if (best[b - 1] > best[b]) best[b] = best[b - 1];
      for (final (cost, amount) in _items) {
        if (cost <= b && best[b - cost] > _none) {
          final value = best[b - cost] + amount;
          if (value > best[b]) best[b] = value;
        }
      }
    }
    return best;
  }

  /// Adds exactly one transaction to [previous].
  List<double> _layer(List<double> previous) {
    final current = List<double>.filled(previous.length, _none);
    for (var b = 0; b < previous.length; b++) {
      if (b > 0 && current[b - 1] > current[b]) current[b] = current[b - 1];
      for (final (cost, amount) in _items) {
        if (cost <= b && previous[b - cost] > _none) {
          final value = previous[b - cost] + amount;
          if (value > current[b]) current[b] = value;
        }
      }
    }
    return current;
  }

  /// Best net amount for [budget] with between [minCount] and [maxCount]
  /// transactions (`0`: no bound); `-infinity` when impossible.
  double bestNet(int budget, {int minCount = 0, int maxCount = 0}) {
    var layer = List<double>.filled(budget + 1, 0);
    if (maxCount <= 0) {
      for (var k = 0; k < minCount; k++) {
        layer = _layer(layer);
      }
      return _unbounded(layer)[budget];
    }
    var best = _none;
    for (var k = 1; k <= maxCount; k++) {
      layer = _layer(layer);
      if (k >= minCount && layer[budget] > best) best = layer[budget];
    }
    return best;
  }
}
