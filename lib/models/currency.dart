class Currency {
  final String name;
  final double buy;
  final double sell;
  final DateTime date;
  final bool isCore;

  Currency({
    required this.name,
    required this.buy,
    required this.sell,
    required this.date,
    required this.isCore,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      name: json['name'] as String,
      buy: json['buy'] as double,
      sell: json['sell'] as double,
      date: DateTime.parse(json['date'] as String),
      isCore: json['isCore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'buy': buy,
      'sell': sell,
      'date': date.toIso8601String(),
    };
  }
}
