import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheManager {
  
  Future<Map<String, dynamic>?> getCache(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString(key);
    if (cachedData != null) {
      return json.decode(cachedData) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> setCache(String key, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(data);
    await prefs.setString(key, jsonData);
  }

bool isCacheValid(Map<String, dynamic> cachedData) {
    DateTime cachedDate = DateTime.parse(cachedData['dateSaved']).toUtc();
    DateTime nowUtc = DateTime.now().toUtc();

    // Algeria's timezone offset (UTC+1)
    const int algeriaTimezoneOffset = 1;
    DateTime cachedDateInAlgeriaTime =
        cachedDate.add(const Duration(hours: algeriaTimezoneOffset));
    DateTime currentDateInAlgeriaTime =
        nowUtc.add(const Duration(hours: algeriaTimezoneOffset));

    return currentDateInAlgeriaTime
            .difference(cachedDateInAlgeriaTime)
            .inDays ==
        0;
  }
}
