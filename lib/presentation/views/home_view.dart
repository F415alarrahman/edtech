import 'package:edtech/data/repositories/chat_repository_impl.dart';
import 'package:edtech/presentation/controllers/app_pages.dart';
import 'package:edtech/presentation/views/chat_room_view.dart';
import 'package:edtech/presentation/widget/images_path.dart';
import 'package:edtech/presentation/widget/no_found.dart';
import 'package:edtech/presentation/widget/pro_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final peersC = Get.put(HomeController());

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Image.asset(ImagesAssets.logo, height: 32),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await auth.logout();
                          Get.offAllNamed(Routes.login);
                        },
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  auth.role.value == "student"
                      ? const Text(
                          "Call your parent to chat with their teacher",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          auth.role.value == "parent"
                              ? "Chat with your child's teacher"
                              : "Chat with parents",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  auth.role.value == "student"
                      ? NoFound(
                          message: "No users available",
                          subMessage:
                              "There are no available users to chat with at the moment.",
                        )
                      : auth.loading.value
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                      : Expanded(
                          child: Obx(() {
                            final peers = peersC.peers;
                            if (peers.isEmpty) {
                              return const Center(
                                child: NoFound(
                                  message: "No users available",
                                  subMessage:
                                      "There are no available users to chat with at the moment.",
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: peers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              padding: const EdgeInsets.all(8),
                              itemBuilder: (_, i) {
                                final u = peers[i];
                                final name = (u['name'] as String?)?.trim();
                                final displayName =
                                    (name == null || name.isEmpty)
                                    ? '(no name)'
                                    : name;
                                final uid = (u['uid'] ?? '') as String? ?? '';
                                final role = (u['role'] ?? '').toString();

                                if (uid.isEmpty) return const SizedBox.shrink();

                                return StreamBuilder<String?>(
                                  stream: Stream.fromFuture(
                                    Get.find<ChatRepository>().findDirectRoomId(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      uid,
                                    ),
                                  ),
                                  builder: (context, roomSnap) {
                                    final roomId = roomSnap.data;

                                    final lastMsgStream = (roomId != null)
                                        ? FirebaseFirestore.instance
                                              .collection('rooms')
                                              .doc(roomId)
                                              .collection('messages')
                                              .orderBy(
                                                'createdAt',
                                                descending: true,
                                              )
                                              .limit(1)
                                              .snapshots()
                                        : const Stream<
                                            QuerySnapshot<Map<String, dynamic>>
                                          >.empty();
                                    final unreadStream = (roomId != null)
                                        ? Get.find<ChatRepository>()
                                              .streamUnreadCount(
                                                roomId,
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid,
                                              )
                                        : const Stream<int>.empty();

                                    return StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>
                                    >(
                                      stream: lastMsgStream,
                                      builder: (context, lastSnap) {
                                        String lastText = (roomId == null)
                                            ? 'Mulai chat baru'
                                            : 'Belum ada pesan';
                                        String timeText = '';

                                        if (lastSnap.hasData &&
                                            lastSnap.data!.docs.isNotEmpty) {
                                          final d = lastSnap.data!.docs.first
                                              .data();
                                          final t =
                                              (d['text'] as String?) ?? '';
                                          final ts = d['createdAt'];
                                          lastText = (t.isEmpty)
                                              ? '(pesan)'
                                              : t;

                                          if (ts is Timestamp) {
                                            final dt = ts.toDate();
                                            final hh = dt.hour
                                                .toString()
                                                .padLeft(2, '0');
                                            final mm = dt.minute
                                                .toString()
                                                .padLeft(2, '0');
                                            timeText = '$hh:$mm';
                                          }
                                        }

                                        return StreamBuilder<int>(
                                          stream: unreadStream,
                                          initialData: 0,
                                          builder: (context, unreadSnap) {
                                            final unread = unreadSnap.data ?? 0;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: InkWell(
                                                onTap: () async {
                                                  final repo =
                                                      Get.find<
                                                        ChatRepository
                                                      >();
                                                  final me = FirebaseAuth
                                                      .instance
                                                      .currentUser!;
                                                  final rid =
                                                      roomId ??
                                                      await repo
                                                          .createDirectRoom(
                                                            createdBy: me.uid,
                                                            otherId: uid,
                                                          );
                                                  Get.to(
                                                    () => ChatRoomView(
                                                      roomId: rid,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                      ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 24,
                                                        child: Text(
                                                          displayName[0]
                                                              .toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              displayName,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              '$role • $lastText',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      if (unread > 0)
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            if (timeText
                                                                .isNotEmpty)
                                                              Text(
                                                                timeText,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical: 2,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .redAccent,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                '$unread',
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          }),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
