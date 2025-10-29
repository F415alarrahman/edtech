import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/chat_entities.dart';
import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final String roomId;
  ChatRoomView({super.key, required this.roomId}) {
    // Registrasi controller sekali (tanpa Stateful)
    if (!Get.isRegistered<ChatRoomController>(tag: roomId)) {
      Get.put(ChatRoomController(roomId: roomId), tag: roomId, permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatRoomController>(tag: roomId);
    final me = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width > 600
                ? 400
                : MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() {
                if (!ctrl.booted.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Layout meniru HomeView (clear, simpel)
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header minimal (opsional)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Chat Room',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ===== LIST AREA (Expanded seperti HomeView) =====
                    Expanded(
                      child: Obx(() {
                        final list = ctrl.messages;
                        if (list.isEmpty) {
                          return const Center(child: Text('No messages'));
                        }

                        return ListView.separated(
                          controller: ctrl.scrollCtrl, // optional (auto scroll)
                          reverse:
                              true, // 🔹 terbaru di bawah + start dari bawah
                          padding: const EdgeInsets.all(12),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final m = list[index]; // 🔹 JANGAN dibalik manual
                            final isMe = me != null && m.authorId == me.uid;
                            final others = ctrl.members
                                .where((u) => me == null || u != me.uid)
                                .toList();

                            if (m.type == 'action') {
                              return KeyedSubtree(
                                key: ValueKey(m.id),
                                child: Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Card(
                                    color: Colors.grey.shade200,
                                    child: ListTile(
                                      dense: true,
                                      title: Text(m.text),
                                      subtitle: Text(_hhmm(m.createdAt)),
                                      trailing: ElevatedButton(
                                        onPressed: () {},
                                        child: const Text('Open'),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Bubble text
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(m.text),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _hhmm(m.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              if (isMe) _statusTicks(m, others),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    // ===== COMPOSER (controller pegang TextEditingController) =====
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ctrl.textCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Type a message...',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onSubmitted: (_) => ctrl.sendText(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: ctrl.sendText,
                              child: const Icon(Icons.send),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// --- Helpers (UI only) ---
Widget _statusTicks(MessageEntity m, List<String> otherMembers) {
  final totalRecipients = otherMembers.length;
  final readCount = m.readBy.keys.where(otherMembers.contains).length;
  final deliveredCount = m.deliveredTo.keys.where(otherMembers.contains).length;

  if (totalRecipients == 0) {
    return const SizedBox.shrink();
  } else if (readCount >= totalRecipients) {
    return const Icon(Icons.done_all, size: 14, color: Colors.blue); // ✔✔
  } else if (deliveredCount >= totalRecipients) {
    return const Icon(Icons.done_all, size: 14, color: Colors.black54); // ✔✔
  } else {
    return const Icon(Icons.done, size: 14, color: Colors.black54); // ✔
  }
}

String _hhmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
