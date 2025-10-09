import '../util/database_util.dart';
import '../util/constant_util.dart';
import 'fee_interval_model.dart';

class Provider {
  Provider({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'business',
    DateTime? creationDatetime,
  }) : creationDatetime = creationDatetime ?? DateTime.now();

  final int id;
  final String name;
  final String description;
  final String iconName;
  final DateTime creationDatetime;

  // Conversion pour la base de données
  Map<String, dynamic> toMap() {
    return {
      ConstantUtil.columnId: id,
      ConstantUtil.columnName: name,
      ConstantUtil.columnDescription: description,
      ConstantUtil.columnIconName: iconName,
      ConstantUtil.columnCreationDatetime: creationDatetime.millisecondsSinceEpoch,
    };
  }

  factory Provider.fromMap(Map<String, dynamic> map) {
    return Provider(
      id: map[ConstantUtil.columnId],
      name: map[ConstantUtil.columnName],
      description: map[ConstantUtil.columnDescription],
      iconName: map[ConstantUtil.columnIconName] ?? 'business',
      creationDatetime: DateTime.fromMillisecondsSinceEpoch(
        map[ConstantUtil.columnCreationDatetime],
      ),
    );
  }

  // Méthodes de base de données
  Future<int> save() async {
    final dbUtil = DatabaseUtil();
    return await dbUtil.insert(ConstantUtil.tableProviders, toMap());
  }

  static Future<List<Provider>> getAll() async {
    final dbUtil = DatabaseUtil();
    final maps = await dbUtil.query(ConstantUtil.tableProviders);
    return maps.map((map) => Provider.fromMap(map)).toList();
  }

  Future<List<FeeInterval>> getFeeIntervals() async {
    return await FeeInterval.getByProviderId(id);
  }

  @override
  String toString() {
    return 'Provider(id: $id, name: $name)';
  }
}