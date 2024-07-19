import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:dinar_echange/utils/logging.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._();
  static RemoteConfigService get instance => _instance;
  late final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService._() {
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 12),
      ));
      await _remoteConfig
          .setDefaults({'ad_show_chance_nav': 30, 'ad_show_chance_open': 40});
      AppLogger.logInfo("Remote Config initialized with defaults.");
    } catch (e, stack) {
      AppLogger.logError("Failed to initialize Remote Config",
          error: e, stackTrace: stack);
    }
  }

  Future<int> fetchAdShowChance(String key) async {
    try {
      await _remoteConfig.fetchAndActivate();
      int chance = _remoteConfig.getInt(key);
      AppLogger.logInfo("Fetched Remote Config for $key: $chance");
      return chance;
    } catch (e, stack) {
      AppLogger.logError("Failed to fetch remote config for $key",
          error: e, stackTrace: stack);
      return _remoteConfig.getInt(key); // default value if fetch fails
    }
  }
}
