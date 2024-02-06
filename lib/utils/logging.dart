import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppLogger {
  static final Logger _logger = Logger();

  static void logInfo(dynamic message) {
    _logger.i(message);
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
}
