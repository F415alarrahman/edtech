import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth_controller.dart';

class HomeController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // Ambil AuthController biar bisa dengar perubahan role
  final AuthController auth = Get.find<AuthController>();

  RxList<Map<String, dynamic>> peers = <Map<String, dynamic>>[].obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  Worker? _roleWorker;

  @override
  void onInit() {
    super.onInit();

    // Dengarkan perubahan role → auto-subscribe ke target role
    _roleWorker = ever<String>(auth.role, (r) {
      if (r.isEmpty) return;
      final targetRole = (r == 'tutor') ? 'parent' : 'tutor';
      subscribe(targetRole);
    });

    // Trigger awal kalau role sudah terisi sebelum controller dibuat
    final r = auth.role.value;
    if (r.isNotEmpty) {
      final targetRole = (r == 'tutor') ? 'parent' : 'tutor';
      subscribe(targetRole);
    }
  }

  void subscribe(String role) {
    _sub?.cancel();
    _sub = _db
        .collection('users')
        .where('role', isEqualTo: role)
        // .orderBy('createdAt', descending: true) // aktifkan jika index siap
        .snapshots()
        .listen(
          (snap) => peers.assignAll(snap.docs.map((d) => d.data())),
          onError: (err) {
            Get.snackbar(
              'Users query error',
              err.toString(),
              snackPosition: SnackPosition.BOTTOM,
            );
            peers.clear();
          },
        );
  }

  @override
  void onClose() {
    _sub?.cancel();
    _roleWorker?.dispose();
    super.onClose();
  }
}
