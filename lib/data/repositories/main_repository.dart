import 'package:dinar_watch/data/currency_repository.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/services/cache_service.dart';
import 'package:dinar_watch/utils/logging.dart';

class MainRepository implements CurrencyRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final CacheManager _cacheManager = CacheManager();

  @override
  Future<List<Currency>> getDailyCurrencies() async {
    return _getCachedData<List<Currency>>(
      baseKey: 'dailyCurrencies',
      fetchFromFirestore: _firestoreService.fetchCurrenciesFromFirestore,
      fromJson: (data) => (data as List<dynamic>)
          .map((model) => Currency.fromJson(model as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Currency> getCurrencyHistory(Currency currency) async {
    return _getCachedData<Currency>(
      baseKey: 'currencyWithHistory',
      suffix: currency.currencyCode,
      fetchFromFirestore: () =>
          _firestoreService.fetchCurrencyHistoryFromFirestore(currency),
      fromJson: (data) => Currency.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<T> _getCachedData<T>({
    required String baseKey,
    String? suffix,
    required Future<T> Function() fetchFromFirestore,
    required T Function(dynamic) fromJson,
  }) async {
    String cacheKey = _cacheManager.generateCacheKey(baseKey, suffix: suffix);
    try {
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);

      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        AppLogger.logInfo('_getCachedData: Cache hit for key: $cacheKey');
        return fromJson(cachedData['data']);
      }

      AppLogger.logInfo(
          '_getCachedData: Cache miss. Fetching from Firestore for key: $cacheKey');

      T data = await fetchFromFirestore();
      await _cacheManager.setCache(cacheKey, {'data': data});
      return data;
    } catch (e, stackTrace) {
      AppLogger.logError(
          '_getCachedData: Failed to fetch data for key: $cacheKey. Error: $e',
          error: e,
          stackTrace: stackTrace);

      rethrow;
    }
  }
}
