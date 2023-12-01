import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:logger/logger.dart';

class UnifiedCurrencyService {
  final MainRepository _mainCurrenciesRepository;
  var logger = Logger(printer: PrettyPrinter());

  UnifiedCurrencyService()
      : _mainCurrenciesRepository = MainRepository(FirestoreService());

Future<List<Currency>> getUnifiedCurrencies() async {
    try {
      // Fetch all currencies (core and extra) directly from Firestore
      List<Currency> currencies =
          await _mainCurrenciesRepository.getDailyCurrencies();

      for (var currency in currencies) {
        print(
            'Currency: ${currency.currencyCode}, Buy: ${currency.buy}, Sell: ${currency.sell}');
      }

      return currencies;
    } catch (e) {
      logger.e('Error getting unified currencies: $e');
      return [];
    }
  }

}
