import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:intl/intl.dart';

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

  String generateCacheKey(String base, {String? suffix}) {
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return suffix != null ? '${base}_${suffix}_$dateKey' : '${base}_$dateKey';
  }

  bool isCacheValid(Map<String, dynamic> cachedData) {
    if (!cachedData.containsKey('timestamp')) return false;

    DateTime cachedDate =
        DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']).toUtc();
    DateTime nowUtc = DateTime.now().toUtc();

    // Algeria's timezone offset (UTC+1)
    const int algeriaTimezoneOffset = 1;
    DateTime cachedDateInAlgeriaTime =
        cachedDate.add(const Duration(hours: algeriaTimezoneOffset));
    DateTime currentDateInAlgeriaTime =
        nowUtc.add(const Duration(hours: algeriaTimezoneOffset));

    // Check if the cached data is from the same day (Algeria timezone)
    bool isSameDay =
        currentDateInAlgeriaTime.day == cachedDateInAlgeriaTime.day;

    // Check if 'data' or 'history' key is not an empty list
    bool isDataNotEmpty = cachedData.entries.any((entry) =>
        entry.key == 'data' ||
        entry.key == 'history' &&
            entry.value is List &&
            (entry.value as List).isNotEmpty);

    return isSameDay && isDataNotEmpty;
  }
}
