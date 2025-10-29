import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/cache_store.dart';
import '../../core/chat_repository_impl.dart';
import '../../domain/entities/chat_entities.dart';

class ChatRoomController extends GetxController {
  final String roomId;
  ChatRoomController({required this.roomId});

  // Deps
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  late final ChatRepository _repo;

  // UI state (semua di controller biar view stateless)
  final TextEditingController textCtrl = TextEditingController();
  final RxBool booted = false.obs;

  // Chat state
  final RxList<MessageEntity> messages = <MessageEntity>[].obs;
  final RxList<String> members = <String>[].obs;

  // Internals
  StreamSubscription? _msgSub;
  StreamSubscription? _roomSub;
  Timer? _readDebounce;
  bool _closed = false;

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  Future<void> _boot() async {
    // Build repo dari CacheStore (tanpa Stateful di View)
    final cache = await CacheStore.create();
    _repo = ChatRepository(cache);

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      booted.value = true; // tetap booted agar UI gak loading terus
      return;
    }

    // 1) Stream members
    _roomSub = _db.collection('rooms').doc(roomId).snapshots().listen((d) {
      final m =
          (d.data()?['members'] as List?)?.map((e) => e as String).toList() ??
          <String>[];
      members.assignAll(m);
    });

    // 2) Stream messages
    _msgSub = _repo
        .streamMessages(roomId)
        .listen(
          (list) async {
            if (_closed) return;
            messages.assignAll(list);

            // tandai delivered utk pesan lawan bicara
            final myUid = uid;
            final toDeliver = list.where(
              (m) => m.authorId != myUid && !m.deliveredTo.containsKey(myUid),
            );
            if (toDeliver.isNotEmpty) {
              await Future.wait(
                toDeliver.map((m) => _repo.markDelivered(roomId, m.id, myUid)),
              );
            }

            // debounce mark read
            _readDebounce?.cancel();
            _readDebounce = Timer(const Duration(milliseconds: 800), () async {
              if (_closed) return;
              await _repo.markRoomRead(roomId, uid);
            });
          },
          onError: (_) async {
            if (_closed) return;
            final cached = await _repo.loadCachedMessages(roomId);
            messages.assignAll(cached);
          },
        );

    booted.value = true;
  }

  Future<void> sendText() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final t = textCtrl.text.trim();
    if (t.isEmpty) return;

    await _repo.sendText(roomId, uid, t);
    await _repo.markRoomRead(roomId, uid);
    textCtrl.clear();
  }

  Future<void> sendAction(String label) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final l = label.trim();
    if (l.isEmpty) return;
    await _repo.sendActionCard(roomId, uid, l);
  }

  @override
  void onClose() {
    _closed = true;
    _readDebounce?.cancel();
    _msgSub?.cancel();
    _roomSub?.cancel();
    textCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }

  final scrollCtrl = ScrollController();
}
