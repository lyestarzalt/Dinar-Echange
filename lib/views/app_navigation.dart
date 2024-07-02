import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/views/settings/settings_view.dart';
import 'package:dinar_echange/views/currencies_list/main_view.dart';
import 'package:dinar_echange/views/graph/graph_view.dart';
import 'package:animations/animations.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/appinit_provider.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Consumer<AppProvider>(
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
              child: _getPageWidget(context, navigationProvider.selectedIndex),
            );
          },
        ),
        bottomNavigationBar: Consumer<AppProvider>(
          builder: (context, navigationProvider, child) {
            return MainNavigation(
              selectedIndex: navigationProvider.selectedIndex,
              onItemSelected: (index) =>
                  navigationProvider.selectedIndex = index,
            );
          },
        ),
      ),
    );
  }

  Widget _getPageWidget(BuildContext context, int index) {
    return Consumer<AppInitializationProvider>(
        builder: (context, initProvider, child) {
      List<Currency> currencies = initProvider.currencies!;
      List<Currency> officialCurrencies = initProvider.officialCurrencies!;

      switch (index) {
        case 0:
          return MainView(
            alternativeMarketCurrencies: currencies,
            officialMarketCurrencies: officialCurrencies,
          );
        case 1:
          return HistoryPage(
            currencies:
                currencies, // Assuming HistoryPage needs a list of all currencies
          );
        case 2:
          return const SettingsPage();
        default:
          return MainView(
            alternativeMarketCurrencies: currencies,
            officialMarketCurrencies: officialCurrencies,
          );
      }
    });
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
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.list),
          label: AppLocalizations.of(context)!.currencies_app_bar_title,
        ),
        NavigationDestination(
          icon: const Icon(Icons.history),
          label: AppLocalizations.of(context)!.trends_app_bar_title,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings_app_bar_title,
        ),
      ],
    );
  }
}
