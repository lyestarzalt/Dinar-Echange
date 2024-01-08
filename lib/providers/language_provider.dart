import 'package:flutter/material.dart';
import 'package:dinar_watch/services/preferences_service.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;
  LanguageProvider() {
    loadSelectedLanguage();
  }
  void setLanguage(Locale newLocale) async {
    if (newLocale != _currentLocale) {
      _currentLocale = newLocale;
      await PreferencesService().setSelectedLanguage(newLocale.languageCode);
      notifyListeners();
    }
  }

  Future<void> loadSelectedLanguage() async {
    String? languageCode = await PreferencesService().getSelectedLanguage();
    _currentLocale = Locale(languageCode ?? 'en');
    notifyListeners();
  }
}
