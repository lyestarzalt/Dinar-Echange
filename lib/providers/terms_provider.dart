import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:flutter/services.dart';
import 'package:dinar_echange/services/http_service.dart';

class TermsProvider with ChangeNotifier {
  String _htmlContent = '';
  bool _isLoading = true;

  TermsProvider() {
    _initialize();
  }

  String get htmlContent => _htmlContent;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    try {
      _htmlContent = await _fetchTermsFromServer();
    } catch (e) {
      _htmlContent = await _loadLocalHtmlContent();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _fetchTermsFromServer() async {
    HttpService termsContent = HttpService();

    return await termsContent.getTermsHtml();
    // Implement fetching logic from server
  }

  Future<String> _loadLocalHtmlContent() async {
    try {
      final String localHtmlContent =
          await rootBundle.loadString('assets/terms_and_conditions.html');
      String modified = localHtmlContent.replaceAll(':hover', '');
      AppLogger.logInfo('Loaded local terms and conditions.');
      return modified;
    } catch (e) {
      AppLogger.logError('Error loading local terms: ${e.toString()}');
      throw 'Error loading local content. Please try again later.';
    }
  }
}
