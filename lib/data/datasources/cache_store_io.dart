import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:edtech/data/models/isar_models.dart';
import 'cache_store.dart';

class IsarCacheStore implements CacheStore {
  final Isar _isar;
  IsarCacheStore(this._isar);

  @override
  Future<void> saveMessages(
    String roomId,
    List<Map<String, dynamic>> rows,
  ) async {
    await _isar.writeTxn(() async {
      final old = await _isar.cachedMessages
          .filter()
          .roomIdEqualTo(roomId)
          .sortByCreatedAtDesc()
          .findAll();
      for (var i = 20; i < old.length; i++) {
        await _isar.cachedMessages.delete(old[i].id);
      }
      for (final m in rows.take(20)) {
        await _isar.cachedMessages.put(
          CachedMessage()
            ..msgId = m['id'] as String
            ..roomId = m['roomId'] as String
            ..authorId = m['authorId'] as String
            ..text = (m['text'] as String?) ?? ''
            ..type = m['type'] as String
            ..createdAt = m['createdAt'] as DateTime,
        );
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> loadMessages(
    String roomId, {
    int limit = 20,
  }) async {
    final list = await _isar.cachedMessages
        .filter()
        .roomIdEqualTo(roomId)
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
    return list
        .map(
          (c) => {
            'id': c.msgId,
            'roomId': c.roomId,
            'authorId': c.authorId,
            'text': c.text,
            'type': c.type,
            'createdAt': c.createdAt,
          },
        )
        .toList();
  }
}

Future<CacheStore> createCacheStore() async {
  const name = 'edtech_cache';
  final existing = Isar.getInstance(name);
  if (existing != null) return IsarCacheStore(existing);

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [CachedUserSchema, CachedMessageSchema],
    directory: dir.path,
    name: name,
  );
  return IsarCacheStore(isar);
}
