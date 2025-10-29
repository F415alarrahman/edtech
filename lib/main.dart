import 'package:edtech/presentation/controllers/app_pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/controllers/auth_controller.dart';

// tambahkan
import 'package:edtech/core/chat_repository_impl.dart';
import 'package:edtech/data/datasources/cache_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupFirebaseMessaging();

  // init cache store (IO: Isar, Web: localStorage)
  final cache = await CacheStore.create();

  // inject ke GetX agar bisa diambil di mana pun
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<ChatRepository>(ChatRepository(cache), permanent: true);

  runApp(const EdTechApp());
}

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notif = message.notification;
    if (notif != null) {
      Get.snackbar(
        notif.title ?? 'Notifikasi',
        notif.body ?? '',
        snackPosition: SnackPosition.TOP,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final roomId = message.data['roomId'];
    if (roomId != null) {
      Get.toNamed('/chat', arguments: {'roomId': roomId});
    }
  });
}

class EdTechApp extends StatelessWidget {
  const EdTechApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EdTech',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
    );
  }
}
