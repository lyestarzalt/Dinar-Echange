import 'dart:ui';
import 'package:dinar_echange/data/repositories/main_repository.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:dinar_echange/utils/state.dart';
import 'package:dinar_echange/utils/FirebaseErrorInterpreter.dart';
import 'package:dinar_echange/providers/admob_provider.dart';

class AppInitializationProvider with ChangeNotifier {
  AppState<List<Currency>> _state = AppState.loading();
  AppState get state => _state;
  List<Currency>? get currencies => _state.data;

   Future<void> initializeApp() async {
    final overallStopwatch = Stopwatch()..start();
    try {
      // Initialize Firebase and related services
      await Future.wait([
        _enableFirebaseAnalytics(),
        _activateAppCheck(),
        _initializeMobileAds(),
        _requestNotificationPermissions(),
        _signInAnonymously(),
      ]);
      AppLogger.logInfo('Firebase and related services initialized.');

      // Start Firebase Messaging setup asynchronously
      _setupFirebaseMessaging().catchError((error) {
        AppLogger.logFatal('Failed to setup Firebase Messaging', error: error);
      });

      // Check and handle terms conditions synchronously
      bool termsAccepted = await _checkAndHandleTermsConditions();
      if (!termsAccepted) {
        return; // Stop initialization if terms are not accepted
      }

      // Fetch Daily Currencies once terms are accepted
      final currenciesStopwatch = Stopwatch()..start();
      List<Currency> fetchedCurrencies =
          await MainRepository().getDailyCurrencies();
      _state = AppState.success(fetchedCurrencies);
      currenciesStopwatch.stop();
      AppLogger.logInfo(
          'Fetched daily currencies in ${currenciesStopwatch.elapsedMilliseconds} ms');
    } catch (e, stackTrace) {
      handleInitializationError(e, stackTrace);
    } finally {
      FlutterNativeSplash.remove();
      notifyListeners();
      overallStopwatch.stop();
      AppLogger.logInfo('App initialization process completed.');
    }
  }
  Future<bool> _checkAndHandleTermsConditions() async {
    bool acceptedTerms = await _checkTermsAndConditions();
    if (!acceptedTerms) {
      _state = AppState.error('Terms not accepted');
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> _checkTermsAndConditions() async {
    return await PreferencesService().hasAcceptedTerms();
  }
  

  Future<void> handleInitializationError(e, stackTrace) async {
    final errorResult = FirebaseErrorInterpreter.interpret(e as Exception);
    AppLogger.logFatal(
      'initializeApp: Failed during app initialization. Error: ${errorResult.message}',
      error: e,
      stackTrace: stackTrace,
    );

    if (errorResult.canContinue) {
      final fetchedCurrencies = await MainRepository().getDailyCurrencies();
      _state = AppState.success(fetchedCurrencies);
    } else {
      _state = AppState.error(errorResult.message);
    }
  }

  Future<void> _enableFirebaseAnalytics() async {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    AppLogger.logInfo('Firebase Analytics collection enabled.');
  }

  Future<void> _activateAppCheck() async {
    await FirebaseAppCheck.instance
        .activate(androidProvider: AndroidProvider.debug);
    AppLogger.logInfo('App Check activated.');
  }

  Future<void> _initializeMobileAds() async {
    MobileAds.instance.initialize();
    AppLogger.logInfo('MobileAds activated.');
  }

  Future<void> _requestNotificationPermissions() async {
    await requestNotificationPermissions();
    AppLogger.logInfo('Notification permissions requested.');
  }

  Future<void> _setupFirebaseMessaging() async {
    await setupFirebaseMessaging();
    AppLogger.logInfo('Firebase Messaging setup completed.');
  }

  Future<void> _signInAnonymously() async {
    await FirebaseAuth.instance.signInAnonymously();
    AppLogger.logInfo('Signed in anonymously to Firebase Auth.');
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
