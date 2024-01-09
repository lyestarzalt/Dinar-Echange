import 'package:dinar_watch/data/currency_repository.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/services/cache_service.dart';
import 'package:intl/intl.dart';
import 'package:dinar_watch/utils/logging.dart';

class MainRepository implements CurrencyRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final CacheManager _cacheManager = CacheManager();

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    String cacheKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);

      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        AppLogger.logInfo('Cache hit for daily currencies with key: $cacheKey');
        List<dynamic> dataList = cachedData['data'] as List<dynamic>;
        return dataList
            .map((model) => Currency.fromJson(model as Map<String, dynamic>))
            .toList();
      } else {
        AppLogger.logInfo(
            'Cache miss. Fetching daily currencies from Firestore.');
        List<Currency> currencies =
            await _firestoreService.fetchCurrenciesFromFirestore();
        await _cacheManager.setCache(
            cacheKey, {'data': currencies.map((e) => e.toJson()).toList()});
        return currencies;
      }
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to fetch daily currencies',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  @override
  Future<Currency> getCurrencyHistory(Currency currency) async {
    String cacheKey =
        'currencyWithHistory_${currency.currencyCode}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    try {
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);

      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        AppLogger.logInfo(
            'Fetching currency history from cache for key: $cacheKey');
        Currency cachedCurrency = Currency.fromJson(cachedData);
        if (cachedCurrency.history != null &&
            cachedCurrency.history!.isNotEmpty) {
          return cachedCurrency;
        }
      }

      AppLogger.logInfo('Fetching currency history from Firestore.');
      Currency fetchedCurrency =
          await _firestoreService.fetchCurrencyHistoryFromFirestore(currency);
      if (fetchedCurrency.history != null &&
          fetchedCurrency.history!.isNotEmpty) {
        await _cacheManager.setCache(cacheKey, fetchedCurrency.toJson());
      }
      return fetchedCurrency;
    } catch (e) {
      AppLogger.logError(
          'Error fetching history for ${currency.currencyCode}: $e');
      rethrow;
    }
  }
}
