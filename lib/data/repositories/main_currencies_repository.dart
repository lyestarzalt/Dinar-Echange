// lib/data/repositories/main_currencies_repository.dart

import 'package:dinar_watch/currency_repository.dart';
import 'package:dinar_watch/models/currency.dart';

import 'package:dinar_watch/data/services/currency_firestore_service.dart';
class MainCurrenciesRepository implements CurrencyRepository {
  final FirestoreService _firestoreService;

  MainCurrenciesRepository(this._firestoreService);

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    return _firestoreService.fetchDailyCurrencies();
  }
}
