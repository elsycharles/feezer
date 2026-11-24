import '../data/app_database.dart';
import '../util/constant_util.dart';

/// Display currency. All amounts are stored in the base currency (Ariary);
/// [rate] is the number of Ariary for one unit of this currency.
class Currency {
  Currency({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    this.rate = 1.0,
    DateTime? creationDatetime,
  }) : creationDatetime = creationDatetime ?? DateTime.now();

  /// Code of the base currency in which every amount is stored.
  static const String baseCode = 'MGA';

  final String id;
  final String code;
  final String name;
  final String symbol;
  final double rate;
  final DateTime creationDatetime;

  bool get isBase => code == baseCode;

  bool get isValid =>
      id.trim().isNotEmpty &&
      code.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      symbol.trim().isNotEmpty &&
      rate > 0;

  String get displayName => '$name ($symbol)';

  Currency copyWith({
    String? id,
    String? code,
    String? name,
    String? symbol,
    double? rate,
    DateTime? creationDatetime,
  }) => Currency(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    rate: rate ?? this.rate,
    creationDatetime: creationDatetime ?? this.creationDatetime,
  );

  factory Currency.fromMap(Map<String, dynamic> map) => Currency(
    id: map[Db.id].toString(),
    code: (map[Db.code] as String?) ?? '',
    name: (map[Db.name] as String?) ?? '',
    symbol: (map[Db.symbol] as String?) ?? '',
    rate: (map[Db.rate] as num?)?.toDouble() ?? 1.0,
    // Older versions stored an ISO string in this INTEGER column.
    creationDatetime: ConstantUtil.parseDateTime(map[Db.creationDatetime]),
  );

  Map<String, dynamic> toMap() => {
    Db.id: id,
    Db.code: code,
    Db.name: name,
    Db.symbol: symbol,
    Db.rate: rate,
    Db.creationDatetime: creationDatetime.millisecondsSinceEpoch,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && other.id == id && other.rate == rate;

  @override
  int get hashCode => Object.hash(id, rate);

  @override
  String toString() =>
      'Currency(id: $id, code: $code, symbol: $symbol, rate: $rate)';
}
