import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/pages/settings/settings_page.dart';
import 'package:dinar_watch/pages/currencies_list/currency_list_page.dart';
import 'package:dinar_watch/pages/trends/history_page.dart';
import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final List<Currency> currencies;

  const MainScreen({super.key, required this.currencies});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return PageTransitionSwitcher(
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
            child: _getPageWidget(navigationProvider.selectedIndex),
          );
        },
      ),
      bottomNavigationBar: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return MainNavigation(
            selectedIndex: navigationProvider.selectedIndex,
            onItemSelected: (index) => navigationProvider.selectedIndex = index,
          );
        },
      ),
    );
  }

  Widget _getPageWidget(int index) {
    Future<List<Currency>> completedFuture = Future.value(widget.currencies);
    switch (index) {
      case 0:
        return const CurrencyListScreen();
      case 1:
        return HistoryPage(currenciesFuture: completedFuture);
      case 2:
        return const SettingsPage();
      default:
        return const CurrencyListScreen();
    }
  }
}

class MainNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MainNavigation(
      {super.key, required this.selectedIndex, required this.onItemSelected});

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
