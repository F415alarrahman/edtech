import 'dart:async';
import 'package:edtech/presentation/views/chat_room_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edtech/core/chat_repository_impl.dart';

class ChatButtonWithBadge extends StatefulWidget {
  final String otherUserId;
  const ChatButtonWithBadge({super.key, required this.otherUserId});

  @override
  State<ChatButtonWithBadge> createState() => _ChatButtonWithBadgeState();
}

class _ChatButtonWithBadgeState extends State<ChatButtonWithBadge> {
  final me = FirebaseAuth.instance.currentUser!;
  late final ChatRepository repo;
  StreamSubscription<int>? _sub;
  String? _roomId;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    repo = Get.find<ChatRepository>();
    _wire();
  }

  Future<void> _wire() async {
    // cari room direct yang sudah ada
    final rid = await repo.findDirectRoomId(me.uid, widget.otherUserId);
    if (!mounted) return;

    setState(() => _roomId = rid);

    // kalau ada, subscribe unread count
    _sub?.cancel();
    if (rid != null) {
      _sub = repo.streamUnreadCount(rid, me.uid).listen((n) {
        if (mounted) setState(() => _unread = n);
      });
    } else {
      setState(() => _unread = 0);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ElevatedButton(
          onPressed: () async {
            // buat room jika belum ada
            final roomId =
                _roomId ??
                await repo.createDirectRoom(
                  createdBy: me.uid,
                  otherId: widget.otherUserId,
                );
            // open chat
            // ignore: use_build_context_synchronously
            Get.to(() => ChatRoomView(roomId: roomId));
          },
          child: const Text('Chat'),
        ),
        if (_unread > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
