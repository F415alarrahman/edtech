import 'package:edtech/presentation/widget/no_found.dart';
import 'package:edtech/presentation/widget/pro_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/chat_entities.dart';
import '../controllers/chat_room_controller.dart';
import 'package:edtech/presentation/widget/colors.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final String roomId;
  ChatRoomView({super.key, required this.roomId}) {
    if (!Get.isRegistered<ChatRoomController>(tag: roomId)) {
      Get.put(ChatRoomController(roomId: roomId), tag: roomId, permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatRoomController>(tag: roomId);
    final me = FirebaseAuth.instance.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width > 600
                ? 400
                : MediaQuery.of(context).size.width,
            child: Obx(() {
              if (!ctrl.booted.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: colorBackground,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => Get.back(),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Chat Room',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 60,
                          left: 16,
                          right: 16,
                          bottom: 86,
                          child: ctrl.loading.value
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ProShimmer(height: 10, width: 200),
                                      SizedBox(height: 4),
                                      ProShimmer(height: 10, width: 120),
                                      SizedBox(height: 4),
                                      ProShimmer(height: 10, width: 100),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                )
                              : Obx(() {
                                  final list = ctrl.messages;
                                  if (list.isEmpty) {
                                    return const Center(
                                      child: NoFound(
                                        message: "No messages",
                                        subMessage:
                                            "Start the conversation by sending a message.",
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    controller: ctrl.scrollCtrl,
                                    reverse: true,
                                    itemCount: list.length,
                                    itemBuilder: (_, index) {
                                      final m = list[index];
                                      final isMe =
                                          me != null && m.authorId == me.uid;
                                      if (m.type == 'action') {
                                        return Align(
                                          alignment: isMe
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: GestureDetector(
                                            onLongPress: isMe
                                                ? () => _onLongPressMessage(
                                                    context,
                                                    ctrl,
                                                    m,
                                                  )
                                                : null,
                                            child: Card(
                                              // ignore: deprecated_member_use
                                              color: colorSecondary.withOpacity(
                                                0.12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                dense: true,
                                                title: Text(m.text),
                                                subtitle: Text(
                                                  _hhmm(m.createdAt),
                                                ),
                                                trailing: ElevatedButton(
                                                  onPressed: () {},
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            colorSecondary,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                  child: const Text('Open'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment: isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: isMe
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (!isMe)
                                                const SizedBox(width: 0),
                                              if (!isMe)
                                                const SizedBox(width: 8),

                                              Flexible(
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        .75,
                                                  ),
                                                  child: GestureDetector(
                                                    onLongPress: isMe
                                                        ? () =>
                                                              _onLongPressMessage(
                                                                context,
                                                                ctrl,
                                                                m,
                                                              )
                                                        : null,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
                                                          ),
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isMe
                                                            ? colorPrimary
                                                            : colorSecondary,
                                                        borderRadius: BorderRadius.only(
                                                          topLeft:
                                                              const Radius.circular(
                                                                16,
                                                              ),
                                                          topRight:
                                                              const Radius.circular(
                                                                16,
                                                              ),
                                                          bottomRight: isMe
                                                              ? Radius.zero
                                                              : const Radius.circular(
                                                                  16,
                                                                ),
                                                          bottomLeft: isMe
                                                              ? const Radius.circular(
                                                                  16,
                                                                )
                                                              : Radius.zero,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            m.text,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                            softWrap: true,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                _hhmm(
                                                                  m.createdAt,
                                                                ),
                                                                style: const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 6,
                                                              ),
                                                              if (isMe)
                                                                const Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SafeArea(
                            top: false,
                            child: Container(
                              height: 86,
                              padding: const EdgeInsets.all(10),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: ctrl.textCtrl,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        hintText: 'Type a message...',
                                        suffixIcon: InkWell(
                                          onTap: ctrl.sendText,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.send,
                                              size: 24,
                                              color:
                                                  colorPrimary, // tombol kirim = primary
                                            ),
                                          ),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          borderSide: BorderSide(
                                            // ignore: deprecated_member_use
                                            color: colorSecondary.withOpacity(
                                              .25,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          borderSide: BorderSide(
                                            // ignore: deprecated_member_use
                                            color: colorSecondary.withOpacity(
                                              .25,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          borderSide: BorderSide(
                                            color: colorSecondary,
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                      onSubmitted: (_) => ctrl.sendText(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

Future<void> _onLongPressMessage(
  BuildContext context,
  ChatRoomController ctrl,
  MessageEntity m,
) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () => Navigator.pop(ctx, 'edit'),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Hapus'),
            onTap: () => Navigator.pop(ctx, 'delete'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (action == 'edit') {
    // ignore: use_build_context_synchronously
    final newText = await _editDialog(context, m.text);
    if (newText != null && newText.trim().isNotEmpty) {
      await ctrl.editMessage(m.id, newText.trim());
    }
  } else if (action == 'delete') {
    final ok = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus pesan?'),
        content: const Text('Pesan akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSecondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ctrl.deleteMessage(m.id);
    }
  }
}

Future<String?> _editDialog(BuildContext context, String oldText) async {
  final controller = TextEditingController(text: oldText);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit pesan'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: null,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, null),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

String _hhmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
