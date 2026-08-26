import 'package:dinar_echange/data/repositories/main_repository.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:io' show Platform;
import 'package:dinar_echange/utils/state.dart';
import 'package:dinar_echange/utils/custom_exception.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/services/remote_config_service.dart';

class AppInitializationProvider with ChangeNotifier {
  AppState<List<Currency>> _parallelState = AppState.loading();
  AppState<List<Currency>> _officialState = AppState.loading();
  final AdProvider _adProvider = AdProvider();
  AppState<List<Currency>> get parallelState => _parallelState;
  AppState<List<Currency>> get officialState => _officialState;

  List<Currency>? get currencies => _parallelState.data;
  List<Currency>? get officialCurrencies => _officialState.data;

  Future<void> initializeApp() async {
    // Retry from ErrorApp lands here too: reset both states so the UI shows
    // loading instead of the previous error.
    if (_parallelState.isError || _officialState.isError) {
      _parallelState = AppState.loading();
      _officialState = AppState.loading();
      notifyListeners();
    }

    try {
      final fetched = await Future.wait([
        MainRepository().getDailyCurrencies(),
        MainRepository().getOfficialDailyCurrencies(),
      ]);
      _parallelState = AppState.success(fetched[0]);
      _officialState = AppState.success(fetched[1]);
    } catch (e, stackTrace) {
      handleInitializationError(e, stackTrace);
    } finally {
      notifyListeners();
      // Remove native splash only after this frame renders so the transition
      // goes native-splash → real UI with no blank flash in between.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
      _deferOtherInitializations();
    }
  }

  Future<void> _deferOtherInitializations() async {
    await Future.wait([
      _initializeMobileAds(),
      _enableFirebaseAnalytics(),
      _requestNotificationPermissions(),
      _setupFirebaseMessaging(),
      _loadInterstitialAd(),
      RemoteConfigService.instance.initialize()
    ])
        .then((_) => AppLogger.logInfo(
            'Deferred Firebase and related services initialized.'))
        .catchError((Object error) => AppLogger.logError(
            'Deferred initialization error',
            error: error,
            isFatal: true));
  }

  void handleInitializationError(Object? e, StackTrace stackTrace) {
    if (e is DataFetchFailureException) {
      AppLogger.logError('initializeApp: Failed during app initialization.',
          error: e, stackTrace: stackTrace, isFatal: true);
      _parallelState =
          AppState.error('Failed to load essential data: ${e.message}');
      _officialState =
          AppState.error('Failed to load essential data: ${e.message}');
    } else {
      AppLogger.logError(
          'initializeApp: Unhandled exception during initialization',
          error: e,
          stackTrace: stackTrace,
          isFatal: true);
      _parallelState =
          AppState.error('Unhandled exception during initialization');
      _officialState =
          AppState.error('Unhandled exception during initialization');
    }
  }

  Future<void> _loadInterstitialAd() async {
    try {
      _adProvider.loadInterstitialAd();

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

  Future<void> _initializeMobileAds() async {
    // iOS 14.5+ requires an ATT prompt before IDFA is available to AdMob.
    // The plugin is a no-op on Android and older iOS.
    if (Platform.isIOS) {
      final status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
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
    final messaging = FirebaseMessaging.instance;
    final prefs = PreferencesService();

    final token = await messaging.getToken();
    AppLogger.logDebug("FCM Token: $token");

    final desiredLanguage = await prefs.getSelectedLanguage() ?? 'en';
    final subscribedLanguage = await prefs.getFcmSubscribedLanguage();

    if (subscribedLanguage == desiredLanguage) {
      AppLogger.logInfo(
          "FCM: already subscribed to 'allDevices_$desiredLanguage', skipping.");
    } else if (subscribedLanguage == null) {
      // First run on this fix: purge any topic subscriptions the previous
      // "unsubscribe-all-then-resubscribe" code path may have left behind,
      // then subscribe to the current language exactly once.
      const supportedLocales = AppLocalizations.supportedLocales;
      for (final locale in supportedLocales) {
        await messaging.unsubscribeFromTopic('allDevices_${locale.languageCode}');
      }
      await messaging.subscribeToTopic('allDevices_$desiredLanguage');
      await prefs.setFcmSubscribedLanguage(desiredLanguage);
      AppLogger.logInfo(
          "FCM: migrated topic subscription to 'allDevices_$desiredLanguage'.");
    } else {
      await messaging.unsubscribeFromTopic('allDevices_$subscribedLanguage');
      await messaging.subscribeToTopic('allDevices_$desiredLanguage');
      await prefs.setFcmSubscribedLanguage(desiredLanguage);
      AppLogger.logInfo(
          "FCM: swapped topic 'allDevices_$subscribedLanguage' → 'allDevices_$desiredLanguage'.");
    }

    // Setup background message handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
