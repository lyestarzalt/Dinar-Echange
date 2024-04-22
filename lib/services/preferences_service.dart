import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:flutter/scheduler.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  late SharedPreferences _pref;

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  Future<List<String>> getSelectedCurrencies() async {
    return _pref.getStringList('selectedCurrencies') ?? [];
  }

  Future<void> setSelectedCurrencies(List<String> currencies) async {
    await _pref.setStringList('selectedCurrencies', currencies);
  }

  Future<ThemeMode> getThemeMode() async {
    String? themeOptionString = _pref.getString('themeOption');
    ThemeOption themeOption = ThemeOption.values.firstWhere(
      (option) => option.toString().split('.').last == themeOptionString,
      orElse: () => ThemeOption.auto, // Default to auto if not set or invalid
    );
    switch (themeOption) {
      case ThemeOption.dark:
        return ThemeMode.dark;
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.auto:
      default:
        Brightness brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeOption themeOption) async {
    String themeOptionString = themeOption.toString().split('.').last;
    await _pref.setString('themeOption', themeOptionString);
  }

  Future<String?> getSelectedLanguage() async {
    return _pref.getString('selectedLanguage');
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    await _pref.setString('selectedLanguage', languageCode);
  }
  
  Future<String?> getString(String key) async {
    return _pref.getString(key);
  }
  Future<bool> setString(String key, String data) async {
    return _pref.setString(key, data);
  }


  Future<bool> hasAcceptedTerms() async {
    return _pref.getBool('acceptedTerms') ?? false;
  }

  Future<void> setAcceptedTerms(bool accepted) async {
    await _pref.setBool('acceptedTerms', accepted);
  }

}

