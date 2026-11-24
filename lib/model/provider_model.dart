import '../data/app_database.dart';
import '../util/constant_util.dart';
import 'fee_operation.dart';

/// A fee grid: an operator (mobile money, bank...) and, when known, the
/// operation it applies to (withdrawal, transfer...). Several grids of the same
/// operator share the same [name].
class Provider {
  Provider({
    required this.id,
    required this.name,
    this.description = '',
    this.iconName = 'business',
    this.operation,
    this.sourceUrl,
    this.sourceType,
    this.effectiveDate,
    DateTime? creationDatetime,
  }) : creationDatetime = creationDatetime ?? DateTime.now();

  /// Database id (empty before insertion).
  final String id;

  /// Operator name, e.g. "MVola".
  final String name;
  final String description;
  final String iconName;

  /// `null` for grids created by the user without an operation.
  final FeeOperation? operation;

  /// Official page the grid was read from.
  final String? sourceUrl;

  /// [officialSource] (read from the operator's website), [manualSource]
  /// (published, typed from the operator's grid), [editedSource] (published,
  /// then changed in the app) or `null` when the grid was entered in the app.
  final String? sourceType;

  /// Date printed by the operator on its grid.
  final DateTime? effectiveDate;

  final DateTime creationDatetime;

  bool get isValid => name.trim().isNotEmpty;

  static const String officialSource = 'official';
  static const String manualSource = 'manual';
  static const String editedSource = 'edited';

  bool get isOfficial => sourceType == officialSource;

  /// Whether the grid comes from the published fee tables.
  bool get isPublished => sourceType != null;

  /// Operator grouping key.
  String get operatorKey => name.trim().toLowerCase();

  static const Object _keep = Object();

  /// Copy; nullable fields can be cleared by passing `null` explicitly.
  Provider copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    Object? operation = _keep,
    Object? sourceUrl = _keep,
    Object? sourceType = _keep,
    Object? effectiveDate = _keep,
    DateTime? creationDatetime,
  }) => Provider(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    iconName: iconName ?? this.iconName,
    operation: identical(operation, _keep)
        ? this.operation
        : operation as FeeOperation?,
    sourceUrl: identical(sourceUrl, _keep)
        ? this.sourceUrl
        : sourceUrl as String?,
    sourceType: identical(sourceType, _keep)
        ? this.sourceType
        : sourceType as String?,
    effectiveDate: identical(effectiveDate, _keep)
        ? this.effectiveDate
        : effectiveDate as DateTime?,
    creationDatetime: creationDatetime ?? this.creationDatetime,
  );

  static Provider fromMap(Map<String, dynamic> map) => Provider(
    id: map[Db.id].toString(),
    name: (map[Db.name] as String?) ?? '',
    description: (map[Db.description] as String?) ?? '',
    iconName: (map[Db.iconName] as String?) ?? 'business',
    operation: FeeOperation.fromKey(map[Db.operation] as String?),
    sourceUrl: map[Db.sourceUrl] as String?,
    sourceType: map[Db.sourceType] as String?,
    effectiveDate: DateTime.tryParse('${map[Db.effectiveDate] ?? ''}'),
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
      Db.operation: provider.operation?.key,
      Db.sourceUrl: provider.sourceUrl,
      Db.sourceType: provider.sourceType,
      Db.effectiveDate: provider.effectiveDate?.toIso8601String().substring(
        0,
        10,
      ),
      Db.creationDatetime: provider.creationDatetime.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Provider && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Provider(id: $id, name: $name, operation: $operation)';
}
