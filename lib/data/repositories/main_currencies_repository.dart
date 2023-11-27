// lib/data/repositories/main_currencies_repository.dart

import '../../currency_repository.dart';
import '../../models/currency.dart';
import '../services/currency_firestore_service.dart';

class MainCurrenciesRepository implements CurrencyRepository {
  final CurrencyFirestoreService _firestoreService;

  MainCurrenciesRepository(this._firestoreService);

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    return _firestoreService.fetchDailyCurrencies();
  }
}
