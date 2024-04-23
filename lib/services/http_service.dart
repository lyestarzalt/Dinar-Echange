// services/http_service.dart
import 'package:dio/dio.dart';

class HttpService {
  late Dio _dio;

  HttpService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://exchange-dinar.web.app',
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 3),
    ));

   
  }

  Future<String> getTermsHtml() async {
    try {
      Response response = await _dio.get('/terms_and_conditions.html');
      return response.data.replaceAll(':hover', '');
    } on DioException catch (e) {
      throw Exception('Failed to load data: ${e.message}');
    }
  }

}
