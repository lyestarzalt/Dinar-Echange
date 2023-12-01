import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/models/currency_history.dart';
import 'package:dinar_watch/services/cache_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheManager _cacheManager = CacheManager();
  var logger = Logger(printer: PrettyPrinter());
  Future<List<Currency>> fetchDailyCurrencies() async {
    String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, dynamic>? cachedData = await _cacheManager.getCache(todayKey);

    if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
      List<dynamic> dataList = cachedData['data'] as List<dynamic>;
      return dataList
          .map((model) => Currency.fromJson(model as Map<String, dynamic>))
          .toList();
    } else {
      return await _fetchAndCacheDailyCurrencies(todayKey);
    }
  }

  // Fetch and cache the daily currency data from Firestore
  Future<List<Currency>> _fetchAndCacheDailyCurrencies(String key) async {
    var snapshot = await _firestore.collection('exchange-daily').doc(key).get();
    if (!snapshot.exists) throw Exception('No data available for today.');

    DateTime docDate = DateTime.parse(key);
    List<Currency> currencies = [];

    snapshot.data()!.entries.forEach((e) {
      print('Currency data for ${e.key}: ${e.value}');
      try {
        Currency currency = Currency(
            currencyCode: e.key.toUpperCase(),
            buy: e.value['buy'] ?? 0.0, // Fallback to 0.0 if null
            sell: e.value['sell'] ?? 0.0, // Fallback to 0.0 if null
            date: docDate,
            isCore: e.value['is_core'] ?? false,
            currencyName: e.value['name'],
            currencySymbol: e.value['symbol'],
            flag: e.value['flag']);
        currencies.add(currency);
      } catch (error) {
        logger.e('Error parsing currency data for ${e.key}: $error');
      }
    });
    // Fetch histories in parallel for core currencies
    var histories = await Future.wait(currencies
        .where((c) => c.isCore)
        .map((c) => fetchCurrencyHistory(c.currencyCode)));

    // Create a map from currency code to its history
    var historyMap = {for (var h in histories) h.name: h};

    // Assign histories to currencies
    for (var currency in currencies) {
      if (currency.isCore) {
        currency.history = historyMap[currency.currencyCode]?.history;
      }
    }

    await _cacheManager.setCache(key,
        {'dateSaved': key, 'data': currencies.map((e) => e.toJson()).toList()});

    return currencies;
  }

  Future<CurrencyHistory> fetchCurrencyHistory(String currencyName) async {
    String historyKey = 'history_$currencyName';
    Map<String, dynamic>? cachedHistory =
        await _cacheManager.getCache(historyKey);

    if (cachedHistory != null && _cacheManager.isCacheValid(cachedHistory)) {
      logger.i('fetching history from cache');
      return _decodeCurrencyHistory(cachedHistory, currencyName);
    } else {
      return await _fetchAndCacheCurrencyHistory(currencyName, historyKey);
    }
  }

  CurrencyHistory _decodeCurrencyHistory(
      Map<String, dynamic> cachedHistory, String currencyName) {
    var data = cachedHistory['data'] as List;
    List<Currency> history =
        data.map((item) => Currency.fromJson(item)).toList();
    return CurrencyHistory(name: currencyName, history: history);
  }

  Future<CurrencyHistory> _fetchAndCacheCurrencyHistory(
      String currencyName, String key) async {
    DocumentSnapshot docSnapshot = await _firestore
        .collection('exchange-rate-trends')
        .doc(currencyName)
        .get();
    logger.i('getting history from firebase $docSnapshot');
    List<Currency> history = [];
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      data.forEach((date, buyRate) {
        history.add(Currency(
            currencyCode: currencyName.toUpperCase(),
            sell: 0,
            buy: buyRate.toDouble() ?? 0.0, // Assuming buyRate is already a num
            date: DateTime.parse(date),
            isCore: true)); // 'sell' field can be removed if not used
      });
    }

    // Optionally cache the data and then return it
    await _cacheManager.setCache(key, {
      'dateSaved': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'data': history.map((e) => e.toJson()).toList()
    });

    return CurrencyHistory(name: currencyName, history: history);
  }
}
