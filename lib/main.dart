import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/pages/home_screen.dart'; // Update the path if necessary
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeApp();
}

Future<void> initializeApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();

  // Load theme preference
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isDarkMode = prefs.getBool('isDarkMode');
  ThemeMode themeMode;

  if (isDarkMode != null) {
    // Use saved preference
    themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  } else {
    // Use system preference if no saved preference
    Brightness brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    themeMode =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  // Fetch data from Firestore
  List<Currency> currencies = await MainRepository().getDailyCurrencies();

  // Remove the native splash screen
  FlutterNativeSplash.remove();

  runApp(MyApp(themeMode: themeMode, currencies: currencies));
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  final List<Currency> currencies;

  const MyApp({super.key, required this.themeMode, required this.currencies});

  @override
  Widget build(BuildContext context) {
    return MainScreen(initialThemeMode: themeMode, currencies: currencies);
  }
}
