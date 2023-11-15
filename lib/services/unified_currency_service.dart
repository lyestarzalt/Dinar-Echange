import 'firebase_service.dart';
import 'extra_currencies_service.dart';
import '../models/currency.dart';

class UnifiedCurrencyService {
  final FirestoreService _firestoreService = FirestoreService();
  final ExtraCurrencyConverter _extraCurrencyConverter =
      ExtraCurrencyConverter();

  Future<List<Currency>> getUnifiedCurrencies() async {
    List<Currency> coreCurrencies =
        await _firestoreService.fetchDailyCurrencies();
    Map<String, Currency> coreCurrenciesMap = {
      for (var c in coreCurrencies) c.name: c
    };
    // Assuming 'USD' is the base currency for extra currencies
    List<Currency> extraCurrencies =
        await _extraCurrencyConverter.calculateConvertedCurrencies('USD', {});

    // Filter out extra currencies that overlap with core currencies
    extraCurrencies.removeWhere(
        (extraCurrency) => coreCurrenciesMap.containsKey(extraCurrency.name));
    // Combine and return the list
    return [...coreCurrencies, ...extraCurrencies];
  }
}
