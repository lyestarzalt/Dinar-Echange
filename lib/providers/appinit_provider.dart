import 'package:flutter/material.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/utils/logging.dart';
import 'package:dinar_watch/utils/enums.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart';



class AppInitializationProvider with ChangeNotifier {
  CurrenciesState _state = CurrenciesState.loading();

  CurrenciesState get state => _state;
  List<Currency>? get currencies => _state.currencies;

  Future<void> initializeApp() async {
    FlutterNativeSplash.preserve(
        widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
    try {
    await Firebase.initializeApp();
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
    final fxm = await messaging.getToken();
    print(fxm);
    // Log or handle the permissions state if needed
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the message. You can show a notification or update the UI.
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

// Define a top-level named handler outside of your class for background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Make sure to initialize Firebase within the background handler
  await Firebase.initializeApp();
  // Handle the message. Note: This handler runs in background, separate from the UI thread.
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
