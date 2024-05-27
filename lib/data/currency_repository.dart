import 'package:dinar_echange/data/models/currency.dart';

abstract class CurrencyRepository {
  Future<List<Currency>> getDailyCurrencies();

  Future<Currency> getCurrencyHistory(Currency currency);
}
