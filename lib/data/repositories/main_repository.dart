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
      return []; // Return an empty list in case of an error
    }
  }

  Future<Currency> getCurrencyHistory(Currency currency) async {
    String cacheKey =
        'currencyWithHistory_${currency.currencyCode}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    try {
      // Check cache first
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);
      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        logger
            .i('Fetching currency with history from cache for key: $cacheKey');
        return Currency.fromJson(cachedData);
      } else {
        logger.i(
            'Cache is invalid or not found. Fetching history from Firestore.');
        currency = await _firestoreService
            .fetchCurrencyHistory(currency); // Fetch history

        // Cache the updated currency object
        Map<String, dynamic> dataToCache = currency.toJson();
        await _cacheManager.setCache(cacheKey, dataToCache);

        return currency;
      }
    } catch (e) {
      logger.e('Error in getCurrencyHistory: $e');
      return currency;
    }
  }
}
