import 'package:edtech/presentation/controllers/app_pages.dart';
import 'package:edtech/presentation/widget/ChatButtonWithBadge.dart';
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
    final peersC = Get.put(
      HomeController(),
    ); // controller urus subscribe sendiri

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
                  IconButton(
                    onPressed: () async {
                      await auth.logout();
                      Get.offAllNamed(Routes.login);
                    },
                    icon: const Icon(Icons.logout),
                  ),

                  // ===== HEADER / ROLE INFO (tidak Expanded) =====
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Obx(() {
                      final myRole = auth.role.value;
                      if (myRole.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final targetRole = (myRole == 'tutor')
                          ? 'parent'
                          : 'tutor';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize
                            .min, // penting: biar tidak minta tinggi tak terbatas
                        children: [
                          Text(
                            'Logged in as: $myRole • Showing $targetRole',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final db = FirebaseFirestore.instance;
                                  try {
                                    final all = await db
                                        .collection('users')
                                        .limit(20)
                                        .get();
                                    int tutor = 0,
                                        parent = 0,
                                        student = 0,
                                        other = 0;
                                    for (final d in all.docs) {
                                      final r = (d.data()['role'] ?? '')
                                          .toString()
                                          .toLowerCase();
                                      if (r == 'tutor') {
                                        tutor++;
                                      } else if (r == 'parent') {
                                        parent++;
                                      } else if (r == 'student') {
                                        student++;
                                      } else {
                                        other++;
                                      }
                                    }
                                    Get.snackbar(
                                      'Users snapshot',
                                      'total:${all.size} • tutor:$tutor • parent:$parent • student:$student • other:$other',
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 4),
                                    );
                                    for (final d in all.docs) {
                                      // ignore: avoid_print
                                      print(d.data());
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Users read failed',
                                      e.toString(),
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                },
                                child: const Text('Debug Users'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                  ),

                  // ===== LIST AREA (Expanded di Column luar) =====
                  auth.role.value == "student"
                      ? const SizedBox()
                      : Expanded(
                          child: Obx(() {
                            final peers = peersC.peers;
                            if (peers.isEmpty) {
                              return const Center(child: Text('No users yet'));
                            }
                            return ListView.separated(
                              itemCount: peers.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final u = peers[i];
                                final name = (u['name'] as String?)?.trim();
                                final displayName =
                                    (name == null || name.isEmpty)
                                    ? '(no name)'
                                    : name;
                                final initial = displayName[0].toUpperCase();
                                final uid = (u['uid'] ?? '') as String? ?? '';

                                return ListTile(
                                  leading: CircleAvatar(child: Text(initial)),
                                  title: Text(displayName),
                                  subtitle: Text((u['role'] ?? '').toString()),
                                  trailing: uid.isEmpty
                                      ? const SizedBox.shrink()
                                      : ChatButtonWithBadge(otherUserId: uid),
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
