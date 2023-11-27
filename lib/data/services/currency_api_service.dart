import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dinar_watch/models/currency.dart';


class ExtraCurrency {
  Future<Map<String, double>> fetchExchangeRates(
      String baseCurrencyCode) async {
    var url = Uri.parse('https://open.er-api.com/v6/latest/$baseCurrencyCode');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return Map.from(data['rates'])
          .map((currencyCode, rate) => MapEntry(currencyCode, rate.toDouble()));
    } else {
      throw Exception('Failed to fetch exchange rates');
    }
  }

  Future<List<Currency>> calculateConvertedCurrencies(
      String baseCurrencyCode, Map<String, Currency> coreCurrencies) async {
    Map<String, double> rates = await fetchExchangeRates(baseCurrencyCode);
    List<Currency> convertedCurrencies = [];

    double baseCurrencyRateInDZD = coreCurrencies[baseCurrencyCode]?.buy ?? 1;

    rates.forEach((convertedCurrencyCode, rateToBase) {
      if (convertedCurrencyCode != baseCurrencyCode) {
        double convertedRate = baseCurrencyRateInDZD / rateToBase;

        convertedCurrencies.add(
          Currency(
              name: convertedCurrencyCode,
              buy: convertedRate,
              sell: convertedRate,
              date: DateTime.now(),
              isCore: false),
        );
      }
    });

    return convertedCurrencies;
  }
}
