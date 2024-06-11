class CurrencyHistoryEntry {
  final DateTime date;
  final double buy;
  CurrencyHistoryEntry({required this.date, required this.buy});
  
  
  
  factory CurrencyHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CurrencyHistoryEntry(
      date: DateTime.parse(json['date'] as String),
      buy: (json['buy'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'buy': buy,
    };
  }
}
