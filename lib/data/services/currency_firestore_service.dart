import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/models/currency_history.dart';
import 'package:logger/logger.dart';
import 'package:dinar_watch/services/cache_service.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var logger = Logger(printer: PrettyPrinter());
  final CacheManager _cacheManager = CacheManager();

  Future<List<Currency>> getTodayCurrencies() async {
    try {
      var snapshot = await _firestore
          .collection('exchange-daily')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) throw Exception('No data available.');

      DocumentSnapshot lastSnapshot = snapshot.docs.first;
      Map<String, dynamic> data = lastSnapshot.data() as Map<String, dynamic>;
      String docDate = lastSnapshot.id;

      return data.entries.map((entry) {
        return Currency(
          currencyCode: entry.key.toUpperCase(),
          buy: entry.value['buy'] ?? 0.0,
          sell: entry.value['sell'] ?? 0.0,
          date: DateTime.parse(docDate),
          isCore: entry.value['is_core'] ?? false,
          currencyName: entry.value['name'],
          currencySymbol: entry.value['symbol'],
          flag: entry.value['flag'],
        );
      }).toList();
    } catch (e) {
      //logger.e('Error fetching today\'s currencies: $e');
      return [];
    }
  }

  Future<List<Currency>> getCurrencies() async {
    String cacheKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      Map<String, dynamic>? cachedData = await _cacheManager.getCache(cacheKey);

      if (cachedData != null && _cacheManager.isCacheValid(cachedData)) {
        //logger.i('Fetching data from cache for key: $cacheKey');
        List<dynamic> dataList = cachedData['data'] as List<dynamic>;
        return dataList
            .map((model) => Currency.fromJson(model as Map<String, dynamic>))
            .toList();
      } else {
        List<Currency> currencies = await getTodayCurrencies();

        for (var currency in currencies.where((c) => c.isCore)) {
          CurrencyHistory currencyHistory =
              await fetchCurrencyHistory(currency.currencyCode);
          currency.history = currencyHistory.history;

          // Log to confirm history is attached
          //logger.i('History for ${currency.currencyCode}: ${currency.history?.map((e) => e.toJson()).toList()}');
        }

        // Prepare data for caching
        Map<String, dynamic> dataToCache = {
          'dateSaved': cacheKey,
          'data': currencies.map((e) => e.toJson()).toList()
        };

        // Log before caching
        logger.i('Data before caching: ${json.encode(dataToCache)}');

        await _cacheManager.setCache(cacheKey, dataToCache);

        return currencies;
      }
    } catch (e) {
      logger.e('Error in getCurrencies: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Future<CurrencyHistory> fetchCurrencyHistory(String currencyName) async {
    DocumentSnapshot docSnapshot = await _firestore
        .collection('exchange-rate-trends')
        .doc(currencyName)
        .get();
    // logger.i('getting history from firebase $docSnapshot');

    if (!docSnapshot.exists) {
      throw Exception('No history available for $currencyName.');
    }

    List<Currency> history = [];
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    data.forEach((date, buyRate) {
      history.add(Currency(
          currencyCode: currencyName.toUpperCase(),
          sell: 0,
          buy: buyRate.toDouble() ?? 0.0,
          date: DateTime.parse(date),
          isCore: true));
    });

    return CurrencyHistory(name: currencyName, history: history);
  }
}
