import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/pages/home_screen.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:dinar_watch/pages/Error/Error_page.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeApp();
}

Future<void> initializeApp() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkMode = prefs.getBool('isDarkMode');
    ThemeMode themeMode = ThemeMode.light; 

    String? selectedLanguage = prefs.getString('selectedLanguage');
    Locale? selectedLocale;
    if (selectedLanguage != null) {
      selectedLocale = Locale(selectedLanguage);
    }

    if (isDarkMode != null) {
      themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      Brightness brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      themeMode =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signInAnonymously();

    List<Currency> currencies = await MainRepository().getDailyCurrencies();

    FlutterNativeSplash.remove();
    runApp(MyApp(
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

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  final List<Currency> currencies;
final Locale? selectedLocale;
  const MyApp({
    Key? key,
    required this.themeMode,
    required this.currencies,
    required this.selectedLocale, 
  }) : super(key: key);

@override
  Widget build(BuildContext context) {
    return MainScreen(
      initialThemeMode: themeMode,
      currencies: currencies,
      selectedLocale: selectedLocale,
    );
  }
}
