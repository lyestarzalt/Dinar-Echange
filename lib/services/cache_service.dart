import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:dinar_watch/services/remote_config.dart';
import 'package:dinar_watch/utils/logging.dart';

class CacheManager {
  Future<void> setCache(String key, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    data['timestamp'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    final String jsonData = json.encode(data);
    await prefs.setString(key, jsonData);
  }

  Future<Map<String, dynamic>?> getCache(String key) async {
    final String? cachedData = await PreferencesService().getString(key);
    if (cachedData != null) {
      final Map<String, dynamic> decodedData =
          json.decode(cachedData) as Map<String, dynamic>;

      // Check if the cache is still valid
      if (isCacheValid(decodedData)) {
        return decodedData;
      }
    }
    return null;
  }

  bool isCacheValid(Map<String, dynamic> cachedData) {
    if (shouldBypassCache(cachedData)) {
      return false;
    }
    return isCacheDateValid(cachedData) && isDataNotEmpty(cachedData);
  }

  String generateCacheKey(String base, {String? suffix}) {
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return suffix != null ? '${base}_${suffix}_$dateKey' : '${base}_$dateKey';
  }

 

  bool shouldBypassCache(Map<String, dynamic> cachedData) {
    bool forceRefresh = RemoteConfigService().forceRefresh;
    AppLogger.logInfo('Bypass cache? $forceRefresh');
    return forceRefresh || !cachedData.containsKey('timestamp');
  }

  bool isCacheDateValid(Map<String, dynamic> cachedData) {
    DateTime cachedDate =
        DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']).toUtc();
    DateTime currentDateInAlgeriaTime = getCurrentDateInAlgeriaTime();

    bool isBeforeUpdateTime = currentDateInAlgeriaTime.hour < 9;
    bool isPreviousDayCache =
        isPreviousDay(cachedDate, currentDateInAlgeriaTime);
    bool isSameDayCache = isSameDay(cachedDate, currentDateInAlgeriaTime);

    return isSameDayCache || (isPreviousDayCache && isBeforeUpdateTime);
  }

  bool isDataNotEmpty(Map<String, dynamic> cachedData) {
    return cachedData.entries.any((entry) =>
        (entry.key == 'data' || entry.key == 'history') &&
        entry.value is List &&
        (entry.value as List).isNotEmpty);
  }

  DateTime getCurrentDateInAlgeriaTime() {
    const int algeriaTimezoneOffset = 1;
    return DateTime.now()
        .toUtc()
        .add(const Duration(hours: algeriaTimezoneOffset));
  }

  bool isPreviousDay(DateTime cachedDate, DateTime currentDate) {
    return cachedDate.day == currentDate.subtract(const Duration(days: 1)).day;
  }

  bool isSameDay(DateTime cachedDate, DateTime currentDate) {
    return cachedDate.day == currentDate.day;
  }
}
