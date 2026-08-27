import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        // Selector rebuilds only when the tab index actually changes;
        // AppProvider notifies for theme / locale / package-info no
        // longer rebuild the tab switcher or the bottom nav.
        body: Selector<AppProvider, int>(
          selector: (_, p) => p.selectedIndex,
          builder: (context, selectedIndex, _) {
            final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
            final reducedMotion = MediaQuery.disableAnimationsOf(context);
            return PageTransitionSwitcher(
              duration: reducedMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 400),
              transitionBuilder: (child, animation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  fillColor: scaffoldBg,
                  child: child,
                );
              },
              child: _getPageWidget(context, selectedIndex),
            );
          },
        ),
        bottomNavigationBar: Selector<AppProvider, int>(
          selector: (_, p) => p.selectedIndex,
          builder: (context, selectedIndex, _) {
            return MainNavigation(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                Provider.of<AppProvider>(context, listen: false)
                    .selectedIndex = index;
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

bool shouldShowAd(String type) {
  final chance = RemoteConfigService.instance.fetchAdShowChance(type);
  return Random().nextInt(100) < chance;
}

class MainNavigation extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemSelected;
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
      BuildContext context, int index, AdProvider adProvider) {
    HapticFeedback.selectionClick();
    if (shouldShowAd('ad_show_chance_nav') && adProvider.isInterstitialAdLoaded) {
      adProvider.showInterstitialAd();
      adProvider.onAdDismissed(() => onItemSelected(index));
    } else {
      onItemSelected(index);
    }
  }
}
