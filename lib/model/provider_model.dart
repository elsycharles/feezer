import '../data/app_database.dart';
import '../util/constant_util.dart';

/// Financial service provider (mobile money operator, bank...).
class Provider {
  Provider({
    required this.id,
    required this.name,
    this.description = '',
    this.iconName = 'business',
    DateTime? creationDatetime,
  }) : creationDatetime = creationDatetime ?? DateTime.now();

  /// Database id (empty before insertion).
  final String id;
  final String name;
  final String description;
  final String iconName;
  final DateTime creationDatetime;

  bool get isValid => name.trim().isNotEmpty;

  Provider copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    DateTime? creationDatetime,
  }) => Provider(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    iconName: iconName ?? this.iconName,
    creationDatetime: creationDatetime ?? this.creationDatetime,
  );

  static Provider fromMap(Map<String, dynamic> map) => Provider(
    id: map[Db.id].toString(),
    name: (map[Db.name] as String?) ?? '',
    description: (map[Db.description] as String?) ?? '',
    iconName: (map[Db.iconName] as String?) ?? 'business',
    creationDatetime: ConstantUtil.parseDateTime(map[Db.creationDatetime]),
  );

  /// Database row. The id is omitted when unknown so SQLite assigns one.
  static Map<String, dynamic> toMap(Provider provider) {
    final id = int.tryParse(provider.id);
    return {
      if (id != null) Db.id: id,
      Db.name: provider.name,
      Db.description: provider.description,
      Db.iconName: provider.iconName,
      Db.creationDatetime: provider.creationDatetime.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Provider && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Provider(id: $id, name: $name)';
}
