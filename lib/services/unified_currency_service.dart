import 'package:dinar_watch/data/repositories/main_currencies_repository.dart';
import 'package:dinar_watch/data/repositories/secondary_currencies_repository.dart';
import 'package:dinar_watch/data/services/currency_api_service.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:logger/logger.dart';

class UnifiedCurrencyService {
  final MainCurrenciesRepository _mainCurrenciesRepository;
  final SecondaryCurrenciesRepository _secondaryCurrenciesRepository;
  var logger = Logger(printer: PrettyPrinter());

  UnifiedCurrencyService()
      : _mainCurrenciesRepository =
            MainCurrenciesRepository(CurrencyFirestoreService()),
        _secondaryCurrenciesRepository =
            SecondaryCurrenciesRepository(ExtraCurrency(), {}) {
    // Empty secondary repository coreCurrencies map is initialized here
  }

  Future<List<Currency>> getUnifiedCurrencies() async {
    try {
      // Fetch core currencies
      List<Currency> coreCurrencies =
          await _mainCurrenciesRepository.getDailyCurrencies();

      // Pass core currencies to SecondaryCurrenciesRepository
      _secondaryCurrenciesRepository.coreCurrencies = {
        for (var currency in coreCurrencies) currency.name: currency
      };

      // Fetch secondary currencies
      List<Currency> secondaryCurrencies =
          await _secondaryCurrenciesRepository.getDailyCurrencies();

      // Combine and return the list
      return [...coreCurrencies, ...secondaryCurrencies];
    } catch (e) {
      logger.e('Error getting unified currencies: $e');
      return [];
    }
  }
}
