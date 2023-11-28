import '../../currency_repository.dart';
import '../../models/currency.dart';
import 'package:dinar_watch/data/services/currency_api_service.dart';


class SecondaryCurrenciesRepository implements CurrencyRepository {
  final ExtraCurrency _apiService;
    Map<String, Currency> coreCurrencies; 

  SecondaryCurrenciesRepository(this._apiService, this.coreCurrencies);

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    // You need a base currency code to fetch exchange rates
    String baseCurrencyCode = "USD"; // Example, this can be dynamic

    // Fetch exchange rates
    Map<String, double> rates =
        await _apiService.fetchExchangeRates(baseCurrencyCode);

    // Calculate and create Currency objects
    return calculateConvertedCurrencies(baseCurrencyCode, rates);
  }

  Future<List<Currency>> calculateConvertedCurrencies(
      String baseCurrencyCode, Map<String, double> rates) async {
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
