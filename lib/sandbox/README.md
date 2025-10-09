# Withdrawal Optimizer

A Dart utility to optimize bank withdrawals and minimize fees.

## Description

This utility implements optimization algorithms to calculate the best withdrawal strategy based on:
- Total amount to withdraw
- Available withdrawal options (min, max, fees)
- Constraints on the number of withdrawals (optional)
- Desired precision

## Project Architecture

Simple and clear structure organized by component type:

```
lib/sandbox/
├── model/                          # Data model (one per file)
│   ├── withdrawal_model.dart        # Withdrawal model
│   ├── withdrawal_option_model.dart # Normalized option model
│   ├── withdrawal_detail_model.dart # Withdrawal detail
│   └── optimal_withdrawal_result_model.dart # Optimization result
├── util/                          # Utilities
│   └── withdrawal_util.dart        # Optimization logic
├── main.dart                       # Example tests
├── pubspec.yaml                    # Dart configuration
└── README.md                       # Documentation
```

## Data Model

### Withdrawal (`withdrawal_model.dart`)
Represents a raw withdrawal option with optional values.
```dart
const Withdrawal(min: 100, max: 5000, fee: 25)
```

### WithdrawalOption (`withdrawal_option_model.dart`)
Normalized version of a withdrawal option with required values.
```dart
const WithdrawalOption(min: 100.0, max: 5000.0, fee: 25.0)
```

### WithdrawalDetail (`withdrawal_detail_model.dart`)
Details a withdrawal in the optimal solution.
```dart
WithdrawalDetail(amount: 5000, fee: 25, netAmount: 5000, count: 2)
```

### OptimalWithdrawalResult (`optimal_withdrawal_result_model.dart`)
Complete optimization result.

## Usage

### 🚀 Simple Usage

```dart
import 'util/withdrawal_util.dart';
import 'model/withdrawal_model.dart';

void main() {
  // Available withdrawal options
  final options = [
    const Withdrawal(min: 100, max: 5000, fee: 25),
    const Withdrawal(min: 1000, max: 10000, fee: 50),
    const Withdrawal(min: 2000, max: 20000, fee: 75),
  ];

  // Calculate optimal strategy
  final result = WithdrawalUtil.calculateOptimalWithdrawals(
    15000, // Total amount to withdraw
    options,
  );

  print('Net amount: ${result.netAmount}€');
  print('Total fees: ${result.totalFees}€');
  print('Number of withdrawals: ${result.totalWithdrawals}');
}
```

### 📊 With Constraints

```dart
// Calculation with constraints on number of withdrawals
final result = WithdrawalUtil.calculateOptimalWithdrawals(
  25000,
  options,
  maxWithdrawals: 3,     // Maximum 3 withdrawals
  minWithdrawals: 2,     // Minimum 2 withdrawals
  precision: 50.0,       // Amounts multiples of 50€
);

// Search for best option for an amount
final normalizedOptions = WithdrawalUtil.normalizeOptions(options);
final bestOption = WithdrawalUtil.findBestOption(3500, normalizedOptions);
```

## 🎯 Advantages

- **Simplicity**: Clear and clean structure, without unnecessary complexity
- **Modularity**: Each file has a precise responsibility  
- **Maintainability**: Easy to understand and modify code
- **Performance**: Optimized algorithms without cache or overhead
- **Testability**: Independent components easily testable

## Algorithms

The system uses several optimization algorithms:

1. **Optimized greedy algorithm**: Always selects the best possible withdrawal
2. **Repeated withdrawals**: Tests combinations of identical withdrawals
3. **Optimal distribution**: To respect an exact number of withdrawals
4. **Min/max constraints**: Adaptations to respect limits

### Thresholds

- **Amounts ≤ 500,000**: Uses the first two algorithms and selects the best
- **Amounts > 500,000**: Uses only the greedy algorithm for performance

## Execution

```bash
# Navigate to the directory
cd lib/sandbox

# Run the tests
dart main.dart
```

## Features

### ✅ Implemented
- Optimization without constraints
- Constraints on number of withdrawals (min/max)
- Precision support
- Error handling
- Multiple optimization algorithms
- Complete tests

### 🔄 Possible improvements
- Result caching
- Variable fee support
- Parallel optimization
- Graphical interface
- Result export

## Tests

The `main.dart` file contains 9 test series:

1. Simple withdrawal without constraints
2. Withdrawal with maximum constraint
3. Withdrawal with minimum constraint
4. Withdrawal with min and max constraints
5. Withdrawal with custom precision
6. Test with large amount
7. Test of `findBestOption` function
8. Error validation tests
9. Performance tests

## Performance

The optimizer is designed to be efficient:
- O(n²) algorithms in the worst case
- Internal calculation cache
- Adaptive thresholds based on amount
- Iteration limitation for large volumes

## License

This project is a demonstration utility. Free to use and modify.