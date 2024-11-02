import 'package:dinar_echange/data/currency_repository.dart';
import 'package:dinar_echange/data/services/currency_firestore_service.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/services/cache_service.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:intl/intl.dart';
import 'package:dinar_echange/utils/custom_exception.dart';

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
  Future<List<Currency>> getOfficialDailyCurrencies() async {
    return _getCachedData<List<Currency>>(
      baseKey: 'officialDailyCurrencies',
      fetchFromFirestore:
          _firestoreService.fetchOfficialCurrenciesFromFirestore,
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
        AppLogger.logInfo('Cache hit for key: $cacheKey');
        return fromJson(cachedData['data']);
      }

      AppLogger.logInfo(
          'Cache miss. Fetching from Firestore for key: $cacheKey');

      // Start timing here, right before fetching from Firestore
      Stopwatch stopwatch = Stopwatch()..start();
      T data = await fetchFromFirestore();
      stopwatch.stop();
      await _cacheManager.setCache(cacheKey, {'data': data});
      AppLogger.logEvent('fetch_currency_duration', {
        'duration_ms': stopwatch.elapsedMilliseconds,
        'cache_key': cacheKey
      });

      return data;
    } catch (e, stackTrace) {
      AppLogger.logError(
          '_getCachedData: Failed to fetch data for key: $cacheKey. Error: $e',
          error: e,
          stackTrace: stackTrace);
      // Attempt to retrieve the most recent valid cache if fetch fails
      return await _getFallbackCacheData(baseKey, fromJson);
    }
  }

  Future<T> _getFallbackCacheData<T>(
      String baseKey, T Function(dynamic) fromJson) async {
    int DaysLookBack = 7; // Limit to 7days
    for (int i = 1; i <= DaysLookBack; i++) {
      String historicalKey = _cacheManager.generateCacheKey(baseKey,
          suffix: DateFormat('yyyy-MM-dd')
              .format(DateTime.now().subtract(Duration(days: i))));
      Map<String, dynamic>? data = await _cacheManager.getCache(historicalKey);
      if (data != null && data['data'] != null) {
        AppLogger.logInfo('Fallback cache hit for key: $historicalKey');
        return fromJson(data['data']);
      }
    }
    String errorMsg =
        'No valid cache data available as fallback for base key: $baseKey. All attempts to fetch data failed.';
    AppLogger.logError(errorMsg, isFatal: true);
    throw DataFetchFailureException(errorMsg, canContinue: false);
  }
}
