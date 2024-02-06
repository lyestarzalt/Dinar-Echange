import 'package:flutter/material.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/utils/logging.dart';
import 'package:dinar_watch/utils/enums.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

class AppInitializationProvider with ChangeNotifier {
  CurrenciesState _state = CurrenciesState.loading();

  CurrenciesState get state => _state;
  List<Currency>? get currencies => _state.currencies;

  Future<void> initializeApp() async {
    FlutterNativeSplash.preserve(
        widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
    try {
      await Firebase.initializeApp();
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );
      await requestNotificationPermissions();
      await setupFirebaseMessaging();
      await FirebaseAuth.instance.signInAnonymously();
      List<Currency> fetchedCurrencies =
          await MainRepository().getDailyCurrencies();
      _state = CurrenciesState.success(fetchedCurrencies);
    } catch (e) {
      AppLogger.logFatal('App init', error: e);
      _state = CurrenciesState.error(e.toString());
    } finally {
      FlutterNativeSplash.remove();
      notifyListeners();
    }
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // Log or handle the permissions state if needed
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // TODO Handle the foreground message.
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class CurrenciesState {
  LoadState state;
  List<Currency>? currencies;
  String? errorMessage;

  CurrenciesState._({required this.state, this.currencies, this.errorMessage});

  factory CurrenciesState.loading() =>
      CurrenciesState._(state: LoadState.loading);

  factory CurrenciesState.success(List<Currency> currencies) =>
      CurrenciesState._(state: LoadState.success, currencies: currencies);

  factory CurrenciesState.error(String message) =>
      CurrenciesState._(state: LoadState.error, errorMessage: message);
}
