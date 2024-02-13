import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/data/models/currency_history.dart';
import 'package:dinar_watch/utils/logging.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Currency>> fetchCurrenciesFromFirestore() async {
    try {
      var snapshot = await _firestore
          .collection('exchange-daily')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        String errMsg =
        'fetchCurrenciesFromFirestore: No daily currency data found. Collection may be empty';
        AppLogger.logError(errMsg);
        throw Exception(errMsg);
      }

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
          AppLogger.logError('fetchCurrenciesFromFirestore: Exception - $e');

      rethrow;
    }
  }

  Future<Currency> fetchCurrencyHistoryFromFirestore(Currency currency) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('exchange-rate-trends')
          .doc(currency.currencyCode)
          .get();

      if (!snapshot.exists) {
             String errMsg =
            'fetchCurrencyHistoryFromFirestore: No history found for ${currency.currencyCode}. Document does not exist.';

        AppLogger.logError(errMsg);
        throw Exception(errMsg);
      }

      List<CurrencyHistoryEntry> history = [];

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      data.forEach((date, buyRate) {
        double parsedBuyRate = (buyRate is num) ? buyRate.toDouble() : 0.0;
        history.add(CurrencyHistoryEntry(
            date: DateTime.tryParse(date) ?? DateTime.now(),
            buy: parsedBuyRate));
      });

      history.sort((a, b) => a.date.compareTo(b.date));

      currency.history = history;
      return currency;
    } catch (e) {
      AppLogger.logError(
          'fetchCurrencyHistoryFromFirestore: Exception for ${currency.currencyCode} - $e');

      rethrow;
    }
  }
}
