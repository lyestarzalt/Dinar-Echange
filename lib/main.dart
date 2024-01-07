import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/pages/home_screen.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/pages/Error/Error_page.dart';
import 'package:dinar_watch/services/preferences_service.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeApp();
}

Future<void> initializeApp() async {
  try {
    await PreferencesService().init();

    ThemeMode themeMode = await PreferencesService().getThemeMode();

    String? selectedLanguage = await PreferencesService().getSelectedLanguage();
    Locale? selectedLocale =
        selectedLanguage != null ? Locale(selectedLanguage) : null;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signInAnonymously();

    List<Currency> currencies = await MainRepository().getDailyCurrencies();

    FlutterNativeSplash.remove();
    runApp(DinarWatch(
      themeMode: themeMode,
      currencies: currencies,
      selectedLocale: selectedLocale,
    ));
  } on FirebaseAuthException catch (e) {
    String errorMessage =
        'An unexpected error occurred. Please try again later.';
    if (e.code == 'network-request-failed') {
      errorMessage =
          'No internet connection. Please check your connection and try again.';
    }
    FlutterNativeSplash.remove();
    runApp(ErrorApp(errorMessage: errorMessage, onRetry: initializeApp));
  }
}

class DinarWatch extends StatelessWidget {
  final ThemeMode themeMode;
  final List<Currency> currencies;
  final Locale? selectedLocale;
  const DinarWatch({
    super.key,
    required this.themeMode,
    required this.currencies,
    required this.selectedLocale,
  });

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      initialThemeMode: themeMode,
      currencies: currencies,
      selectedLocale: selectedLocale,
    );
  }
}
