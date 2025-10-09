import 'model/withdrawal_model.dart';
import 'model/withdrawal_option_model.dart';
import 'model/optimal_withdrawal_result_model.dart';
import 'util/withdrawal_util.dart';

void main() {
  print('=== Withdrawal optimizer test ===\n');

  // Creating example withdrawal options
  final options = [
    const Withdrawal(min: 100, max: 5000, fee: 25),
    const Withdrawal(min: 1000, max: 10000, fee: 50),
    const Withdrawal(min: 2000, max: 20000, fee: 75),
    const Withdrawal(min: 5000, max: 50000, fee: 100),
    const Withdrawal(min: 10000, max: 100000, fee: 150),
  ];

  print('Available withdrawal options:');
  for (int i = 0; i < options.length; i++) {
    print('  ${i + 1}. ${options[i]}');
  }
  print('');

  // Test 1: Simple withdrawal without constraints
  print('--- Test 1: 15000€ withdrawal without constraints ---');
  try {
    final result1 = WithdrawalUtil.calculateOptimalWithdrawals(
      15000,
      options,
    );
    print(result1);
  } catch (e) {
    print('Error: $e');
  }

  // Test 2: Withdrawal with maximum constraint
  print('--- Test 2: 25000€ withdrawal with max 3 withdrawals ---');
  try {
    final result2 = WithdrawalUtil.calculateOptimalWithdrawals(
      25000,
      options,
      maxWithdrawals: 3,
    );
    print(result2);
  } catch (e) {
    print('Error: $e');
  }

  // Test 3: Withdrawal with minimum constraint
  print('--- Test 3: 8000€ withdrawal with min 5 withdrawals ---');
  try {
    final result3 = WithdrawalUtil.calculateOptimalWithdrawals(
      8000,
      options,
      minWithdrawals: 5,
    );
    print(result3);
  } catch (e) {
    print('Error: $e');
  }

  // Test 4: Withdrawal with min and max constraints
  print('--- Test 4: 30000€ withdrawal with 2-4 withdrawals ---');
  try {
    final result4 = WithdrawalUtil.calculateOptimalWithdrawals(
      30000,
      options,
      minWithdrawals: 2,
      maxWithdrawals: 4,
    );
    print(result4);
  } catch (e) {
    print('Error: $e');
  }

  // Test 5: Withdrawal with precision
  print('--- Test 5: 12500€ withdrawal with precision 50 ---');
  try {
    final result5 = WithdrawalUtil.calculateOptimalWithdrawals(
      12500,
      options,
      precision: 50,
    );
    print(result5);
  } catch (e) {
    print('Error: $e');
  }

  // Test 6: Large amount
  print('--- Test 6: 750000€ withdrawal (large amount) ---');
  try {
    final result6 = WithdrawalUtil.calculateOptimalWithdrawals(
      750000,
      options,
    );
    print(result6);
  } catch (e) {
    print('Error: $e');
  }

  // Test 7: Test findBestOption
  print('--- Test 7: Search for best option for 3500€ ---');
  final normalizedOptions = options
      .where((o) => o.min != null && o.max != null && o.fee != null)
      .map((o) => WithdrawalOption(min: o.min!, max: o.max!, fee: o.fee!))
      .toList();

  final bestOption = WithdrawalUtil.findBestOption(3500, normalizedOptions);
  if (bestOption != null) {
    print('Best option: $bestOption');
    final efficiency = (3500 - bestOption.fee) / bestOption.fee;
    print('Efficiency for 3500€: ${efficiency.toStringAsFixed(2)}');
  } else {
    print('No option found for 3500€');
  }
  print('');

  // Test 8: Error cases
  print('--- Test 8: Error validation tests ---');
  
  // Negative amount
  try {
    WithdrawalUtil.calculateOptimalWithdrawals(-1000, options);
  } catch (e) {
    print('✓ Expected error for negative amount: $e');
  }

  // Empty options
  try {
    WithdrawalUtil.calculateOptimalWithdrawals(1000, []);
  } catch (e) {
    print('✓ Expected error for empty options: $e');
  }

  // Invalid constraints
  try {
    WithdrawalUtil.calculateOptimalWithdrawals(
      1000, 
      options, 
      minWithdrawals: 5, 
      maxWithdrawals: 3
    );
  } catch (e) {
    print('✓ Expected error for invalid constraints: $e');
  }

  print('');

  // Test 9: Performance comparison
  print('--- Test 9: Performance comparison ---');
  final stopwatch = Stopwatch();
  
  stopwatch.start();
  for (int i = 0; i < 100; i++) {
    WithdrawalUtil.calculateOptimalWithdrawals(15000, options);
  }
  stopwatch.stop();
  
  print('Time for 100 calculations of 15000€: ${stopwatch.elapsedMilliseconds}ms');
  print('Average per calculation: ${stopwatch.elapsedMilliseconds / 100}ms');

  print('\n=== All tests completed ===');
}

/// Utility function to display a compact summary
void printResultSummary(OptimalWithdrawalResult result) {
  print('Summary: ${result.netAmount.toStringAsFixed(2)}€ net, '
      '${result.totalFees.toStringAsFixed(2)}€ fees, '
      '${result.totalWithdrawals} withdrawals, '
      '${(result.efficiency * 100).toStringAsFixed(1)}% efficiency');
}