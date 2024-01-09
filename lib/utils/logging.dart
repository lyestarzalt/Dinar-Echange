import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger();

  static void logInfo(dynamic message) {
    _logger.i(message);
  }

  static void logError(String message,
      {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void logFatal(String message,
      {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
