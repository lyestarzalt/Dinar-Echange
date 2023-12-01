import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/currency_list_screen.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';
import 'theme_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dinar_watch/data/repositories/unified_currency_service.dart';
import 'package:dinar_watch/models/currency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.light;
  final UnifiedCurrencyService currencyService = UnifiedCurrencyService();
  late Future<List<Currency>> _currenciesFuture;

  List<Currency> _currencies = [];

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Declare widget options here
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
        _currenciesFuture = currencyService.getUnifiedCurrencies();

    _widgetOptions = [
        CurrencyListScreen(currenciesFuture: currencyService.getUnifiedCurrencies()),

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
