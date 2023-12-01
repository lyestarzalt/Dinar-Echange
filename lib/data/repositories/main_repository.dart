import 'package:dinar_watch/currency_repository.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:logger/logger.dart';

class MainRepository implements CurrencyRepository {
  var logger = Logger(printer: PrettyPrinter());

  final FirestoreService _firestoreService;

  MainRepository(this._firestoreService);

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    var test = _firestoreService.fetchDailyCurrencies();
    logger.i(test);
    return test;
  }
}
