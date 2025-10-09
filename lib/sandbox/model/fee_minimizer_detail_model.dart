import '../util/database_util.dart';
import '../util/constant_util.dart';

class FeeOptimizerDetail {
  FeeOptimizerDetail({
    this.id,
    this.resultId,
    required this.amount,
    required this.fee,
    required this.count,
  });

  final int? id;
  final int? resultId;
  final double amount;
  final double fee;
  final int count;

  // Calculs dérivés
  double get totalGross => amount * count;
  double get totalFees => fee * count;
  double get totalNet => amount * count;

  // Conversion pour la base de données
  Map<String, dynamic> toMap() {
    return {
      ConstantUtil.columnId: id,
      ConstantUtil.columnResultId: resultId,
      ConstantUtil.columnAmount: amount,
      ConstantUtil.columnFee: fee,
      ConstantUtil.columnCount: count,
    };
  }

  factory FeeOptimizerDetail.fromMap(Map<String, dynamic> map) {
    return FeeOptimizerDetail(
      id: map[ConstantUtil.columnId],
      resultId: map[ConstantUtil.columnResultId],
      amount: map[ConstantUtil.columnAmount],
      fee: map[ConstantUtil.columnFee],
      count: map[ConstantUtil.columnCount],
    );
  }

  // Sauvegarde
  Future<int> save() async {
    final dbUtil = DatabaseUtil();
    return await dbUtil.insert(ConstantUtil.tableOptimizationDetails, toMap());
  }

  @override
  String toString() {
    return '$count x ${amount.toStringAsFixed(2)}€ (fee: ${fee.toStringAsFixed(2)}€)';
  }
}