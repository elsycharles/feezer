/// Clean Provider model with validation and utility methods
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

  /// Checks if provider data is valid
  bool get isValid =>
      id.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      description.trim().isNotEmpty;

  /// Gets display name (truncated if too long)
  String get displayName =>
      name.length > 25 ? '${name.substring(0, 25)}...' : name;

  /// Gets short description
  String get shortDescription => description.length > 50
      ? '${description.substring(0, 50)}...'
      : description;

  /// Checks if provider was created recently (within 7 days)
  bool get isRecent => DateTime.now().difference(creationDatetime).inDays <= 7;

  /// Gets formatted creation date
  String get formattedCreationDate {
    final now = DateTime.now();
    final difference = now.difference(creationDatetime);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${creationDatetime.day}/${creationDatetime.month}/${creationDatetime.year}';
  }

  /// Creates a copy with updated values
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
      other is Provider && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Provider(id: $id, name: $name)';
}
