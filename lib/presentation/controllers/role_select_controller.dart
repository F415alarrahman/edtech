import 'package:get/get.dart';
import '../controllers/auth_controller.dart'; // sesuaikan path jika beda
import '../controllers/app_pages.dart'; // untuk Routes

class RoleSelectController extends GetxController {
  final auth = Get.find<AuthController>();

  // Argumen dari halaman sebelumnya
  late final String email;
  late final String password;
  late final String name;

  // State dipantau via Rx
  final RxnString role = RxnString(); // 'tutor' | 'parent' | 'student'

  bool get canContinue =>
      role.value != null &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      name.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    // Ambil argumen dari Get.arguments
    final args = Get.arguments as Map<dynamic, dynamic>?;

    email = (args?['email'] as String?) ?? '';
    password = (args?['password'] as String?) ?? '';
    name = (args?['name'] as String?) ?? '';
  }

  void selectRole(String value) {
    role.value = value;
  }

  Future<void> submit() async {
    if (!canContinue) return;
    await auth.registerWithEmail(
      email: email,
      password: password,
      name: name,
      role: role.value!, // sudah dipastikan non-null oleh canContinue
    );
    await auth.loadMyRole();
    Get.offAllNamed(Routes.home);
  }
}
