import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AppLogger {
  static final Logger _logger = Logger();
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static void logInfo(dynamic message) {
    _logger.i(message);
  }

  static void logDebug(dynamic message) {
    _logger.d(message);
  }

  static void logError(String message,
      {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: message,
      information: [],
      printDetails: true,
      fatal: false,
    );
  }

  static void logFatal(String message,
      {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: message,
      information: [],
      printDetails: true,
      fatal: true,
    );
  }

  static Future<void> trackScreenView(
      String screenName, String screenClass) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    logInfo('Screen View Logged: $screenName, Class: $screenClass');
  }


  static Future<void> logEvent(
      String eventName, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
    logInfo('Event Logged: $eventName, Details: $parameters');

  }
}
