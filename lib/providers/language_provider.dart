import 'package:flutter/material.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:intl/intl.dart';

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

  String getDatetime(DateTime currentDateTime) {
    String langLocal = currentLocale.toString();
    if (langLocal == 'ar') {
      // If the selected language is Arabic, switch to Algerian Arabic (ar_DZ)
      langLocal = 'ar_DZ';
    }

    String formattedDate = DateFormat(
      'EEEE, d MMM y',
      langLocal,
    ).format(currentDateTime);

    return formattedDate;
  }
}
