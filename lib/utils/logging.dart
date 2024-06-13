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
        excludePaths: ['package:dinar_echange/utils/logging.dart'],
        noBoxingByDefault: false,
        //stackTraceBeginIndex: 1,
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 80,
        colors: true,
        printEmojis: false,
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
    logDebug('Screen View Logged: $screenName, Class: $screenClass');
  }

  static Future<void> logEvent(
      String eventName, Map<String, Object> parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
    logDebug('Event Logged: $eventName, Details: $parameters');
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
