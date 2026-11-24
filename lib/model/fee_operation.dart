/// Kind of transaction a fee grid applies to. [key] is the identifier used in
/// the database, CSV files and the published fee tables.
enum FeeOperation {
  withdrawal('withdrawal'),
  transferSame('transfer_same'),
  transferSameApp('transfer_same_app'),
  transferOther('transfer_other'),
  transferMicrofinance('transfer_microfinance'),
  transferUnregistered('transfer_unregistered');

  const FeeOperation(this.key);

  final String key;

  /// Cash withdrawal: the fee is paid on top of the amount withdrawn.
  bool get isWithdrawal => this == withdrawal;

  static FeeOperation? fromKey(String? key) {
    if (key == null) return null;
    final normalized = key.trim().toLowerCase();
    for (final operation in values) {
      if (operation.key == normalized) return operation;
    }
    return null;
  }
}
