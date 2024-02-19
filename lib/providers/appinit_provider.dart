import 'dart:ui';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/utils/logging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:dinar_watch/utils/state.dart';
import 'package:dinar_watch/utils/FirebaseErrorInterpreter.dart';
import 'package:dinar_watch/providers/admob_provider.dart';

class AppInitializationProvider with ChangeNotifier {
  AppState<List<Currency>> _state = AppState.loading();
  AppState get state => _state;
  List<Currency>? get currencies => _state.data;

  Future<void> initializeApp() async {
    try {
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      AppLogger.logInfo('Firebase Analytics collection enabled.');

      await FirebaseAppCheck.instance
          .activate(androidProvider: AndroidProvider.debug);

      MobileAds.instance.initialize();

      AppLogger.logInfo('MobileAds activated.');

      await requestNotificationPermissions();
      AppLogger.logInfo('Notification permissions requested.');

      await setupFirebaseMessaging();
      AppLogger.logInfo('Firebase Messaging setup completed.');

      await FirebaseAuth.instance.signInAnonymously();
      AppLogger.logInfo('Signed in anonymously to Firebase Auth.');

      List<Currency> fetchedCurrencies =
          await MainRepository().getDailyCurrencies();
    
    
    
      _state = AppState.success(fetchedCurrencies);
      AppLogger.logInfo('Fetched daily currencies successfully.');
    
    
    
    } catch (e, stackTrace) {
      final errorResult = FirebaseErrorInterpreter.interpret(e as Exception);
      AppLogger.logFatal(
          'initializeApp: Failed during app initialization. Error: ${errorResult.message}',
          error: e,
          stackTrace: stackTrace);

      if (errorResult.canContinue) {
        List<Currency> fetchedCurrencies =
            await MainRepository().getDailyCurrencies();
        _state = AppState.success(fetchedCurrencies);
      }
      _state = AppState.error(errorResult.message);
    } finally {
      FlutterNativeSplash.remove();
      notifyListeners();
      AppLogger.logInfo('initializeApp: App initialization process completed.');
    }
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    AppLogger.logInfo("FCM Token: $token");
    const List<Locale> supportedLocales = AppLocalizations.supportedLocales;

    List<String> languageTopics = supportedLocales
        .map((locale) => 'allDevices_${locale.languageCode}')
        .toList();

    // Unsubscribe from all language topics
    for (String topic in languageTopics) {
      await messaging.unsubscribeFromTopic(topic);
    }

    String languageCode =
        await PreferencesService().getSelectedLanguage() ?? 'en';
    String topic = 'allDevices_$languageCode';

    await messaging.subscribeToTopic(topic);
    AppLogger.logInfo("Subscribed to '$topic' topic");

    // Setup background message handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
