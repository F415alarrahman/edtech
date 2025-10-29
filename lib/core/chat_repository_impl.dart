import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:edtech/data/datasources/cache_store.dart';
import '../../domain/entities/chat_entities.dart';

class ChatRepository {
  final _db = FirebaseFirestore.instance;
  final CacheStore _cache;
  ChatRepository(this._cache);

  // =========================
  // ROOMS
  // =========================
  Stream<List<RoomEntity>> streamMyRooms(String uid) {
    return _db
        .collection('rooms')
        .where('members', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final m = (d['members'] as List).map((e) => e as String).toList();
            return RoomEntity(id: d.id, type: d['type'] ?? 'group', members: m);
          }).toList(),
        );
  }

  Future<String> createTrioRoom({
    required String createdBy,
    required String tutorId,
    required String parentId,
    required String studentId,
  }) async {
    final members = [tutorId, parentId, studentId]..sort(); // deterministik
    final doc = _db.collection('rooms').doc();
    await doc.set({
      'id': doc.id,
      'type': 'trio',
      'members': members,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> createDirectRoom({
    required String createdBy,
    required String otherId,
  }) async {
    final members = [createdBy, otherId]..sort();

    // coba reuse kalau sudah ada
    final q = await _db
        .collection('rooms')
        .where('type', isEqualTo: 'direct')
        .where('members', arrayContains: createdBy)
        .get();

    for (final d in q.docs) {
      final m = (d['members'] as List).cast<String>()..sort();
      if (listEquals(m, members)) {
        return d.id;
      }
    }

    final doc = _db.collection('rooms').doc();
    await doc.set({
      'id': doc.id,
      'type': 'direct',
      'members': members,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // =========================
  // MESSAGES
  // =========================
  Stream<List<MessageEntity>> streamMessages(String roomId, {int limit = 50}) {
    Map<String, DateTime> _toMap(dynamic m) {
      if (m is Map) {
        return m.map<String, DateTime>(
          (k, v) => MapEntry(
            k.toString(),
            (v is Timestamp) ? v.toDate() : DateTime.now(),
          ),
        );
      }
      return {};
    }

    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) async {
          final list = snap.docs.map((d) {
            final data = d.data();
            final ts = data['createdAt'];
            final created = ts is Timestamp ? ts.toDate() : DateTime.now();

            return MessageEntity(
              id: d.id,
              roomId: roomId,
              authorId: data['authorId'],
              text: data['text'] ?? '',
              createdAt: created,
              type: data['type'],
              deliveredTo: _toMap(data['deliveredTo']),
              readBy: _toMap(data['readBy']),
            );
          }).toList();

          // cache 20 terakhir
          await _cache.saveMessages(
            roomId,
            list
                .take(20)
                .map(
                  (m) => {
                    'id': m.id,
                    'roomId': m.roomId,
                    'authorId': m.authorId,
                    'text': m.text,
                    'type': m.type,
                    'createdAt': m.createdAt,
                  },
                )
                .toList(),
          );

          return list;
        })
        .asyncMap((f) async => await f);
  }

  // OFFLINE read ketika error/offline
  Future<List<MessageEntity>> loadCachedMessages(
    String roomId, {
    int limit = 20,
  }) async {
    final raw = await _cache.loadMessages(roomId, limit: limit);
    return raw
        .map(
          (c) => MessageEntity(
            id: c['id'] as String,
            roomId: c['roomId'] as String,
            authorId: c['authorId'] as String,
            text: (c['text'] as String?) ?? '',
            createdAt: (c['createdAt'] as DateTime),
            type: c['type'] as String,
          ),
        )
        .toList();
  }

  // =========================
  // RECEIPTS (delivered/read) & UNREAD
  // =========================
  Future<void> markDelivered(
    String roomId,
    String messageId,
    String uid,
  ) async {
    final ref = _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);
    await ref.set({
      'deliveredTo': {uid: FieldValue.serverTimestamp()},
    }, SetOptions(merge: true));
  }

  Future<void> markRoomRead(String roomId, String uid) async {
    // update participants lastReadAt
    final pRef = _db
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .doc(uid);
    await pRef.set({
      'lastReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // tandai read pada pesan lawan (batasi 50 terakhir)
    final q = await _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .where('authorId', isNotEqualTo: uid)
        .orderBy('authorId') // syarat Firestore utk isNotEqualTo
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final batch = _db.batch();
    for (final d in q.docs) {
      final readBy = (d.data()['readBy'] ?? {}) as Map;
      if (!readBy.containsKey(uid)) {
        batch.set(d.reference, {
          'readBy': {uid: FieldValue.serverTimestamp()},
        }, SetOptions(merge: true));
      }
    }
    await batch.commit();
  }

  Future<String?> findDirectRoomId(String uidA, String uidB) async {
    final members = [uidA, uidB]..sort();
    final q = await _db
        .collection('rooms')
        .where('type', isEqualTo: 'direct')
        .where('members', arrayContains: uidA)
        .get();

    for (final d in q.docs) {
      final m = (d['members'] as List).cast<String>()..sort();
      if (listEquals(m, members)) return d.id;
    }
    return null;
  }

  Future<void> _bumpRoomMeta({
    required String roomId,
    required String authorId,
    required String preview,
  }) async {
    await _db.collection('rooms').doc(roomId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageBy': authorId,
      'lastMessageText': preview,
    });
  }

  Future<void> sendText(String roomId, String uid, String text) async {
    final msgRef = _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc();
    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'id': msgRef.id,
        'authorId': uid,
        'text': text,
        'type': 'text',
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(_db.collection('rooms').doc(roomId), {
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageBy': uid,
        'lastMessageText': text.length > 80
            ? '${text.substring(0, 80)}…'
            : text,
      });
    });
  }

  Future<void> sendActionCard(String roomId, String uid, String label) async {
    final msgRef = _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc();
    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'id': msgRef.id,
        'authorId': uid,
        'text': label,
        'type': 'action',
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(_db.collection('rooms').doc(roomId), {
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageBy': uid,
        'lastMessageText': label,
      });
    });
  }

  // hitung unread via query (createdAt > lastReadAt && authorId != me)
  // TANPA rxdart: pakai asyncExpand (setara switchMap)
  Stream<int> streamUnreadCount(String roomId, String uid) {
    final pRef = _db
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .doc(uid);

    return pRef.snapshots().asyncExpand((pSnap) {
      final lastRead =
          (pSnap.data()?['lastReadAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final q = _db
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .where('authorId', isNotEqualTo: uid)
          .where('createdAt', isGreaterThan: lastRead)
          .orderBy('authorId')
          .orderBy('createdAt', descending: true);

      return q.snapshots().map((s) => s.size);
    });
  }

  Stream<List<RoomEntity>> streamMyRoomsSorted(String uid) {
    return _db
        .collection('rooms')
        .where('members', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true) // kunci urutan
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final m = (d['members'] as List).cast<String>();
            final hasLast = d.data().containsKey('lastMessageAt');
            final ts = hasLast
                ? (d['lastMessageAt'] is Timestamp
                      ? (d['lastMessageAt'] as Timestamp).toDate()
                      : null)
                : null;
            return RoomEntity(
              id: d.id,
              type: d['type'] ?? 'group',
              members: m,
              lastMessageAt: ts,
              lastMessageBy: d.data()['lastMessageBy'],
              lastMessageText: d.data()['lastMessageText'],
            );
          }).toList(),
        );
  }
}
