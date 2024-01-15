import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:dinar_watch/utils/logging.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      AppLogger.logInfo('Remote config: init');
      await _remoteConfig.setDefaults(<String, dynamic>{
        'force_refresh': false,
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await fetchAndActivate();
    } catch (e) {
      AppLogger.logError('Remote Config: init error', error: e);
    }
  }

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      AppLogger.logError('Remote Config: fetch and activate error', error: e);
    }
  }

  bool get forceRefresh => _remoteConfig.getBool('force_refresh');
}
