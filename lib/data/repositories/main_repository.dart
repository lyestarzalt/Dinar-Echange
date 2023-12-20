import 'package:dinar_watch/currency_repository.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/services/cache_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MainRepository implements CurrencyRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final CacheManager _cacheManager = CacheManager();
  var logger = Logger(printer: PrettyPrinter());

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    String cacheKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);

      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        logger.i('Fetching data from cache for key: $cacheKey');
        List<dynamic> dataList = cachedData['data'] as List<dynamic>;
        return dataList
            .map((model) => Currency.fromJson(model as Map<String, dynamic>))
            .toList();
      } else {
        logger
            .i('Cache is invalid or not found. Fetching data from Firestore.');
        List<Currency> currencies = await _firestoreService.getCurrencies();

        // Prepare data for caching
        Map<String, dynamic> dataToCache = {
          'dateSaved': cacheKey,
          'data': currencies.map((e) => e.toJson()).toList()
        };

        logger.i('Updating cache with new data for key: $cacheKey');
        await _cacheManager.setCache(cacheKey, dataToCache);
        return currencies;
      }
    } catch (e) {
      logger.e('Error in getDailyCurrencies: $e');
      return []; // Return an empty list in case of an error
    }
  }
}
