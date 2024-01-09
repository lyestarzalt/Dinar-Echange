import 'package:dinar_watch/data/models/currency.dart';


/// The CurrencyRepository class is an abstract class 
/// for managing currency-related data.
abstract class CurrencyRepository {
  Future<List<Currency>> getDailyCurrencies();

  Future<Currency> getCurrencyHistory(Currency currency);

}


