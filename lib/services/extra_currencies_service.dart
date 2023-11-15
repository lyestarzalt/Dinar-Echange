import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class ExtraCurrencyConverter {
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

    double baseCurrencyBuyRateInDZD = coreCurrencies[baseCurrencyCode]?.buy ??
        1; // Fallback to 1 if not found
    double baseCurrencySellRateInDZD =
        coreCurrencies[baseCurrencyCode]?.sell ?? 1;

    rates.forEach((convertedCurrencyCode, rateToBase) {
      if (convertedCurrencyCode != baseCurrencyCode) {
        double convertedBuyRate = baseCurrencyBuyRateInDZD * rateToBase;
        double convertedSellRate = baseCurrencySellRateInDZD * rateToBase;

        convertedCurrencies.add(
          Currency(
              name: convertedCurrencyCode,
              buy: convertedBuyRate,
              sell: convertedSellRate,
              date: DateTime.now(),
              isCore: false),
        );
      }
    });

    return convertedCurrencies;
  }
}
