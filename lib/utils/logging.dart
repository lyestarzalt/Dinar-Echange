import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 80,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static void logInfo(dynamic message) {
    if (kReleaseMode) return;
    _instance._logger.i(message);
  }

  /// Debug log. Fully compiled out in release: neither the string nor
  /// the underlying logger call executes, so callers can freely
  /// interpolate expensive values without paying for them in release.
  static void logDebug(dynamic message) {
    if (kReleaseMode) return;
    _instance._logger.d(message);
  }

  /// Records an error.
  ///
  /// In debug: pretty-prints the error + stack via the logger package.
  /// In release: forwarded to Sentry unless [reportToSentry] is false.
  ///   Use `reportToSentry: false` for expected / already-handled failure
  ///   paths (ad load failures, offline network, missing history,
  ///   asset fallback taken) so the Sentry issue list stays a real
  ///   signal instead of noise.
  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool isFatal = false,
    bool reportToSentry = true,
  }) {
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
    if (!reportToSentry) return;
    final level = isFatal ? SentryLevel.fatal : SentryLevel.error;
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.level = level;
          scope.setContexts('log', {'message': message});
        },
      );
    } else {
      Sentry.captureMessage(message, level: level);
    }
  }

  static Future<void> trackScreenView(
      String screenName, String screenClass) async {
    if (kReleaseMode) {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } else {
      _instance._logger
          .d('Screen View Logged: $screenName, Class: $screenClass');
    }
  }

  static Future<void> logEvent(
      String eventName, Map<String, Object> parameters) async {
    if (kReleaseMode) {
      await _analytics.logEvent(name: eventName, parameters: parameters);
    } else {
      _instance._logger.d('Event Logged: $eventName, Details: $parameters');
    }
  }
}

class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.error.index;
    } else {
      return true;
    }
  }
}
