import 'package:edtech/presentation/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edtech/presentation/controllers/auth_controller.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width > 600
                ? 400
                : MediaQuery.of(context).size.width,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Obx(
                            () => Text(
                              auth.mode.value == 'register'
                                  ? "Register"
                                  : "Login",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Obx(
                            () => Text(
                              auth.mode.value == 'register'
                                  ? "Create a new account to get started"
                                  : "Please login to your account",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => auth.mode.value = 'login',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          color: auth.mode.value == 'login'
                                              ? Colors.white
                                              : Colors.grey[200],
                                        ),
                                        child: const Text(
                                          "Login",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => auth.mode.value = 'register',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          color: auth.mode.value == 'register'
                                              ? Colors.white
                                              : Colors.grey[200],
                                        ),
                                        child: const Text(
                                          "Register",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Obx(
                            () => auth.mode.value == 'register'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Full Name",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 44,
                                        child: TextFormField(
                                          controller: auth.nameC,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            hintText: "Faisal Arrahman",
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 44,
                                child: TextFormField(
                                  controller: auth.emailC,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: "ex@email.com",
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Password
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Password",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => SizedBox(
                                  height: 44,
                                  child: TextFormField(
                                    controller: auth.passC,
                                    obscureText: auth.obscure.value,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        onPressed: auth.gantiobscure,
                                        icon: Icon(
                                          auth.obscure.value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Obx(
                            () => auth.mode.value == 'register'
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Role",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Obx(() {
                                          final selected = auth.regRole.value;
                                          return Row(
                                            children: [
                                              _RoleChip(
                                                label: 'Tutor',
                                                selected: selected == 'tutor',
                                                onTap: () =>
                                                    auth.setRole('tutor'),
                                              ),
                                              const SizedBox(width: 8),
                                              _RoleChip(
                                                label: 'Parent',
                                                selected: selected == 'parent',
                                                onTap: () =>
                                                    auth.setRole('parent'),
                                              ),
                                              const SizedBox(width: 8),
                                              _RoleChip(
                                                label: 'Student',
                                                selected: selected == 'student',
                                                onTap: () =>
                                                    auth.setRole('student'),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const Spacer(),

                          Center(
                            child: Obx(
                              () => InkWell(
                                onTap: auth.loading.value ? null : auth.button,
                                child: Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: auth.loading.value
                                        ? Colors.grey
                                        : colorPrimary,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: colorPrimary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      auth.mode.value == 'login'
                                          ? 'Login'
                                          : 'Register',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.grey[200],
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              width: 1.2,
              color: selected ? colorPrimary : Colors.grey,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? colorPrimary : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
