import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheManager {
  Future<Map<String, dynamic>?> getCache(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? cachedData = prefs.getString(key);
  

      if (cachedData != null) {
        return json.decode(cachedData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      
      return null;
    }
  }

  Future<void> setCache(String key, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Add the current timestamp to the data before caching
    data['timestamp'] = DateTime.now().toUtc().millisecondsSinceEpoch;

    String jsonData = json.encode(data);
    await prefs.setString(key, jsonData);
  }

  bool isCacheValid(Map<String, dynamic> cachedData) {
    int cachedTimestamp = cachedData['timestamp'] as int;
    DateTime cachedDate =
        DateTime.fromMillisecondsSinceEpoch(cachedTimestamp).toUtc();
    DateTime nowUtc = DateTime.now().toUtc();

    // Algeria's timezone offset (UTC+1)
    const int algeriaTimezoneOffset = 1;
    DateTime cachedDateInAlgeriaTime =
        cachedDate.add(const Duration(hours: algeriaTimezoneOffset));
    DateTime currentDateInAlgeriaTime =
        nowUtc.add(const Duration(hours: algeriaTimezoneOffset));

    // Check if 'data' key is not an empty list
    //TODO: Fix this
    bool isDataNotEmpty = (cachedData.containsKey('data') &&
            cachedData['data'] is List &&
            (cachedData['data'] as List).isNotEmpty) ||
        (cachedData.containsKey('history') &&
            cachedData['history'] is List &&
            (cachedData['history'] as List).isNotEmpty);

    // Check if the cached data is from the same day (considering Algeria's timezone) and 'data' is not empty
    return currentDateInAlgeriaTime
                .difference(cachedDateInAlgeriaTime)
                .inDays ==
            0 &&
        isDataNotEmpty;
  }
}
