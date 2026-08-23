import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:dinar_echange/utils/logging.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._();
  static RemoteConfigService get instance => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  RemoteConfigService._();

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 12),
      ));
      await _remoteConfig
          .setDefaults({'ad_show_chance_nav': 30, 'ad_show_chance_open': 40});
      AppLogger.logInfo("Remote Config initialized with defaults.");

      // Kick the network fetch off in the background. Any callers running
      // before it lands read the defaults; callers after it lands read the
      // freshly-activated values. Nothing user-visible ever waits on the
      // network here.
      unawaited(_refreshInBackground());
    } catch (e, stack) {
      AppLogger.logError("Failed to initialize Remote Config",
          error: e, stackTrace: stack);
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      AppLogger.logInfo(
          "Remote Config fetch completed (activated new values: $activated).");
    } catch (e, stack) {
      AppLogger.logError("Remote Config background refresh failed",
          error: e, stackTrace: stack);
    }
  }

  // Kept async for backwards compatibility with existing `await` call sites;
  // now reads the currently-active value (default or last-fetched) without
  // touching the network.
  Future<int> fetchAdShowChance(String key) async {
    final chance = _remoteConfig.getInt(key);
    AppLogger.logInfo("Remote Config read $key: $chance");
    return chance;
  }
}
