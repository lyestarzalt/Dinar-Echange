import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/currency_list_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';
import 'theme_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.light;
  late MainRepository currencyService = MainRepository();
  //final UnifiedCurrencyService currencyService = UnifiedCurrencyService();
  late Future<List<Currency>> _currenciesFuture;

  Future<void> saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Default to light theme if no preference is set
    return prefs.getBool('isDarkMode') ?? false;
  }

  void _toggleTheme(ThemeOption option) async {
    switch (option) {
      case ThemeOption.dark:
        await saveThemePreference(true);
        setState(() {
          _themeMode = ThemeMode.dark;
        });
        break;
      case ThemeOption.light:
        await saveThemePreference(false);
        setState(() {
          _themeMode = ThemeMode.light;
        });
        break;
      case ThemeOption.auto:
      default:
        setState(() {
          _themeMode = ThemeMode.system;
        });
        break;
    }
  }

  Future<void> _initTheme() async {
    bool isDarkMode = await loadThemePreference();
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Declare widget options here
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _initTheme();

    _currenciesFuture = currencyService.getDailyCurrencies();

    _widgetOptions = [
      CurrencyListScreen(currenciesFuture: _currenciesFuture),
      HistoryPage(currenciesFuture: _currenciesFuture),
      SettingsPage(onThemeChanged: _toggleTheme),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency App',
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      themeMode: _themeMode,
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: NavigationBar(
          height: 50,
          indicatorColor: Colors.transparent,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list),
              label: 'Currencies',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
