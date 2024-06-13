import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final AppLogger _instance = AppLogger._internal();
  late final Logger _logger;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _logger = Logger(
      filter: CustomLogFilter(),
      printer: PrettyPrinter(
        methodCount: kReleaseMode ? 0 : 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: !kReleaseMode,
        printEmojis: !kReleaseMode,
        printTime: true,
      ),
    );
  }
  static void logInfo(dynamic message) {
    _instance._logger.i(message);
  }

  static void logDebug(dynamic message) {
    _instance._logger.d(message);
  }

  static void logError(String message,
      {Object? error, StackTrace? stackTrace, bool isFatal = false}) {
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: message,
      fatal: isFatal,
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

class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      // In release mode, only log events that are errors or more severe
      return event.level.index >= Level.error.index;
    } else {
      return true;
    }
  }
}
