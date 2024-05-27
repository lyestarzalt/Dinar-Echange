import 'package:dinar_echange/utils/logging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class HttpService {
  late Dio _dio;
  final baseURL = 'https://exchange-dinar.web.app/';
  HttpService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseURL,
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 3),
    ));
  }

  Future<String> getLegalHtml(String urlPath) async {
    try {
      Response response = await _dio.get(urlPath);
      return response.data;
    } on DioException catch (e, stackTrace) {
      AppLogger.logError('Failed to fetch Html from $baseURL$urlPath',
          error: e, stackTrace: stackTrace);
      final String localHtmlContent =
          await rootBundle.loadString("assets/$urlPath");
      return localHtmlContent;
    }
  }
}
