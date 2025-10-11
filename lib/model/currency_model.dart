/// Clean Currency model with validation and utility methods
class Currency {
  Currency({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    this.rate = 1.0,
    DateTime? creationDatetime,
  }) : creationDatetime = creationDatetime ?? DateTime.now();

  final String id;
  final String code; // ISO code like 'EUR', 'USD', 'MGA'
  final String name; // Full name like 'Euro', 'US Dollar', 'Ariary'
  final String symbol; // Symbol like '€', '$', 'Ar'
  final double rate; // Exchange rate relative to base currency
  final DateTime creationDatetime;

  /// Checks if currency data is valid
  bool get isValid =>
      id.trim().isNotEmpty &&
      code.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      symbol.trim().isNotEmpty &&
      rate > 0;

  /// Gets display name with symbol
  String get displayName => '$name ($symbol)';

  /// Gets short display name
  String get shortDisplayName => '$code $symbol';

  /// Checks if currency was created recently (within 7 days)
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
  Currency copyWith({
    String? id,
    String? code,
    String? name,
    String? symbol,
    double? rate,
    DateTime? creationDatetime,
  }) {
    return Currency(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      rate: rate ?? this.rate,
      creationDatetime: creationDatetime ?? this.creationDatetime,
    );
  }

  /// Creates currency from database map
  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      id: map['id'].toString(),
      code: map['code'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      rate: (map['rate'] as num?)?.toDouble() ?? 1.0,
      creationDatetime: DateTime.parse(map['creation_datetime'] as String),
    );
  }

  /// Converts currency to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
      'rate': rate,
      'creation_datetime': creationDatetime.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Currency(id: $id, code: $code, name: $name, symbol: $symbol, rate: $rate)';
}