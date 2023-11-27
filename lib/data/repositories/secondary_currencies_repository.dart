// lib/data/repositories/secondary_currencies_repository.dart

import '../../currency_repository.dart';
import '../../models/currency.dart';
import 'package:dinar_watch/data/services/currency_api_service.dart';
class SecondaryCurrenciesRepository implements CurrencyRepository {
  final ExtraCurrency _apiService;

  SecondaryCurrenciesRepository(this._apiService);

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    return _apiService.getDailyCurrencies();

  }
}
