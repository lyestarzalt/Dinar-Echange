import 'package:flutter/material.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/services/http_service.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:flutter/services.dart';
class LegalProvider with ChangeNotifier {
  late String _htmlContent;
  bool _isLoading = true;

  String get htmlContent => _htmlContent;
  bool get isLoading => _isLoading;

  Future<void> loadContent(LegalDocumentType type) async {
    HttpService httpService = HttpService();
    String path = type == LegalDocumentType.terms
        ? 'terms_and_conditions.html'
        : 'privacy_policy.html';

    try {
      _htmlContent = await httpService.getLegalHtml(path);
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to fetch $path',
          error: e, stackTrace: stackTrace);
      _htmlContent = await rootBundle.loadString('assets/$path');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
