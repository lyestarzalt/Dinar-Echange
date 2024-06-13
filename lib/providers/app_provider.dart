import 'package:flutter/material.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/services/http_service.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';

class AppProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  TabController? _tabController;

  TabController get tabController => _tabController!;

  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  late String _htmlContent;
  bool _isLoading = true;
  String get htmlContent => _htmlContent;
  bool get isLoading => _isLoading;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  PackageInfo get packageInfo => _packageInfo;

  AppProvider() {
    loadThemeMode();
    loadSelectedLanguage();
    loadAppVersion();
  }

  // Load Theme Mode
  Future<void> loadThemeMode() async {
    _themeMode = await PreferencesService().getThemeMode();
    notifyListeners();
  }

  // Set Theme Mode
  void setThemeMode(ThemeOption option) async {
    switch (option) {
      case ThemeOption.dark:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeOption.light:
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    await PreferencesService().setThemeMode(option);
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

  // Set Language
  void setLanguage(Locale newLocale) async {
    if (newLocale != _currentLocale) {
      _currentLocale = newLocale;
      await PreferencesService().setSelectedLanguage(newLocale.languageCode);
      notifyListeners();
    }
  }

  // Load HTML Content for Legal Documents
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

  Future<void> loadAppVersion() async {
    _packageInfo = await PackageInfo.fromPlatform();
    notifyListeners();
  }

  String getBuildMode() {
    if (kReleaseMode) {
      return "Release";
    } else if (kDebugMode) {
      return "Debug";
    } else if (kProfileMode) {
      return "Profile";
    }
    return "Unknown";
  }
}
