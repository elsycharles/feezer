import 'fee_minimizer_detail_model.dart';

/// Outcome of an optimization request.
enum OptimizationStatus {
  /// A valid plan was found.
  success,

  /// The provider has no usable fee interval.
  noFeeIntervals,

  /// The budget is too small to perform even one transaction.
  budgetTooSmall,

  /// No plan satisfies the requested minimum/maximum number of transactions.
  constraintsUnsatisfiable,
}

/// Result of a fee optimization (or of a baseline strategy used for
/// comparison).
///
class FeeOptimizerResult {
  const FeeOptimizerResult({
    required this.budget,
    required this.netAmount,
    required this.totalFees,
    required this.details,
    this.status = OptimizationStatus.success,
    this.isProvenOptimal = true,
  });

  /// Builds a result from a list of transaction groups, computing every total.
  factory FeeOptimizerResult.fromDetails({
    required double budget,
    required List<FeeOptimizerDetail> details,
    OptimizationStatus status = OptimizationStatus.success,
    bool isProvenOptimal = true,
  }) {
    var net = 0.0;
    var fees = 0.0;
    for (final detail in details) {
      net += detail.totalNet;
      fees += detail.totalFees;
    }
    return FeeOptimizerResult(
      budget: budget,
      netAmount: net,
      totalFees: fees,
      details: List.unmodifiable(details),
      status: status,
      isProvenOptimal: isProvenOptimal,
    );
  }

  /// Empty result (no transaction) with the given [status].
  factory FeeOptimizerResult.empty(double budget, OptimizationStatus status) =>
      FeeOptimizerResult(
        budget: budget,
        netAmount: 0,
        totalFees: 0,
        details: const [],
        status: status,
      );

  /// Amount the user is willing to spend (fees included).
  final double budget;

  /// Total amount actually received by the recipient(s).
  final double netAmount;

  /// Total fees paid.
  final double totalFees;

  /// Transactions grouped by identical amount.
  final List<FeeOptimizerDetail> details;

  final OptimizationStatus status;

  /// `false` when the search was truncated by its safety limit: the plan is
  /// valid and very good, but optimality could not be proven.
  final bool isProvenOptimal;

  bool get isSuccess =>
      status == OptimizationStatus.success && details.isNotEmpty;

  /// Money that leaves the user's account (net + fees).
  double get totalSpent => netAmount + totalFees;

  /// Part of the budget that is not spent.
  double get remaining {
    final value = budget - totalSpent;
    // Absorb floating point noise.
    return value.abs() <= 1e-9 * (budget.abs() + 1) ? 0 : value;
  }

  /// Number of transactions to perform.
  int get totalOperations =>
      details.fold(0, (sum, detail) => sum + detail.count);

  /// Share of the spent money that reaches the recipient, in percent.
  double get efficiency => totalSpent > 0 ? netAmount / totalSpent * 100 : 0;

  @override
  String toString() =>
      'FeeOptimizerResult(status: $status, budget: $budget, net: $netAmount, '
      'fees: $totalFees, remaining: $remaining, operations: $totalOperations)';
}
