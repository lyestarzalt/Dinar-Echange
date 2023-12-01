class Currency {
  final String currencyCode;
  final double buy;
  final double sell;
  final DateTime date;
  final bool isCore;
  final String? currencyName;
  final String? currencySymbol;
  final String? flag;
  List<Currency>? history;

  Currency({
    required this.currencyCode,
    required this.buy,
    required this.sell,
    required this.date,
    required this.isCore,
    this.currencyName,
    this.currencySymbol,
    this.flag,
    this.history,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    
    num? buy = json['buy'] as num?;
    num? sell = json['sell'] as num?;
    return Currency(
   currencyCode: json['currencyCode'] as String? ?? '',
      buy: buy?.toDouble() ?? 0.0, // Safe conversion with default value
      sell: sell?.toDouble() ?? 0.0, // Safe conversion with default value
      date: DateTime.parse(json['date'] as String),
      isCore: json['isCore'] as bool? ?? false,
      currencyName: json['name'] as String?,
      currencySymbol: json['symbol'] as String?,
      flag: json['flag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'buy': buy,
      'sell': sell,
      'date': date.toIso8601String(),
      'isCore': isCore,
      'name': currencyName,
      'symbol': currencySymbol,
      'flag': flag,
    };
  }
}
