import 'firebase_service.dart';
import 'extra_currencies_service.dart';
import '../models/currency.dart';
import 'package:logger/logger.dart';

class UnifiedCurrencyService {
  final FirestoreService _firestoreService = FirestoreService();
  final ExtraCurrencyConverter _extraCurrencyConverter =
      ExtraCurrencyConverter();
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  Future<List<Currency>> getUnifiedCurrencies() async {
    // Fetch core currencies from Firebase
    List<Currency> coreCurrencies =
        await _firestoreService.fetchDailyCurrencies();

    // Create a map of core currencies for easy lookup
    Map<String, Currency> coreCurrenciesMap = {
      for (var c in coreCurrencies) c.name: c
    };

    // Fetch extra currencies
    List<Currency> extraCurrencies = await _extraCurrencyConverter
        .calculateConvertedCurrencies('USD', coreCurrenciesMap);

    // Filter out extra currencies that overlap with core currencies
    extraCurrencies.removeWhere(
        (extraCurrency) => coreCurrenciesMap.containsKey(extraCurrency.name));

    // Combine and return the list
    return [...coreCurrencies, ...extraCurrencies];
  }
}
