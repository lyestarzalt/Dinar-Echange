import 'package:dinar_watch/data/models/currency.dart';

// you better follow rules
abstract class CurrencyRepository {
  Future<List<Currency>> getDailyCurrencies();
}
