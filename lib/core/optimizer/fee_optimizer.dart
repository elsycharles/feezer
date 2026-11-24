import 'dart:math' as math;

import '../../model/fee_interval_model.dart';
import '../../model/fee_minimizer_detail_model.dart';
import '../../model/fee_minimizer_result_model.dart';
import 'fee_tier.dart';
import 'naive_strategy.dart';

/// Exact fee optimizer.
///
/// ## Problem
/// Given a budget `B` and fee tiers (`[min, max]` amount ranges with a fixed
/// or percentage fee), choose a set of transactions whose total cost
/// (amounts + fees) does not exceed `B` so that:
///   1. the total amount received is maximal,
///   2. then the total fees are minimal,
///   3. then the number of transactions is minimal,
/// optionally with a minimum and/or maximum number of transactions.
///
/// ## Method
/// * For a fixed number of transactions per tier (a *count vector*), the best
///   amounts are given by a linear program solved in closed form: every
///   transaction starts at its tier minimum and the remaining budget is
///   poured where it costs the least (fixed-fee tiers first, then percentage
///   tiers by increasing rate).
/// * Count vectors are enumerated tier by tier with two pruning rules:
///   - a *reference line* `net <= alpha + beta * cost` dominating every
///     possible single transaction bounds the plan by `K * alpha + beta * B`;
///     each transaction loses a measurable *deficit* against that line, so
///     vectors that already lose more than the best plan's margin are cut;
///   - partial vectors dominated by another one (higher minimum cost, lower
///     maximum cost and higher fees) are discarded (Pareto front).
/// * The counts of the one or two *reference tiers* (those touching the line)
///   are not enumerated: the objective is concave in them, so they are found
///   with a galloping/binary search.
///
/// Without transaction constraints the line goes through the origin and the
/// most efficient tier. With constraints, the problem is solved for exact
/// transaction counts `K` using the concave envelope of the single
/// transaction value, iterating over `K` only while the bound can still beat
/// the best plan found.
///
/// ## Amount step
/// With a positive `step` (cash withdrawals: notes only), every transaction
/// amount is a multiple of `step`. Tier bounds are rounded inwards to
/// multiples of `step` and the budget is poured by whole steps; the greedy
/// fill stays optimal because every step brings the same net amount. The
/// continuous value of a count vector bounds its stepped value, so the
/// pruning rules still hold; the counts of the reference tiers are found by
/// closed form (fixed fees) or by scanning around the continuous optimum
/// while the bound can still beat the best plan.
///
/// The search is exact; a safety limit on the number of evaluated count
/// vectors keeps pathological inputs fast, in which case
/// [FeeOptimizerResult.isProvenOptimal] is `false`.
class FeeOptimizer {
  const FeeOptimizer._();

  /// Largest budget (in base currency) handled with full precision.
  static const double maxSupportedAmount = 1e15;

  /// Default maximum number of count vectors evaluated by one search.
  static const int defaultLeafLimit = 3000000;

  /// Default time budget of one optimization. When it is exceeded the best
  /// plan found so far is returned (flagged as not proven optimal).
  static const Duration defaultTimeLimit = Duration(milliseconds: 1500);

  /// Optimizes the transfer of [budget] (fees included) using [intervals].
  ///
  /// [minOperations] / [maxOperations] constrain the number of transactions;
  /// `0` means "no constraint". With a positive [step], every amount is a
  /// multiple of [step].
  static FeeOptimizerResult optimize(
    double budget,
    Iterable<FeeInterval> intervals, {
    int minOperations = 0,
    int maxOperations = 0,
    double step = 0,
    int leafLimit = defaultLeafLimit,
    Duration timeLimit = defaultTimeLimit,
  }) {
    final tiers = FeeTier.fromIntervals(intervals, step: step);
    if (tiers.isEmpty &&
        step > 0 &&
        FeeTier.fromIntervals(intervals).isNotEmpty) {
      return FeeOptimizerResult.empty(
        budget.isFinite ? budget : 0,
        OptimizationStatus.stepTooLarge,
      );
    }
    return optimizeTiers(
      budget,
      tiers,
      minOperations: minOperations,
      maxOperations: maxOperations,
      step: step,
      leafLimit: leafLimit,
      timeLimit: timeLimit,
    );
  }

