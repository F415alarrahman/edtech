import 'cache_store_selector.dart';

abstract class CacheStore {
  Future<void> saveMessages(String roomId, List<Map<String, dynamic>> rows);
  Future<List<Map<String, dynamic>>> loadMessages(String roomId, {int limit});
  static CacheStore? _instance;
  static Future<CacheStore> create() async {
    if (_instance != null) return _instance!;
    _instance = await createCacheStore(); // disediakan di selector
    return _instance!;
  }
}
