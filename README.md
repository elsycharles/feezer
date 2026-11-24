# Feezer (fee_minimizer)

Flutter app that tells you how to split a money transfer (mobile money, bank…)
into transactions so that the recipient gets **as much as possible** for a
given budget, while paying **the least fees**.

## Architecture

```
lib/
  core/optimizer/   Pure Dart, no Flutter: the optimization engine
    fee_tier.dart          normalized fee interval
    fee_optimizer.dart     exact optimizer
    naive_strategy.dart    "by hand" strategies (comparison baseline)
    fee_comparison.dart    optimized plan vs. baselines
  data/             SQLite access (sqflite)
    app_database.dart      schema, migrations, seeding
    *_repository.dart      providers, fee intervals, currencies
  model/            immutable models
  provider/         app state (ChangeNotifier): currency, locale, theme
  screen/ widget/   UI
  util/             formatting, CSV import/export, navigation, theme
```

All amounts are **stored in Ariary** (base currency). The selected currency is
only used to convert amounts on input and display; percentage fees are never
converted.

## Optimization algorithm

Problem: with a budget `B` (fees included) and tiers `[min, max]` with a fixed
or percentage fee, choose transactions maximizing the amount received, then
minimizing fees, then the number of transactions, optionally with a minimum /
maximum number of transactions.

1. For a given number of transactions per tier, the best amounts are a linear
   program solved in closed form (start every transaction at its tier minimum,
   then pour the remaining budget where it costs least).
2. Count vectors are enumerated tier by tier, with two exact pruning rules:
   * a line `net <= alpha + beta * cost` above every possible transaction
     bounds any plan; each transaction loses a *deficit* against it, so
     branches that already lose more than the best plan's margin are cut;
   * partial vectors dominated by another one (higher minimum cost, lower
     maximum cost, higher fees) are dropped (Pareto front).
3. The count of the most efficient tier is not enumerated: the objective is
   concave in it, so it is found by galloping/binary search (or in closed form
   when every fee is fixed).
4. With transaction constraints, exact counts `K` are solved using the concave
   envelope of a single transaction's value, only while the bound can still
   beat the best plan.

The result is **proven optimal**. A safety limit (time / number of evaluated
vectors) keeps extreme inputs responsive; the plan is then still valid and
flagged as not proven optimal. The optimizer runs in a background isolate.

## Development

```sh
flutter pub get
flutter analyze
flutter test
```

Tests include an exact brute-force reference (dynamic programming over integer
costs) used to verify the optimizer on thousands of random fee tables and
budgets, database migration tests (`sqflite_common_ffi`) and a UI smoke test.

Localizations live in `lib/l10n/*.arb` (English, French, Malagasy); regenerate
with `flutter gen-l10n`.