  /// Same as [optimize] with already normalized [tiers] (built with the same
  /// [step]).
  static FeeOptimizerResult optimizeTiers(
    double budget,
    List<FeeTier> tiers, {
    int minOperations = 0,
    int maxOperations = 0,
    double step = 0,
    int leafLimit = defaultLeafLimit,
    Duration timeLimit = defaultTimeLimit,
  }) {
    if (tiers.isEmpty) {
      return FeeOptimizerResult.empty(
        budget,
        OptimizationStatus.noFeeIntervals,
      );
    }
    if (!budget.isFinite || budget <= 0) {
      return FeeOptimizerResult.empty(
        budget.isFinite ? budget : 0,
        OptimizationStatus.budgetTooSmall,
      );
    }
    return _Solver(
      budget,
      tiers,
      step > 0 ? step : 0,
      leafLimit,
      timeLimit,
    ).solve(
      minOperations > 0 ? minOperations : 0,
      maxOperations > 0 ? maxOperations : 0,
    );
  }
}

/// Straight line `net = alpha + beta * cost` dominating every transaction.
class _Line {
  const _Line(this.alpha, this.beta);
  final double alpha;
  final double beta;
}

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

/// Partial count vector explored by the search, stored as a chain of
/// `(tier, count)` choices sharing their prefix with the parent state.
class _State {
  _State(
    this.parent,
    this.tier,
    this.count,
    this.mandatory,
    this.maxCost,
    this.fees,
    this.total,
    this.deficit,
    this.percentageKey, {
    this.isNew = false,
  });

  final _State? parent;
  final int tier;
  final int count;

  /// Sum of the minimum costs.
  final double mandatory;

  /// Sum of the maximum costs.
  final double maxCost;

  /// Sum of the fixed fees.
  final double fees;

  /// Number of transactions.
  final int total;

  /// Lower bound of the loss against the reference line.
  final double deficit;

  /// Counts of the percentage tiers (states are only comparable when equal).
  final String percentageKey;

  bool isNew;

  void writeCounts(List<int> target) {
    target.fillRange(0, target.length, 0);
    for (_State? s = this; s != null; s = s.parent) {
      if (s.count > 0) target[s.tier] = s.count;
    }
  }
}

class _Solver {
  _Solver(this.budget, this.tiers, this.step, this.leafLimit, this.timeLimit)
    : n = tiers.length,
      eps = 1e-12 * math.max(1.0, budget) + 1e-9,
      mins = [for (final t in tiers) t.minAmount],
      maxs = [for (final t in tiers) t.maxAmount],
      rates = [for (final t in tiers) t.rate],
      fixeds = [for (final t in tiers) t.fixedFee],
      los = [for (final t in tiers) t.minCost],
      his = [for (final t in tiers) t.maxCost] {
    // Fill order of the linear program: fixed-fee tiers first (one unit of
    // budget gives one unit of net), biggest first for nicer plans, then
    // percentage tiers by increasing rate.
    fillOrder = List.generate(n, (i) => i)
      ..sort((a, b) {
        final byRate = rates[a].compareTo(rates[b]);
        return byRate != 0 ? byRate : maxs[b].compareTo(maxs[a]);
      });
    counts = List.filled(n, 0);
  }

  final double budget;
  final List<FeeTier> tiers;

  /// Every amount is a multiple of [step] (0: any amount).
  final double step;
  final int leafLimit;
  final Duration timeLimit;
  final Stopwatch _clock = Stopwatch()..start();
  final int n;
  final double eps;

  final List<double> mins;
  final List<double> maxs;
  final List<double> rates;
  final List<double> fixeds;
  final List<double> los;
  final List<double> his;
  late final List<int> fillOrder;

  /// Working count vector of the search.
  late final List<int> counts;

  // Best plan found so far.
  List<int>? _bestCounts;
  double _bestNet = double.negativeInfinity;
  double _bestFees = double.infinity;
  int _bestCount = 0;

  int _leaves = 0;
  bool _truncated = false;
  bool _searchTruncated = false;

