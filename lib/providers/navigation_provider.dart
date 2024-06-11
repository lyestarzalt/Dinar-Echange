import 'package:flutter/material.dart';
import 'package:dinar_echange/utils/logging.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  NavigationProvider();

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
     AppLogger.trackScreenView(
      getScreenNameByIndex(index),
       getScreenClassByIndex(index),
    );
  }

   String getScreenNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'MainCurrencyList_Screen';
      case 1:
        return 'Trends_Screen';
      case 2:
        return 'Settings_Screen';
      default:
        return 'Unknown_Screen';
    }
  }

  String getScreenClassByIndex(int index) {
    switch (index) {
      case 0:
        return 'MainList';
      case 1:
        return 'Trends';
      case 2:
        return 'Settings'; 
      default:
        return 'UnknownClass';
    }
  }
}
