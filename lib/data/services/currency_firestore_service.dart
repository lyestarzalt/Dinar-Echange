import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/models/currency_history.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var logger = Logger(printer: PrettyPrinter());

  Future<List<Currency>> getTodayCurrencies() async {
    try {
      var startTime = DateTime.now(); // Start timing
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
      logger.e('Error fetching today\'s currencies: $e');
      return [];
    }
  }

  Future<Currency> fetchCurrencyHistory(Currency currency) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('exchange-rate-trends')
          .doc(currency.currencyCode)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('No history available for ${currency.currencyCode}.');
      }

      List<CurrencyHistoryEntry> history = [];

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      data.forEach((date, buyRate) {
        double parsedBuyRate;
        if (buyRate is num) {
          // This will be true for both int and double
          parsedBuyRate = buyRate.toDouble();
        } else {
          parsedBuyRate = 0.0; // Default or error value
        }

        history.add(CurrencyHistoryEntry(
          date: DateTime.tryParse(date) ?? DateTime.now(),
          buy: parsedBuyRate,
        ));
      });

      history.sort((a, b) => a.date.compareTo(b.date));

      currency.history = history;
      return currency;
    } catch (e) {
      logger
          .e('Error in fetchCurrencyHistory for ${currency.currencyCode}: $e');
      currency.history = [];
      return currency;
    }
  }
}
