import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/pages/home_screen.dart'; // Update the path if necessary
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinar_watch/theme_manager.dart';
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

  // Load theme preference and Firestore data
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  ThemeMode themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
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
    return MaterialApp(
      title: 'Currency App',
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      themeMode: themeMode,
      home: MainScreen(initialThemeMode: themeMode, currencies: currencies),
    );
  }
}
