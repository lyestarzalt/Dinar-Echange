import 'package:dinar_watch/currency_repository.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/models/currency.dart';

class MainRepository implements CurrencyRepository {

  final FirestoreService _firestoreService = FirestoreService();


  @override
  Future<List<Currency>> getDailyCurrencies() async {
    var test = _firestoreService.getCurrencies();
    return test;
  }
}
