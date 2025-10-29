import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/role_select_controller.dart';

class RoleSelectView extends GetView<RoleSelectController> {
  const RoleSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller terdaftar. Kalau sudah pakai Bindings di route, baris ini tak perlu.
    if (!Get.isRegistered<RoleSelectController>()) {
      Get.put(RoleSelectController());
    }

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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() {
                      final selected = controller.role.value;

                      return Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Tutor'),
                            value: 'tutor',
                            groupValue: selected,
                            onChanged: (v) => controller.selectRole(v!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Parent'),
                            value: 'parent',
                            groupValue: selected,
                            onChanged: (v) => controller.selectRole(v!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Student'),
                            value: 'student',
                            groupValue: selected,
                            onChanged: (v) => controller.selectRole(v!),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.canContinue
                                ? controller.submit
                                : null,
                            child: const Text('Continue'),
                          ),
                        ],
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
