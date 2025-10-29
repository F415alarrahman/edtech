import 'cache_store.dart';

class WebCacheStore implements CacheStore {
  final Map<String, List<Map<String, dynamic>>> _mem = {};
  @override
  Future<void> saveMessages(
    String roomId,
    List<Map<String, dynamic>> rows,
  ) async {
    _mem[roomId] = rows.take(20).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> loadMessages(
    String roomId, {
    int limit = 20,
  }) async {
    return (_mem[roomId] ?? const []).take(limit).toList();
  }
}

Future<CacheStore> createCacheStore() async => WebCacheStore();