  // State of the current search.
  double _bound = double.infinity;
  bool _stop = false;
  late List<double> _lbBase;
  late List<double> _lbSlope;
  bool _wlog = false;
  List<_Point>? _hull;

  // ---------------------------------------------------------------------------
  // Entry point
  // ---------------------------------------------------------------------------

  FeeOptimizerResult solve(int minOps, int maxOps) {
    final cheapest = los.reduce(math.min);
    if (budget + eps < cheapest) {
      return FeeOptimizerResult.empty(
        budget,
        OptimizationStatus.budgetTooSmall,
      );
    }
    if (minOps > 0 && maxOps > 0 && minOps > maxOps) {
      return FeeOptimizerResult.empty(
        budget,
        OptimizationStatus.constraintsUnsatisfiable,
      );
    }
    final maxFeasible = _floorClamp((budget + eps) / cheapest, 0, 1 << 52);
    final kMin = minOps > 0 ? minOps : 1;
    final kMax = maxOps > 0 ? math.min(maxOps, maxFeasible) : maxFeasible;
    if (kMin > kMax) {
      return FeeOptimizerResult.empty(
        budget,
        OptimizationStatus.constraintsUnsatisfiable,
      );
    }

    _searchFree();
    final unconstrainedCount = _bestCount;
    if (_bestCounts != null &&
        unconstrainedCount >= kMin &&
        unconstrainedCount <= kMax) {
      return _buildResult();
    }

    // The unconstrained optimum violates a constraint: the best plan then uses
    // an exact number of transactions K, explored from the violated bound.
    _resetBest();
    const maxIterations = 200;
    var iterations = 0;
    if (unconstrainedCount > kMax) {
      for (var k = kMax; k >= kMin; k--) {
        final line = _envelopeAt(budget / k);
        if (line == null) continue;
        final bound = k * line.alpha + line.beta * budget;
        if (_bestCounts != null && bound <= _bestNet + eps) {
          // The bound is concave in K and increases with K once alpha >= 0:
          // smaller K cannot do better.
          if (line.alpha >= 0) break;
          continue;
        }
        if (++iterations > maxIterations ||
            (_bestCounts != null && _clock.elapsed > timeLimit)) {
          _truncated = true;
          break;
        }
        _searchExact(k, line);
      }
    } else {
      for (var k = kMin; k <= kMax; k++) {
        final line = _envelopeAt(budget / k);
        if (line == null) break;
        final bound = k * line.alpha + line.beta * budget;
        if (_bestCounts != null && bound <= _bestNet + eps) {
          // Past the peak of the concave bound, bigger K cannot do better.
          if (line.alpha <= 0) break;
          continue;
        }
        if (++iterations > maxIterations ||
            (_bestCounts != null && _clock.elapsed > timeLimit)) {
          _truncated = true;
          break;
        }
        _searchExact(k, line);
      }
    }

    if (_bestCounts == null) {
      return FeeOptimizerResult.empty(
        budget,
        OptimizationStatus.constraintsUnsatisfiable,
      );
    }
    return _buildResult();
  }

  // ---------------------------------------------------------------------------
  // Linear program for a count vector
  // ---------------------------------------------------------------------------

  double _lastFees = 0;

  /// Best net amount for [counts]; `-infinity` when the mandatory minimums
  /// exceed the budget. The fees are stored in [_lastFees].
  ///
  /// With [continuous], the amount step is ignored: the result is then an
  /// upper bound of the stepped value of the same counts.
  double _evaluate(List<int> c, {bool continuous = false}) {
    final stepped = step > 0 && !continuous;
    var mandatory = 0.0;
    for (var i = 0; i < n; i++) {
      final k = c[i];
      if (k != 0) mandatory += k * los[i];
    }
    if (mandatory > budget + eps) return double.negativeInfinity;
    var extra = budget - mandatory;
    if (extra < 0) extra = 0;
    var net = 0.0;
    var fees = 0.0;
    for (final i in fillOrder) {
      final k = c[i];
      if (k == 0) continue;
      final unit = 1 + rates[i];
      final capacity = k * (maxs[i] - mins[i]);
      var take = extra / unit;
      if (stepped) take = FeeTier.floorToStep(take, step);
      if (take > capacity) take = capacity;
      extra -= take * unit;
      if (extra < 0) extra = 0;
      final amount = k * mins[i] + take;
      net += amount;
      fees += k * fixeds[i] + amount * rates[i];
    }
    _lastFees = fees;
    return net;
  }

