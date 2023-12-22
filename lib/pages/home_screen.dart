import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import '../theme/theme_manager.dart';
import 'package:dinar_watch/pages/settings/settings_page.dart';
import 'package:dinar_watch/pages/currencies_list/currency_list_page.dart';
import 'package:dinar_watch/pages/trends/history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:dinar_watch/shared/enums.dart';
import 'package:dinar_watch/theme/color_scheme.dart';

class MainScreen extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final List<Currency> currencies;

  const MainScreen(
      {Key? key, required this.initialThemeMode, required this.currencies})
      : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _onThemeChanged(ThemeOption option) {
    setState(() {
      switch (option) {
        case ThemeOption.dark:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeOption.light:
          _themeMode = ThemeMode.light;
          break;
        case ThemeOption.auto:
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    });
    _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency App',
      theme: ColorSchemeManager.lightTheme,
      darkTheme: ColorSchemeManager.darkTheme,
      themeMode: _themeMode,
      home: Material(
        child: Scaffold(
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: _getPageWidget(_selectedIndex),
          ),
          bottomNavigationBar: NavigationBar(
            height: 55,
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
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPageWidget(int index) {
    Future<List<Currency>> completedFuture = Future.value(widget.currencies);
    switch (index) {
      case 0:
        return CurrencyListScreen(currenciesFuture: completedFuture);
      case 1:
        return HistoryPage(currenciesFuture: completedFuture);
      case 2:
        return SettingsPage(
            onThemeChanged: (option) => _onThemeChanged(option));
      default:
        return CurrencyListScreen(currenciesFuture: completedFuture);
    }
  }
}
