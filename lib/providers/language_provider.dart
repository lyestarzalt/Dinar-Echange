import 'package:flutter/material.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

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

    if (languageCode != null) {
      // If there's a saved language preference, use that
      _currentLocale = Locale(languageCode);
    } else {
      // No saved preference, so use the system's locale
      final List<Locale> systemLocales = PlatformDispatcher.instance.locales;
      _currentLocale =
          systemLocales.isNotEmpty ? systemLocales.first : const Locale('en');
    }

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