  int _total(List<int> c) {
    var total = 0;
    for (final k in c) {
      total += k;
    }
    return total;
  }

  void _offerCurrent() {
    final net = _evaluate(counts);
    if (net == double.negativeInfinity) return;
    final fees = _lastFees;
    final total = _total(counts);
    if (total == 0) return;
    if (_isBetter(net, fees, total)) {
      _bestCounts = List.of(counts);
      _bestNet = net;
      _bestFees = fees;
      _bestCount = total;
      if (_bestNet >= _bound - eps) _stop = true;
    }
  }

  bool _isBetter(double net, double fees, int total) {
    if (_bestCounts == null) return true;
    if (net > _bestNet + eps) return true;
    if (net < _bestNet - eps) return false;
    if (fees < _bestFees - eps) return true;
    if (fees > _bestFees + eps) return false;
    return total < _bestCount;
  }

  void _resetBest() {
    _bestCounts = null;
    _bestNet = double.negativeInfinity;
    _bestFees = double.infinity;
    _bestCount = 0;
  }

  // ---------------------------------------------------------------------------
  // Unconstrained search
  // ---------------------------------------------------------------------------

  void _searchFree() {
    var reference = 0;
    for (var i = 1; i < n; i++) {
      final e = tiers[i].efficiency;
      final best = tiers[reference].efficiency;
      if (e > best + 1e-15 ||
          (e >= best - 1e-15 && maxs[i] > maxs[reference])) {
        reference = i;
      }
    }
    final beta = tiers[reference].efficiency;
    _bound = beta * budget;
    _stop = false;
    _leaves = 0;
    _searchTruncated = false;
    _wlog = true;
    _lbBase = List.filled(n, 0);
    _lbSlope = List.filled(n, 0);
    for (var i = 0; i < n; i++) {
      _lbBase[i] = fixeds[i];
      _lbSlope[i] = beta - 1 / (1 + rates[i]);
    }

    // Seed with the naive plan: a valid, usually good, starting point.
    counts.fillRange(0, n, 0);
    for (final naive in NaiveStrategy.maxNetPlan(budget, tiers, step: step)) {
      counts[naive.tierIndex] += naive.count;
    }
    _offerCurrent();
    counts.fillRange(0, n, 0);

    final others = [
      for (var i = 0; i < n; i++)
        if (i != reference) i,
    ]..sort((a, b) => _lowerBound(a, 1).compareTo(_lowerBound(b, 1)));

    final allFixed = rates.every((r) => r == 0);
    _paretoSearch(others, 1 << 52, false, (mandatory, maxCostSum, fees, total) {
      if (allFixed) {
        _leafFixed(reference, mandatory, maxCostSum, fees, total);
      } else {
        _leafSingle(reference, mandatory, maxCostSum, null);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Search with exactly K transactions
  // ---------------------------------------------------------------------------

  void _searchExact(int k, _Line line) {
    _bound = k * line.alpha + line.beta * budget;
    _stop = _bestCounts != null && _bestNet >= _bound - eps;
    if (_stop) return;
    _leaves = 0;
    _searchTruncated = false;
    _wlog = false;

    final deficit = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final atMin = line.alpha + line.beta * los[i] - mins[i];
      final atMax = line.alpha + line.beta * his[i] - maxs[i];
      deficit[i] = math.max(0, math.min(atMin, atMax));
    }
    _lbBase = deficit;
    _lbSlope = List.filled(n, 0);

    final order = List.generate(n, (i) => i)
      ..sort((a, b) {
        final byDeficit = deficit[a].compareTo(deficit[b]);
        return byDeficit != 0 ? byDeficit : maxs[b].compareTo(maxs[a]);
      });
    final refs = <int>[order.first];
    final tolerance = 1e-9 * (line.alpha.abs() + line.beta * budget / k + 1);
    if (n > 1 && line.beta > 0 && deficit[order[1]] <= tolerance) {
      refs.add(order[1]);
    }
    final others = [
      for (final i in order)
        if (!refs.contains(i)) i,
    ]..sort((a, b) => deficit[a].compareTo(deficit[b]));

    _paretoSearch(others, k, true, (mandatory, maxCostSum, fees, total) {
      final remaining = k - total;
      if (refs.length == 1) {
        _leafSingle(refs.first, mandatory, maxCostSum, remaining);
      } else {
        _leafPair(refs[0], refs[1], mandatory, maxCostSum, remaining);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Enumeration
  // ---------------------------------------------------------------------------

  /// Lower bound of the deficit of [k] transactions in tier [i].
  double _lowerBound(int i, int k) {
    if (k == 0) return 0;
    final slope = _lbSlope[i];
    final double cost;
    if (slope < 0) {
      cost = k * his[i];
    } else if (_wlog) {
      // Using more percentage transactions than needed never helps, so the
      // total cost of the tier exceeds (k - 1) full transactions.
      cost = math.max(k * los[i], (k - 1) * his[i]);
    } else {
      cost = k * los[i];
    }
    return math.max(0, k * _lbBase[i] + slope * cost);
  }

  /// Enumerates the count vectors of the tiers in [order] (all other tiers at
  /// zero) and calls [leaf] for each promising one.
  ///
  /// Tiers are added one at a time; after each step, partial vectors that are
  /// dominated (higher mandatory cost, lower maximum cost and higher fixed
  /// fees than another one with the same percentage counts) are discarded:
  /// any completion of the dominated vector is beaten by the same completion
  /// of the dominating one. Vectors whose deficit already exceeds the margin
  /// left by the best plan are discarded as well.
  void _paretoSearch(
    List<int> order,
    int maxTotal,
    bool keyByCount,
    void Function(double mandatory, double maxCostSum, double fees, int total)
    leaf,
  ) {
    final empty = _State(null, 0, 0, 0, 0, 0, 0, 0, '');
    _visit(empty, leaf);
    var front = [empty];
    for (final i in order) {
      if (_stop || _searchTruncated) break;
      final grown = <_State>[];
      for (final state in front) {
        grown.add(state);
        for (var k = 1; ; k++) {
          final deficit = state.deficit + _lowerBound(i, k);
          if (_bestCounts != null && _bound - deficit < _bestNet - eps) break;
          final mandatory = state.mandatory + k * los[i];
          if (mandatory > budget + eps) break;
          if (state.total + k > maxTotal) break;
          grown.add(
            _State(
              state,
              i,
              k,
              mandatory,
              state.maxCost + k * his[i],
              state.fees + k * fixeds[i],
              state.total + k,
              deficit,
              rates[i] > 0
                  ? '${state.percentageKey},$i:$k'
                  : state.percentageKey,
              isNew: true,
            ),
          );
        }
      }
      front = _prune(grown, keyByCount);
      for (final state in front) {
        if (_stop || _searchTruncated) break;
        if (state.isNew) {
          state.isNew = false;
          _visit(state, leaf);
        }
      }
    }
    counts.fillRange(0, n, 0);
  }

  void _visit(
    _State state,
    void Function(double mandatory, double maxCostSum, double fees, int total)
    leaf,
  ) {
    if (++_leaves > leafLimit ||
        ((_leaves & 1023) == 0 && _clock.elapsed > timeLimit)) {
      _searchTruncated = true;
      _truncated = true;
      return;
    }
    state.writeCounts(counts);
    leaf(state.mandatory, state.maxCost, state.fees, state.total);
    counts.fillRange(0, n, 0);
  }

  List<_State> _prune(List<_State> states, bool keyByCount) {
    final groups = <String, List<_State>>{};
    for (final state in states) {
      if (_bestCounts != null && _bound - state.deficit < _bestNet - eps) {
        continue;
      }
      final key = keyByCount
          ? '${state.total}|${state.percentageKey}'
          : state.percentageKey;
      groups.putIfAbsent(key, () => []).add(state);
    }
    final kept = <_State>[];
    for (final group in groups.values) {
      // A tiny per-transaction penalty keeps, among equal fees, the vectors
      // with fewer transactions (third optimization criterion).
      group.sort((a, b) {
        var c = (a.fees + a.total * 1e-6).compareTo(b.fees + b.total * 1e-6);
        if (c != 0) return c;
        c = a.mandatory.compareTo(b.mandatory);
        if (c != 0) return c;
        c = b.maxCost.compareTo(a.maxCost);
        return c != 0 ? c : a.total.compareTo(b.total);
      });
      // Staircase of the kept vectors: mandatory and maxCost both increasing.
      final stairLow = <double>[];
      final stairHigh = <double>[];
      for (final state in group) {
        var lo = 0;
        var hi = stairLow.length;
        while (lo < hi) {
          final mid = (lo + hi) >> 1;
          if (stairLow[mid] <= state.mandatory + eps) {
            lo = mid + 1;
          } else {
            hi = mid;
          }
        }
        if (lo > 0 && stairHigh[lo - 1] >= state.maxCost - eps) continue;
        kept.add(state);
        var end = lo;
        while (end < stairLow.length && stairHigh[end] <= state.maxCost + eps) {
          end++;
        }
        stairLow.replaceRange(lo, end, [state.mandatory]);
        stairHigh.replaceRange(lo, end, [state.maxCost]);
      }
    }
    return kept;
  }

  /// Leaf with one reference tier [r]. When [exactCount] is given, the tier
  /// must contain exactly that many transactions; otherwise its count is
  /// optimized.
  void _leafSingle(
    int r,
    double mandatory,
    double maxCostSum,
    int? exactCount,
  ) {
    if (exactCount != null) {
      if (exactCount < 0) return;
      if (mandatory + exactCount * los[r] > budget + eps) return;
      counts[r] = exactCount;
      _offerCurrent();
      counts[r] = 0;
      return;
    }
    final hi = _floorClamp((budget + eps - mandatory) / los[r], 0, 1 << 52);
    final guess = _floorClamp((budget - maxCostSum) / his[r], 0, hi);
    final best = _argmaxConcave(0, hi, guess, (t) {
      counts[r] = t;
      return _evaluate(counts, continuous: true);
    });
    if (step > 0) {
      _scanStepped(0, hi, best, (t) => counts[r] = t);
    } else {
      for (var t = math.max(0, best - 1); t <= math.min(hi, best + 1); t++) {
        counts[r] = t;
        _offerCurrent();
      }
    }
    counts[r] = 0;
  }

  /// Offers the stepped plans around [peak], the continuous optimum of a
  /// concave count search on `[lo, hi]` ([apply] sets the count `t`).
  ///
  /// The continuous value bounds the stepped value and decreases away from
  /// the peak, so each direction stops as soon as it cannot beat the best
  /// plan. A safety limit marks the result as not proven optimal.
  void _scanStepped(int lo, int hi, int peak, void Function(int t) apply) {
    const maxScan = 512;
    apply(peak);
    _offerCurrent();
    for (final direction in const [-1, 1]) {
      for (var i = 1; ; i++) {
        final t = peak + direction * i;
        if (t < lo || t > hi || _stop) break;
        apply(t);
        if (_bestCounts != null &&
            _evaluate(counts, continuous: true) <= _bestNet + eps) {
          break;
        }
        if (i > maxScan) {
          _truncated = true;
          break;
        }
        _offerCurrent();
      }
    }
  }

  /// Exact closed form of [_leafSingle] (unconstrained count) when every tier
  /// has a fixed fee: with `t` reference transactions the plan is worth
  /// `min(B - F - t * fee, H - F + t * max)` while `L + t * minCost <= B`,
  /// which is maximal for the smallest `t` covering the budget or the one
  /// just before.
  void _leafFixed(
    int r,
    double mandatory,
    double maxCostSum,
    double fees,
    int total,
  ) {
    final feasible = _floorClamp(
      (budget + eps - mandatory) / los[r],
      0,
      1 << 52,
    );
    var covering = _ceilClamp((budget - maxCostSum - eps) / his[r], 0, 1 << 52);
    void consider(int t) {
      if (t < 0 || t > feasible || total + t == 0) return;
      final budgetBound = FeeTier.floorToStep(
        budget - fees - t * fixeds[r],
        step,
      );
      final capacityBound = maxCostSum - fees + t * maxs[r];
      final net = budgetBound < capacityBound ? budgetBound : capacityBound;
      final planFees = fees + t * fixeds[r];
      if (_isBetter(net, planFees, total + t)) {
        counts[r] = t;
        _offerCurrent();
        counts[r] = 0;
      }
    }

    if (covering > feasible) {
      consider(feasible);
    } else {
      consider(covering);
      consider(covering - 1);
    }
  }

  /// Leaf with two reference tiers sharing [total] transactions.
  void _leafPair(int a, int b, double mandatory, double maxCostSum, int total) {
    if (total < 0) return;
    // Feasible split: mandatory + t * lo_a + (total - t) * lo_b <= budget.
    final diff = los[a] - los[b];
    final rhs = budget + eps - mandatory - total * los[b];
    var lo = 0;
    var hi = total;
    if (diff.abs() <= 1e-12) {
      if (rhs < 0) return;
    } else if (diff > 0) {
      if (rhs < 0) return;
      hi = _floorClamp(rhs / diff, -1, total);
    } else {
      lo = _ceilClamp(rhs / diff, 0, total + 1);
    }
    if (lo > hi) return;
    final denominator = his[a] - his[b];
    final guess = denominator.abs() > 1e-12
        ? _floorClamp(
            (budget - maxCostSum - total * his[b]) / denominator,
            lo,
            hi,
          )
        : lo;
    void apply(int t) {
      counts[a] = t;
      counts[b] = total - t;
    }

    final best = _argmaxConcave(lo, hi, guess, (t) {
      apply(t);
      return _evaluate(counts, continuous: true);
    });
    if (step <= 0) {
      for (var t = math.max(lo, best - 1); t <= math.min(hi, best + 1); t++) {
        apply(t);
        _offerCurrent();
      }
    } else if (_allFixed(a, b)) {
      // Fixed fees: the stepped value is min(capacity, budget rounded down to
      // the step), monotone on each side of the point where the capacity
      // covers the budget, so the optimum is next to it or at a bound.
      for (final t in {lo, hi, guess, guess + 1}) {
        if (t < lo || t > hi) continue;
        apply(t);
        _offerCurrent();
      }
    } else {
      _scanStepped(lo, hi, best, apply);
    }
    counts[a] = 0;
    counts[b] = 0;
  }

  /// Whether the current count vector, with tiers [a] and [b], only uses
  /// fixed-fee tiers.
  bool _allFixed(int a, int b) {
    if (rates[a] != 0 || rates[b] != 0) return false;
    for (var i = 0; i < n; i++) {
      if (counts[i] != 0 && rates[i] != 0) return false;
    }
    return true;
  }

  /// First maximizer of a concave function on `[lo, hi]`, starting the search
  /// from [guess] (galloping then binary search).
  int _argmaxConcave(int lo, int hi, int guess, double Function(int) f) {
    if (hi <= lo) return lo;
    final cache = <int, double>{};
    double value(int t) => cache.putIfAbsent(t, () => f(t));
    // Monotone predicate: false before the maximum, true from it.
    bool reached(int t) => t >= hi || value(t + 1) - value(t) <= eps;

    var g = guess < lo ? lo : (guess > hi ? hi : guess);
    int left; // reached(left) == false, or lo - 1
    int right; // reached(right) == true
    if (reached(g)) {
      right = g;
      var step = 1;
      while (true) {
        final probe = right - step;
        if (probe < lo) {
          left = lo - 1;
          break;
        }
        if (reached(probe)) {
          right = probe;
          step *= 2;
        } else {
          left = probe;
          break;
        }
      }
    } else {
      left = g;
      var step = 1;
      while (true) {
        final probe = left + step;
        if (probe >= hi) {
          right = hi;
          break;
        }
        if (reached(probe)) {
          right = probe;
          break;
        }
        left = probe;
        step *= 2;
      }
    }
    while (right - left > 1) {
      final mid = left + (right - left) ~/ 2;
      if (reached(mid)) {
        right = mid;
      } else {
        left = mid;
      }
    }
    return right;
  }

  // ---------------------------------------------------------------------------
  // Concave envelope of the value of a single transaction
  // ---------------------------------------------------------------------------

  /// Best net amount of one transaction costing at most [cost].
  double _singleValue(double cost) {
    var best = double.negativeInfinity;
    for (var i = 0; i < n; i++) {
      if (los[i] > cost + eps) continue;
      final spent = cost < his[i] ? cost : his[i];
      final net = tiers[i].netForCost(spent);
      if (net > best) best = net;
    }
    return best;
  }

  List<_Point> _buildHull() {
    final xs = <double>{...los, ...his}.toList()..sort();
    final points = [for (final x in xs) _Point(x, _singleValue(x))];
    final hull = <_Point>[];
    for (final p in points) {
      while (hull.length >= 2) {
        final a = hull[hull.length - 2];
        final b = hull[hull.length - 1];
        final cross = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
        if (cross >= 0) {
          hull.removeLast();
        } else {
          break;
        }
      }
      hull.add(p);
    }
    return hull;
  }

  /// Tangent line of the concave envelope at average cost [x], or `null` if
  /// no transaction can cost that little.
  _Line? _envelopeAt(double x) {
    final hull = _hull ??= _buildHull();
    if (x < hull.first.x - eps) return null;
    if (hull.length == 1 || x >= hull.last.x) return _Line(hull.last.y, 0);
    for (var i = 0; i + 1 < hull.length; i++) {
      final a = hull[i];
      final b = hull[i + 1];
      if (x <= b.x) {
        final beta = (b.y - a.y) / (b.x - a.x);
        return _Line(a.y - beta * a.x, beta);
      }
    }
    return _Line(hull.last.y, 0);
  }

  // ---------------------------------------------------------------------------
  // Result
  // ---------------------------------------------------------------------------

  FeeOptimizerResult _buildResult() {
    final c = _bestCounts!;
    var extra = budget;
    for (var i = 0; i < n; i++) {
      extra -= c[i] * los[i];
    }
    if (extra < 0) extra = 0;

    final groups = <String, FeeOptimizerDetail>{};
    void add(int tier, double amount, int count) {
      if (count <= 0) return;
      final value = _snap(amount);
      final fee = _snap(tiers[tier].feeFor(value));
      final key = '$value|$fee';
      final existing = groups[key];
      groups[key] = FeeOptimizerDetail(
        amount: value,
        fee: fee,
        count: (existing?.count ?? 0) + count,
      );
    }

    for (final i in fillOrder) {
      final k = c[i];
      if (k == 0) continue;
      final unit = 1 + rates[i];
      final width = maxs[i] - mins[i];
      var take = FeeTier.floorToStep(extra / unit, step);
      if (take > k * width) take = k * width;
      extra -= take * unit;
      if (extra < 0) extra = 0;

      if (width <= 0) {
        add(i, mins[i], k);
        continue;
      }
      var full = (take / width + 1e-9).floor();
      if (full > k) full = k;
      add(i, maxs[i], full);
      if (full < k) {
        var rest = take - full * width;
        if (rest < 0) rest = 0;
        add(i, mins[i] + rest, 1);
        add(i, mins[i], k - full - 1);
      }
    }

    final details = groups.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return FeeOptimizerResult.fromDetails(
      budget: budget,
      details: details,
      isProvenOptimal: !_truncated,
    );
  }

  /// Removes floating point noise around integers (amounts are usually whole
  /// numbers of Ariary).
  static double _snap(double value) {
    final rounded = value.roundToDouble();
    return (value - rounded).abs() <= 1e-7 * math.max(1.0, value.abs())
        ? rounded
        : value;
  }

  static int _floorClamp(double x, int lo, int hi) {
    if (x.isNaN || x <= lo) return lo;
    if (x >= hi) return hi;
    return x.floor();
  }

  static int _ceilClamp(double x, int lo, int hi) {
    if (x.isNaN || x <= lo) return lo;
    if (x >= hi) return hi;
    return x.ceil();
  }
}
