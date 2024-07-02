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
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:dinar_echange/utils/state.dart';
import 'package:dinar_echange/utils/custom_exception.dart';
import 'package:dinar_echange/providers/admob_provider.dart';

class AppInitializationProvider with ChangeNotifier {
  AppState<List<Currency>> _parallelstate = AppState.loading();
  AppState<List<Currency>> _officialState = AppState.loading();

  AppState get Paralleltate => _parallelstate;
  AppState get officialState => _officialState;

  List<Currency>? get currencies => _parallelstate.data;
  List<Currency>? get officialCurrencies => _officialState.data;

  Future<void> initializeApp() async {
    try {
      _activateAppCheck();
      await Future.wait([_signInAnonymously(), _activateAppCheck()]);

      List<List<Currency>> fetchedResults = await Future.wait([
        MainRepository().getDailyCurrencies(),
        MainRepository().getOfficialDailyCurrencies(),
      ]);

      List<Currency> fetchedCurrencies = fetchedResults[0];
      List<Currency> fetchedOfficialCurrencies = fetchedResults[1];
      _parallelstate = AppState.success(fetchedCurrencies);
      _officialState = AppState.success(fetchedOfficialCurrencies);
      FlutterNativeSplash.remove();

      _deferOtherInitializations();
    } catch (e, stackTrace) {
      handleInitializationError(e, stackTrace);
    } finally {
      notifyListeners();
    }
  }

  Future<void> _deferOtherInitializations() async {
    await Future.wait([
      _initializeMobileAds(),
      _enableFirebaseAnalytics(),
      _requestNotificationPermissions(),
      _setupFirebaseMessaging(),
      _loadInterstitialAd(),
    ])
        .then((_) => AppLogger.logInfo(
            'Deferred Firebase and related services initialized.'))
        .catchError((error) => AppLogger.logError(
            'Deferred initialization error',
            error: error,
            isFatal: true));
  }

  Future<void> handleInitializationError(
      Object? e, StackTrace stackTrace) async {
    if (e is DataFetchFailureException) {
      AppLogger.logError('initializeApp: Failed during app initialization.',
          error: e, stackTrace: stackTrace, isFatal: true);
      _parallelstate =
          AppState.error('Failed to load essential data: ${e.message}');
      _officialState =
          AppState.error('Failed to load essential data: ${e.message}');
    } else {
      AppLogger.logError(
          'initializeApp: Unhandled exception during initialization',
          error: e,
          stackTrace: stackTrace,
          isFatal: true);
      _parallelstate =
          AppState.error('Unhandled exception during initialization');
      _officialState =
          AppState.error('Unhandled exception during initialization');
    }
  }

  Future<void> _loadInterstitialAd() async {
    try {
      final adProvider = AdProvider();
      adProvider.loadInterstitialAd();
      AppLogger.logInfo('InterstitialAd loading initiated.');
    } catch (error, stackTrace) {
      AppLogger.logError('Failed to load InterstitialAd.',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _enableFirebaseAnalytics() async {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    AppLogger.logInfo('Firebase Analytics collection enabled.');
  }

  Future<void> _activateAppCheck() async {
    if (kReleaseMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        //appleProvider: AppleProvider.deviceCheck,
      );
      AppLogger.logInfo('App Check activated: production');
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        //appleProvider: AppleProvider.debug,
      );
      AppLogger.logInfo('App Check activated: debug');
      try {
        String? token = await FirebaseAppCheck.instance.getToken(false);
        AppLogger.logDebug("Temp token: $token");
      } catch (e) {
        AppLogger.logError('Error fetching App Check token: $e');
        // Implement a fallback mechanism or exponential backoff retry logic if needed
      }
    }
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
    AppLogger.logDebug("FCM Token: $token");
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
