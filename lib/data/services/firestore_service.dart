import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/data/models/historical_rate_model.dart';
import 'package:dinar_echange/utils/logging.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _parallelMarketRates = 'exchange-daily';
  static const String _bankRates = 'exchange-daily-official';
  static const String _rateHistory = 'exchange-rate-trends';

  Future<List<Currency>> fetchCurrenciesFromFirestore(
      {required bool isBankRate}) async {
    try {
      final ratesCollection = isBankRate ? _bankRates : _parallelMarketRates;

      final latestRatesSnapshot = await _firestore
          .collection(ratesCollection)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      if (latestRatesSnapshot.docs.isEmpty) {
        final source = isBankRate ? 'bank' : 'parallel market';
        throw Exception('No exchange rates available for $source');
      }

      return _convertFirestoreDataToCurrencies(latestRatesSnapshot.docs.first);
    } catch (e, stackTrace) {
      final rateType = isBankRate ? 'bank' : 'parallel market';
      AppLogger.logError('Failed to fetch $rateType exchange rates',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Currency> fetchCurrencyHistory(Currency currency) async {
    try {
      final historicalRatesSnapshot = await _firestore
          .collection(_rateHistory)
          .doc(currency.currencyCode)
          .get();

      if (!historicalRatesSnapshot.exists) {
        throw Exception(
            'Historical data not found for ${currency.currencyCode}');
      }

      currency.history =
          _convertFirestoreDataToHistoricalRates(historicalRatesSnapshot);
      return currency;
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Failed to fetch historical rates for ${currency.currencyCode}',
          error: e,
          stackTrace: stackTrace);
      rethrow;
    }
  }

  List<Currency> _convertFirestoreDataToCurrencies(
      DocumentSnapshot ratesSnapshot) {
    final ratesData = ratesSnapshot.data() as Map<String, dynamic>;
    final snapshotDate = ratesSnapshot.id;

    return ratesData.entries.map((currencyData) {
      final value = currencyData.value as Map<String, dynamic>;
      return Currency(
        currencyCode: currencyData.key.toUpperCase(),
        buy: (value['buy'] as num?)?.toDouble() ?? 0.0,
        sell: (value['sell'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.parse(snapshotDate),
        isCore: value['is_core'] as bool? ?? false,
        currencyName: value['name'] as String?,
        currencySymbol: value['symbol'] as String?,
        flag: value['flag'] as String?,
      );
    }).toList();
  }

  List<CurrencyHistoryEntry> _convertFirestoreDataToHistoricalRates(
      DocumentSnapshot historySnapshot) {
    final historicalData = historySnapshot.data() as Map<String, dynamic>;

    final historicalRates = historicalData.entries
        .map((entry) => CurrencyHistoryEntry(
              date: DateTime.tryParse(entry.key) ?? DateTime.now(),
              buy: (entry.value is num) ? (entry.value as num).toDouble() : 0.0,
            ))
        .toList();

    historicalRates.sort((a, b) => a.date.compareTo(b.date));
    return historicalRates;
  }
}
