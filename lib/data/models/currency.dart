import 'package:dinar_echange/data/models/currency_history.dart';
import 'dart:math' as math;

class Currency {
  final String currencyCode;
  final double buy;
  final double sell;
  final DateTime date;
  final bool isCore;
  final String? currencyName;
  final String? currencySymbol;
  final String? flag;
  List<CurrencyHistoryEntry>? history;

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
    List<CurrencyHistoryEntry> getFilteredHistory(int timeSpan) {
    if (history == null || history!.isEmpty) {
      return [];
    }

    final int historyLength = history!.length;
    final int startIndex = math.max(0, historyLength - timeSpan);
    return historyLength <= timeSpan
        ? List<CurrencyHistoryEntry>.from(history!)
        : List<CurrencyHistoryEntry>.from(history!.sublist(startIndex));
  }
  

  factory Currency.fromJson(Map<String, dynamic> json) {
    num? buy = json['buy'] as num?;
    num? sell = json['sell'] as num?;

    var historyJson = json['history'] as List<dynamic>?;
    List<CurrencyHistoryEntry>? history = historyJson
        ?.map((e) => CurrencyHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return Currency(
      currencyCode: json['currencyCode'] as String? ?? '',
      buy: buy?.toDouble() ?? 0.0,
      sell: sell?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] as String),
      isCore: json['isCore'] as bool? ?? false,
      currencyName: json['name'] as String?,
      currencySymbol: json['symbol'] as String?,
      flag: json['flag'] as String?,
      history: history,
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
      'history': history?.map((e) => e.toJson()).toList(),
    };
  }
}
