import 'package:dinar_watch/data/models/currency.dart';

abstract class CurrencyRepository {
  Future<List<Currency>> getDailyCurrencies();

  Future<Currency> getCurrencyHistory(Currency currency);

}


