import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight local cache used for:
/// - offline viewing of the last-loaded feed/communities/notifications
/// - settings (theme, language, notification prefs)
/// - draft posts/comments
///
/// Deliberately uses plain Hive boxes (Map<String,dynamic> JSON storage)
/// instead of typed Hive adapters so NO build_runner / code generation
/// step is required. Run `flutter pub get` and the app just works.
class LocalCache {
  LocalCache._();

  static const String settingsBox = 'settings_box';
  static const String feedCacheBox = 'feed_cache_box';
  static const String communitiesCacheBox = 'communities_cache_box';
  static const String notificationsCacheBox = 'notifications_cache_box';
  static const String draftsBox = 'drafts_box';
  static const String searchHistoryBox = 'search_history_box';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(settingsBox),
      Hive.openBox(feedCacheBox),
      Hive.openBox(communitiesCacheBox),
      Hive.openBox(notificationsCacheBox),
      Hive.openBox(draftsBox),
      Hive.openBox(searchHistoryBox),
    ]);
  }

  static Box box(String name) => Hive.box(name);

  /// Cache a list of JSON-encodable maps under [key] in [boxName].
  static Future<void> cacheList(
      String boxName, String key, List<Map<String, dynamic>> items) async {
    await box(boxName).put(key, items);
  }

  static List<Map<String, dynamic>> readList(String boxName, String key) {
    final raw = box(boxName).get(key);
    if (raw == null) return [];
    return (raw as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> clearAll() async {
    await Hive.box(feedCacheBox).clear();
    await Hive.box(communitiesCacheBox).clear();
    await Hive.box(notificationsCacheBox).clear();
    await Hive.box(draftsBox).clear();
  }
}
