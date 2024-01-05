import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/pages/settings/settings_page.dart';
import 'package:dinar_watch/pages/currencies_list/currency_list_page.dart';
import 'package:dinar_watch/pages/trends/history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:dinar_watch/shared/enums.dart';
import 'package:dinar_watch/theme/color_scheme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

class MainScreen extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final List<Currency> currencies;
  final Locale? selectedLocale; // Add this line

  const MainScreen({
    Key? key,
    required this.initialThemeMode,
    required this.currencies,
    required this.selectedLocale, // Add this line
  }) : super(key: key);

  @override
  MainScreenState createState() =>
      MainScreenState(selectedLocale); // Pass selectedLocale to MainScreenState
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.light;
  Locale? _currentLocale;

  // Add this constructor
  MainScreenState(Locale? selectedLocale) {
    _currentLocale = selectedLocale;
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _currentLocale = newLocale;
    });
  }

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _currentLocale,
      title: 'Dinar Watch',
      theme: ColorSchemeManager.lightTheme,
      darkTheme: ColorSchemeManager.darkTheme,
      themeMode: _themeMode,
      home: Material(
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
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
            bottomNavigationBar: MainNavigation(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
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

class MainNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  MainNavigation(
      {Key? key, required this.selectedIndex, required this.onItemSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 55,
      indicatorColor: Colors.transparent,
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.list),
          label: AppLocalizations.of(context)!.currencies,
        ),
        NavigationDestination(
          icon: const Icon(Icons.history),
          label: AppLocalizations.of(context)!.history,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }
}
