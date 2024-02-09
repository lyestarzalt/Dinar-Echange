import 'package:flutter/material.dart';
import 'package:dinar_watch/utils/analytics_service.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  NavigationProvider();

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
    // Call trackScreenView with the screen name based on the current index
    AnalyticsService.trackScreenView(screenName: getScreenNameByIndex(index));
  }

  String getScreenNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'CurrencyListScreen';
      case 1:
        return 'HistoryPage';
      case 2:
        return 'SettingsPage';
      default:
        return 'UnknownScreen';
    }
  }
}
