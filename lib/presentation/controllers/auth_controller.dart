import 'package:edtech/presentation/controllers/app_pages.dart';
import 'package:edtech/presentation/widget/dialog_loading.dart';
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

  final RxnString regRole = RxnString();
  void setRole(String v) => regRole.value = v;

  final emailC = TextEditingController();
  final passC = TextEditingController();
  final nameC = TextEditingController();

  final mode = 'login'.obs;
  final obscure = true.obs;
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    nameC.dispose();
    super.onClose();
  }

  void setMode(String m) => mode.value = m;
  void gantiobscure() => obscure.toggle();

  String friendlyAuthError(Object e) {
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

  Future<void> button() async {
    final ctx = Get.context;
    final email = emailC.text.trim();
    final pass = passC.text;
    final name = nameC.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      Get.snackbar('Form belum lengkap', 'Isi email dan password dulu ya.');
      return;
    }
    if (mode.value == 'register' && name.isEmpty) {
      Get.snackbar('Form belum lengkap', 'Isi nama lengkap ya.');
      return;
    }
    if (loading.value) return;

    if (mode.value == 'login') {
      loading.value = true;
      if (ctx != null) DialogCustom().showLoading(ctx);
      try {
        await loginWithEmail(email: email, password: pass);
        await loadMyRole();
        // ignore: use_build_context_synchronously
        if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
        Get.offAllNamed(Routes.home);
      } on FirebaseAuthException catch (e) {
        // ignore: use_build_context_synchronously
        if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
        Get.snackbar(
          'Login gagal',
          friendlyAuthError(e),
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        loading.value = false;
      }
      return;
    }
    final selectedRole = regRole.value;
    if (selectedRole == null || selectedRole.isEmpty) {
      Get.snackbar(
        'Pilih role dulu',
        'Silakan pilih Tutor/Parent/Student.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    loading.value = true;
    if (ctx != null) DialogCustom().showLoading(ctx);

    try {
      await registerWithEmail(
        email: email,
        password: pass,
        name: name,
        role: selectedRole,
      );
      await loadMyRole();

      // ignore: use_build_context_synchronously
      if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
      Get.offAllNamed(Routes.home);

      regRole.value = null;
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
      Get.snackbar(
        'Register gagal',
        friendlyAuthError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
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
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await saveFcmToken();
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

  Future<void> logout() async => _auth.signOut();
}
