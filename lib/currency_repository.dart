import 'package:dinar_watch/models/currency.dart';

// you better follow rules
abstract class CurrencyRepository {
  Future<List<Currency>> getDailyCurrencies();
}
