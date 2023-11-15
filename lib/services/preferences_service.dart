// File: lib/services/preferences_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<String>> getSelectedCurrencies() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList('selectedCurrencies') ?? [];
  }

  Future<void> setSelectedCurrencies(List<String> currencies) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setStringList('selectedCurrencies', currencies);
  }
}
