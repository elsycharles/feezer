import '../util/database_util.dart';
import '../util/constant_util.dart';

class FeeInterval {
  FeeInterval({
    this.id,
    this.providerId,
    this.minAmount,
    this.maxAmount,
    this.fee,
    DateTime? creationDateTime,
  }) : creationDatetime = creationDateTime ?? DateTime.now();

  final int? id;
  final int? providerId;
  final double? minAmount;
  final double? maxAmount;
  final double? fee;
  final DateTime creationDatetime;

  // Conversion pour la base de données
  Map<String, dynamic> toMap() {
    return {
      ConstantUtil.columnId: id,
      ConstantUtil.columnProviderId: providerId,
      ConstantUtil.columnMinAmount: minAmount,
      ConstantUtil.columnMaxAmount: maxAmount,
      ConstantUtil.columnFee: fee,
      ConstantUtil.columnCreationDatetime: creationDatetime.millisecondsSinceEpoch,
    };
  }

  factory FeeInterval.fromMap(Map<String, dynamic> map) {
    return FeeInterval(
      id: map[ConstantUtil.columnId],
      providerId: map[ConstantUtil.columnProviderId],
      minAmount: map[ConstantUtil.columnMinAmount],
      maxAmount: map[ConstantUtil.columnMaxAmount],
      fee: map[ConstantUtil.columnFee],
      creationDateTime: DateTime.fromMillisecondsSinceEpoch(
        map[ConstantUtil.columnCreationDatetime],
      ),
    );
  }

  // Méthodes de base de données
  Future<int> save() async {
    final dbUtil = DatabaseUtil();
    return await dbUtil.insert(ConstantUtil.tableFeeIntervals, toMap());
  }

  static Future<List<FeeInterval>> getAll() async {
    final dbUtil = DatabaseUtil();
    final maps = await dbUtil.query(ConstantUtil.tableFeeIntervals);
    return maps.map((map) => FeeInterval.fromMap(map)).toList();
  }

  static Future<List<FeeInterval>> getByProviderId(int providerId) async {
    final dbUtil = DatabaseUtil();
    final maps = await dbUtil.query(
      ConstantUtil.tableFeeIntervals,
      where: '${ConstantUtil.columnProviderId} = ?',
      whereArgs: [providerId],
    );
    return maps.map((map) => FeeInterval.fromMap(map)).toList();
  }

  // Validation
  bool get isValid => 
      minAmount != null && maxAmount != null && fee != null && maxAmount! > minAmount!;

  @override
  String toString() {
    return 'FeeInterval(min: $minAmount, max: $maxAmount, fee: $fee)';
  }
}