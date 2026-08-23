import 'package:dio/dio.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:meta/meta.dart';

class HttpRatesService {
  static const String _baseUrl =
      'https://pub-371a3502015844d0999d54a1eadb7ac7.r2.dev';

  final Dio _dio;

  HttpRatesService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 8),
          responseType: ResponseType.json,
        ));

  Future<List<Currency>> fetchLatestCurrencies(
      {required bool isBankRate}) async {
    final path =
        isBankRate ? '/v1/official/latest.json' : '/v1/parallel/latest.json';
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      final data = response.data;
      if (data == null) {
        throw Exception('Empty response body from $path');
      }
      return parseRates(data);
    } on DioException catch (e, stackTrace) {
      AppLogger.logError('Failed to fetch $path',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @visibleForTesting
  static List<Currency> parseRates(Map<String, dynamic> data) {
    final ratesMap = data['rates'] as Map<String, dynamic>?;
    final dateStr = data['date'] as String?;
    if (ratesMap == null || dateStr == null) {
      throw Exception('Malformed rates payload: missing rates or date');
    }
    final parsedDate = DateTime.parse(dateStr);

    return ratesMap.entries.map((entry) {
      final v = entry.value as Map<String, dynamic>;
      return Currency(
        currencyCode: entry.key.toUpperCase(),
        buy: (v['buy'] as num?)?.toDouble() ?? 0.0,
        sell: (v['sell'] as num?)?.toDouble() ?? 0.0,
        date: parsedDate,
        isCore: v['is_core'] as bool? ?? false,
        currencyName: v['name'] as String?,
        currencySymbol: v['symbol'] as String?,
        flag: v['flag'] as String?,
      );
    }).toList();
  }
}
