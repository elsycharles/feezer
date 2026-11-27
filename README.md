# Feezer

Flutter app that tells you how to split a mobile money **withdrawal or
transfer** into transactions so that you get **as much as possible** from the
money you have, while paying **the least fees**.

Choose the operator (MVola, Orange Money, Airtel Money… or your own grids),
then the operation (withdrawal, transfer, to another operator…), enter the
amount available, and Feezer shows the cheapest plan next to the usual way of
doing it.

## Architecture

```
lib/
  core/optimizer/   Pure Dart, no Flutter: the optimization engine
    fee_tier.dart          normalized fee interval
    fee_optimizer.dart     exact optimizer
    naive_strategy.dart    "usual way" strategies (comparison baseline)
    fee_comparison.dart    optimized plan vs. baselines
  data/             SQLite access (sqflite) and official fee grids
    app_database.dart      schema, migrations, change notifications
    *_repository.dart      grids (operator + operation) and their tiers
    fee_table_service.dart download, compare and apply the official grids
    default_data.dart      grids bundled with the app (first launch, upgrades)
  model/            immutable models (grid, tier, operation, results)
  provider/         app state (ChangeNotifier): locale, theme
  theme/            design tokens: colors, typography, spacing, motion
  screen/           launch splash, onboarding, home (tabs), optimize,
                    operators, settings
  widget/           shared components (buttons, cards, pills, skeletons…),
                    the animated logo
  util/             money and date labels, CSV import/export, navigation
tool/
  brand/            the logo, drawn from exact geometry, and launcher icons
  screenshots_test.dart   renders every screen to build/screenshots/
```

Amounts are shown without currency, formatted as money (`10 050`, `1 234,50`).

## Official fees

A grid is an operator and an operation. The official grids are read every day
from the operators' websites by the public repository
[elsycharles/feezer-fee-tables](https://github.com/elsycharles/feezer-fee-tables),
which publishes them as `fees.json`:

| Operator | Source |
| --- | --- |
| MVola | mvola.mg rates page (HTML) |
| Orange Money | orange.mg rates (PDF) |
| Airtel Money | copied by hand: airtel.mg cannot be read automatically |

* The app ships a copy (`assets/data/fees.json`), installed on first launch so
  it works offline. Grids seeded by the 1.x versions are replaced only if the
  user never changed them.
* **Update** (Operators tab or Settings) downloads `fees.json`, lists the grids
  that are new or changed, and applies them after confirmation. Other grids
  are never touched.
* A downloaded grid edited in the app is marked *edited by you*; the next
  update shows it as changed and restores the official tiers if confirmed.

## Design

Flat surfaces, no gradients, Inter, one blue taken from the logo. Every
tappable surface shrinks slightly when pressed and shows a calm ripple and a
hover tint; tabs fade through, results count up and appear section by
section, sheets and expanding cards animate their size. Texts are kept to
one line. At launch the logo assembles itself (the two bars slide in, the leg
unfolds) while the app reads its preferences and fee grids, then fades into
the first screen; the system launch screen is plain so the animation starts
from an empty screen, and reduced motion skips it. Tokens live in `lib/theme/app_theme.dart`, components in
`lib/widget/common.dart`.

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

5. With an amount step (withdrawals default to multiples of 100, since cash
   points hand out notes; configurable per withdrawal / transfer), tier bounds
   are rounded inwards to the step and the budget is poured by whole steps.
   The continuous value still bounds every plan, so the search stays exact; it
   is checked against a stepped brute-force reference.

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
budgets, database tests (`sqflite_common_ffi`: migrations, seeding, official
grid updates, CSV) and a UI flow test in both themes.

Localizations live in `lib/l10n/*.arb` (English, French, Malagasy); regenerate
with `flutter gen-l10n`.

Tools:

```sh
python3 tool/brand/make_logo.py            # logo, launcher icons, logo paths
dart run flutter_launcher_icons            # Android / iOS launcher icons
flutter test tool/screenshots_test.dart    # every screen, light and dark
flutter test tool/store_screenshots_test.dart && \
  python3 tool/store/compose_store_assets.py   # Google Play images
```

The Google Play listing (texts, icon, feature graphic, screenshots, in French
and English) is in [`fastlane/metadata/android`](fastlane/metadata/android); the
Play Console forms are answered in [`fastlane/GOOGLE_PLAY.md`](fastlane/GOOGLE_PLAY.md).
The privacy policy is [`PRIVACY.md`](PRIVACY.md).

The logo is the original artwork (`tool/brand/logo_original.png`) redrawn
from measured geometry: 60° slants, one radius for the soft corners, flat
colors. `make_logo.py` needs Pillow and NumPy; it also writes the same shapes
as Flutter paths (`lib/widget/logo_geometry.dart`) for the animated logo.

## License

Copyright (C) 2025-2026 Elsy Charles.

The source code of Feezer is free software, released under the
[GNU General Public License v3.0](LICENSE) or (at your option) any later
version: you may use, study, modify and share it, including commercially, as
long as derived works are released under the same license with their source
code and keep the copyright notices.

* The official fee grids (`assets/data/fees.json`, published by
  [feezer-fee-tables](https://github.com/elsycharles/feezer-fee-tables)) are
  licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
* The **Feezer name and logo** are not covered by these licenses: a modified
  version must use another name and logo.
* MVola, Orange Money and Airtel Money are trademarks of their respective
  owners. Feezer is not affiliated with any operator.

To report a security problem, see [SECURITY.md](SECURITY.md).
