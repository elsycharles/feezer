import '../util/database_util.dart';
import '../util/constant_util.dart';
import 'fee_minimizer_detail_model.dart';

class FeeOptimizerResult {
  FeeOptimizerResult({
    this.id,
    required this.totalAmount,
    required this.netAmount,
    required this.totalFees,
    required this.remaining,
    required this.details,
    DateTime? creationDatetime,
  }) : creationDatetime = creationDatetime ?? DateTime.now() {
    efficiency = netAmount / totalAmount;
  }

  final int? id;
  final double totalAmount;
  final double netAmount;
  final double totalFees;
  final double remaining;
  final List<FeeOptimizerDetail> details;
  final DateTime creationDatetime;
  late final double efficiency;

  // Calculs dérivés
  int get totalOperations => details.fold(0, (sum, detail) => sum + detail.count);
  bool get isValid => netAmount > 0 && totalOperations > 0;

  // Conversion pour la base de données
  Map<String, dynamic> toMap() {
    return {
      ConstantUtil.columnId: id,
      ConstantUtil.columnTotalAmount: totalAmount,
      ConstantUtil.columnNetAmount: netAmount,
      ConstantUtil.columnTotalFees: totalFees,
      ConstantUtil.columnRemaining: remaining,
      ConstantUtil.columnEfficiency: efficiency,
      ConstantUtil.columnCreationDatetime: creationDatetime.millisecondsSinceEpoch,
    };
  }

  factory FeeOptimizerResult.fromMap(Map<String, dynamic> map) {
    return FeeOptimizerResult(
      id: map[ConstantUtil.columnId],
      totalAmount: map[ConstantUtil.columnTotalAmount],
      netAmount: map[ConstantUtil.columnNetAmount],
      totalFees: map[ConstantUtil.columnTotalFees],
      remaining: map[ConstantUtil.columnRemaining],
      details: [], // Chargé séparément
    );
  }

  // Sauvegarde complète avec détails
  Future<int> save() async {
    final dbUtil = DatabaseUtil();
    final resultId = await dbUtil.insert(
      ConstantUtil.tableOptimizationResults, 
      toMap(),
    );

    // Sauvegarde des détails
    for (final detail in details) {
      final detailMap = detail.toMap();
      detailMap[ConstantUtil.columnResultId] = resultId;
      await dbUtil.insert(ConstantUtil.tableOptimizationDetails, detailMap);
    }

    return resultId;
  }

  // Chargement avec détails
  static Future<FeeOptimizerResult?> getById(int id) async {
    final dbUtil = DatabaseUtil();
    
    // Charger le résultat principal
    final results = await dbUtil.query(
      ConstantUtil.tableOptimizationResults,
      where: '${ConstantUtil.columnId} = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    
    final result = FeeOptimizerResult.fromMap(results.first);
    
    // Charger les détails
    final detailMaps = await dbUtil.query(
      ConstantUtil.tableOptimizationDetails,
      where: '${ConstantUtil.columnResultId} = ?',
      whereArgs: [id],
    );

    result.details.addAll(
      detailMaps.map((map) => FeeOptimizerDetail.fromMap(map)),
    );

    return result;
  }

  @override
  String toString() {
    return 'FeeOptimizerResult: ${(efficiency * 100).toStringAsFixed(1)}% efficiency, '
           '$netAmount€ net, $totalFees€ fees, $totalOperations operations';
  }
}