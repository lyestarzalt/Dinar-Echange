import 'package:flutter/material.dart';
import 'package:dinar_echange/views/settings/settings_view.dart';
import 'package:dinar_echange/views/currencies_list/main_view.dart';
import 'package:dinar_echange/views/graph/graph_view.dart';
import 'package:animations/animations.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/services/remote_config_service.dart';

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
              onItemSelected: (index) {
                navigationProvider.selectedIndex = index;
              },
            );
          },
        ),
      ),
    );
  }

  Widget _getPageWidget(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const MainView();
      case 1:
        return const HistoryPage();
      case 2:
        return const SettingsPage();
      default:
        return const MainView();
    }
  }
}

Future<bool> shouldShowAd(String type) async {
  int chanceToShowAd =
      await RemoteConfigService.instance.fetchAdShowChance(type);
  return Random().nextInt(100) < chanceToShowAd;
}

class MainNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  const MainNavigation(
      {super.key, required this.selectedIndex, required this.onItemSelected});
  @override
  Widget build(BuildContext context) {
    AdProvider adProvider = Provider.of<AdProvider>(context, listen: false);
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) =>
          _handleSelection(context, index, adProvider),
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

  void _handleSelection(
      BuildContext context, int index, AdProvider adProvider) async {
    if (await shouldShowAd('ad_show_chance_nav')) {
      if (adProvider.isInterstitialAdLoaded) {
        adProvider.showInterstitialAd();
        adProvider.onAdDismissed(() => onItemSelected(index));
      } else {
        onItemSelected(index);
      }
    } else {
      onItemSelected(index);
    }
  }
}
