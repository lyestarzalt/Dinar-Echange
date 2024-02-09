import 'package:firebase_analytics/firebase_analytics.dart';
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Tracks screen views
  static Future<void> trackScreenView({
    required String screenName,
    String screenClassOverride = 'FlutterScreen',
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }
}

