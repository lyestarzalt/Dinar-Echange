import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:dinar_echange/utils/logging.dart';

class CacheManager {
  Future<void> setCache(String key, Map<String, dynamic> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      data['timestamp'] = DateTime.now().toUtc().millisecondsSinceEpoch;
      final String jsonData = json.encode(data);
      await prefs.setString(key, jsonData);
      AppLogger.logInfo('setCache: Successfully set cache for key: $key');
    } catch (e, stackTrace) {
      AppLogger.logError(
        'setCache: Failed to set cache for key: $key. Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCache(String key) async {
    try {
      final String? cachedData = await PreferencesService().getString(key);
      if (cachedData != null) {
        final Map<String, dynamic> decodedData =
            json.decode(cachedData) as Map<String, dynamic>;

        if (isCacheValid(decodedData)) {
          AppLogger.logInfo(
              'getCache: Successfully retrieved cache for key: $key');
          return decodedData;
        } else {
          AppLogger.logInfo(
              'getCache: Cache data invalid or expired for key: $key');
        }
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.logError(
        'getCache: Failed to retrieve cache for key: $key. Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
    return false;
  }

  bool isCacheDateValid(Map<String, dynamic> cachedData) {
    DateTime cachedDate =
        DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']).toUtc();
    DateTime currentDateInAlgeriaTime = getCurrentDateInAlgeriaTime();

    bool isBeforeUpdateTime = currentDateInAlgeriaTime.hour < 9;
    bool isPreviousDayCache =isPreviousDay(cachedDate, currentDateInAlgeriaTime);
    bool isSameDayCache = isSameDay(cachedDate, currentDateInAlgeriaTime);

    return isSameDayCache || (isPreviousDayCache && isBeforeUpdateTime);
  }


bool isDataNotEmpty(Map<String, dynamic> cachedData) {
    if (cachedData.containsKey('data')) {
      var data = cachedData['data'];
      if (data is List) {
        // For a list of currencies, we check that it's not empty.
        return data.isNotEmpty;
      } else if (data is Map<String, dynamic>) {
        // For a single currency with history, we check for non-empty history.
        return data.containsKey('history') &&
            data['history'] is List &&
            data['history'].isNotEmpty;
      }
    }
    // Default to false if none of the above conditions are met.
    return false;
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
