import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/models/currency_history.dart';
import 'package:dinar_watch/services/cache_service.dart';
import 'package:intl/intl.dart';

class CurrencyFirestoreService    {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheManager _cacheManager = CacheManager();



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
    List<Currency> currencies = snapshot
        .data()!
        .entries
        .map((e) => Currency(
            name: e.key.toUpperCase(),
            buy: e.value['buy'],
            sell: e.value['sell'],
            date: docDate,
            isCore: true))
        .toList();

    await _cacheManager.setCache(key,
        {'dateSaved': key, 'data': currencies.map((e) => e.toJson()).toList()});

    return currencies;
  }

  Future<CurrencyHistory> fetchCurrencyHistory(
      String currencyName, int lastDays) async {
    String historyKey = 'history_${currencyName}_$lastDays';
    Map<String, dynamic>? cachedHistory =
        await _cacheManager.getCache(historyKey);

    if (cachedHistory != null && _cacheManager.isCacheValid(cachedHistory)) {
      return _decodeCurrencyHistory(cachedHistory, currencyName);
    } else {
      return await _fetchAndCacheCurrencyHistory(
          currencyName, lastDays, historyKey);
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
      String currencyName, int lastDays, String key) async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('exchange-daily').limit(lastDays).get();

    List<Currency> history = [];
    for (var doc in querySnapshot.docs) {
      DateTime docDate = DateTime.parse(doc.id);
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(currencyName)) {
        history.add(Currency(
            name: currencyName.toUpperCase(),
            buy: (data[currencyName]['buy'] as num)
                .toDouble(), // Convert to double
            sell: (data[currencyName]['sell'] as num)
                .toDouble(), // Convert to double
            date: docDate,
            isCore: true));
      }
    }

    // Optionally cache the data and then return it
    await _cacheManager.setCache(key, {
      'dateSaved': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'data': history.map((e) => e.toJson()).toList()
    });

    return CurrencyHistory(name: currencyName, history: history);
  }
}

