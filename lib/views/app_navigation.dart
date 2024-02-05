import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/views/settings/settings_view.dart';
import 'package:dinar_watch/views/currencies_list/list_currencies_view.dart';
import 'package:dinar_watch/views/graph/graph_view.dart';
import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class AppNavigation extends StatefulWidget {
  final List<Currency> currencies;

  const AppNavigation({super.key, required this.currencies});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<AppNavigation> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
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
              onItemSelected: (index) =>
                  navigationProvider.selectedIndex = index,
            );
          },
        ),
      ),
    );
  }

  Widget _getPageWidget(int index) {
    switch (index) {
      case 0:
        return CurrencyListScreen(
          currencies: widget.currencies,
        );
      case 1:
        return HistoryPage(
          currencies: widget.currencies,
        );
      case 2:
        return const SettingsPage();
      default:
        return CurrencyListScreen(
          currencies: widget.currencies,
        );
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
