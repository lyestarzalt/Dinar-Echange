// File: lib/util/external_rate_converter.dart
import 'package:dinar_watch/models/currency.dart';

class ExternalRateConverter {
  
  static Future<List<Currency>> convertExternalRates(String baseCurrencyCode,
      Map<String, double> rates, Map<String, Currency> coreCurrencies) async {
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
