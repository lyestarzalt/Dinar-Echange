import 'package:dinar_echange/data/models/currency_model.dart';

abstract class CurrencyRepository {
  Future<List<Currency>> getDailyCurrencies();
  Future<Currency> getCurrencyHistory(Currency currency);
  Future<List<Currency>> getOfficialDailyCurrencies();
}
