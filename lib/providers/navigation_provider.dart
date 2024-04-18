import 'package:flutter/material.dart';
import 'package:dinar_echange/utils/logging.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  NavigationProvider();

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
    AppLogger.trackScreenView(getScreenNameByIndex(index));
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
