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
      // Start timing cache retrieval
      var startTimeCache = DateTime.now();
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);
      var endTimeCache = DateTime.now();
      var cacheDuration = endTimeCache.difference(startTimeCache);
      logger.i(
          "Shared Preferences cache retrieval duration: ${cacheDuration.inMilliseconds} ms");

      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        logger.i('Fetching data from cache for key: $cacheKey');
        List<dynamic> dataList = cachedData['data'] as List<dynamic>;
        return dataList
            .map((model) => Currency.fromJson(model as Map<String, dynamic>))
            .toList();
      } else {
        logger
            .i('Cache is invalid or not found. Fetching data from Firestore.');

        // Start timing Firestore fetching
        var startTimeFirestore = DateTime.now();
        List<Currency> currencies =
            await _firestoreService.getTodayCurrencies();
        var endTimeFirestore = DateTime.now();
        var firestoreDuration = endTimeFirestore.difference(startTimeFirestore);
        logger.i(
            "Firestore fetch duration: ${firestoreDuration.inMilliseconds} ms");

        // Start timing cache update
        var startTimeCacheUpdate = DateTime.now();
        Map<String, dynamic> dataToCache = {
          'dateSaved': cacheKey,
          'data': currencies.map((e) => e.toJson()).toList()
        };
        await _cacheManager.setCache(cacheKey, dataToCache);
        var endTimeCacheUpdate = DateTime.now();
        var cacheUpdateDuration =
            endTimeCacheUpdate.difference(startTimeCacheUpdate);
        logger.i(
            "Shared Preferences cache update duration: ${cacheUpdateDuration.inMilliseconds} ms");

        return currencies;
      }
    } catch (e) {
      logger.e('Error in getDailyCurrencies: $e');
      return []; 
    }
  }

Future<Currency> getCurrencyHistory(Currency currency) async {
    String cacheKey =
        'currencyWithHistory_${currency.currencyCode}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    try {
      // Check cache first
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);
      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        Currency cachedCurrency = Currency.fromJson(cachedData);
        logger
            .i('Fetching currency with history from cache for key: $cacheKey');

      
        if (cachedCurrency.history != null &&
            cachedCurrency.history!.isNotEmpty) {
          return cachedCurrency;
        }
      }

      // If cache is invalid, not found, or history is empty, fetch from Firestore
      logger.i(
          'Cache is invalid or not found, or history is empty. Fetching history from Firestore.');
      Currency fetchedCurrency =
          await _firestoreService.fetchCurrencyHistory(currency);
      // Cache the updated currency object only if fetch is successful and history is not empty
      if (fetchedCurrency.history != null &&
          fetchedCurrency.history!.isNotEmpty) {
        Map<String, dynamic> dataToCache = fetchedCurrency.toJson();
        await _cacheManager.setCache(cacheKey, dataToCache);
      }
      return fetchedCurrency;
    } catch (e) {
      logger.e('Error in getCurrencyHistory for ${currency.currencyCode}: $e');
      // Return the original currency object with an empty history
      currency.history = [];
      return currency;
    }
  }

}
