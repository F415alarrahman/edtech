import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  RxString role = ''.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  final emailC = TextEditingController();
  final passC = TextEditingController();
  final nameC = TextEditingController();
  String mode = 'login'; // 'login' or 'register'

  // 🔸 TARUH FUNGSI INI DI SINI 🔸
  friendlyAuthError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Email tidak valid.';
        case 'user-disabled':
          return 'Akun dinonaktifkan.';
        case 'user-not-found':
          return 'Akun tidak ditemukan.';
        case 'wrong-password':
          return 'Password salah.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti.';
        case 'network-request-failed':
          return 'Koneksi jaringan bermasalah.';
        default:
          return e.message ?? 'Gagal login. (${e.code})';
      }
    }
    return 'Terjadi kesalahan tak terduga.';
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name,
      'avatarUrl': '',
      'role': role, // tutor | parent | student
      'createdAt': FieldValue.serverTimestamp(),
    });

    await saveFcmToken();
  }

  Future<void> saveFcmToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _db
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token)
          .set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await saveFcmToken();
  }

  Future<void> loadMyRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    role.value = doc.data()?['role'] ?? '';
    await saveFcmToken();
  }

  Future<void> logout() async => _auth.signOut();
}
