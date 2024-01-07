import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  late SharedPreferences _prefs;

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<String>> getSelectedCurrencies() async {
    return _prefs.getStringList('selectedCurrencies') ?? [];
  }

  Future<void> setSelectedCurrencies(List<String> currencies) async {
    await _prefs.setStringList('selectedCurrencies', currencies);
  }

  // Add other preferences methods here
}

// Usage
// Call `await PreferencesService().init();` during app initialization.
