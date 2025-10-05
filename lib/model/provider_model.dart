/// Clean Provider model
class Provider {
  Provider({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'business',
    DateTime? creationDatetime,
  }) : creationDatetime = creationDatetime ?? DateTime.now();

  final String id;
  final String name;
  final String description;
  final String iconName;
  final DateTime creationDatetime;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Provider &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => Object.hash(id, name, description);

  @override
  String toString() => 'Provider(id: $id, name: $name)';
}
