import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/currency.dart';
import '../models/currency_history.dart';
import 'cache_service.dart';
import 'package:intl/intl.dart';

class FirestoreService {
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

  Future<CurrencyHistory> fetchCurrencyHistory(String currencyName) async {
    String historyKey = 'history_$currencyName';
    Map<String, dynamic>? cachedHistory =
        await _cacheManager.getCache(historyKey);

    if (cachedHistory != null && _cacheManager.isCacheValid(cachedHistory)) {
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

    List<Currency> history = [];
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      data.forEach((date, buyRate) {
        history.add(Currency(
            name: currencyName.toUpperCase(),
            sell: 0,
            buy: buyRate.toDouble(), // Assuming buyRate is already a num
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
