import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edtech/presentation/controllers/auth_controller.dart';
import 'package:edtech/presentation/controllers/app_pages.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});
  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (auth.mode == 'register')
                          TextField(
                            controller: auth.nameC,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                          ),
                        TextField(
                          controller: auth.emailC,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        TextField(
                          controller: auth.passC,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (auth.emailC.text.isEmpty ||
                                    auth.passC.text.isEmpty) {
                                  Get.snackbar(
                                    'Form belum lengkap',
                                    'Isi email dan password dulu ya.',
                                  );
                                  return;
                                }

                                try {
                                  if (auth.mode == 'login') {
                                    await auth.loginWithEmail(
                                      email: auth.emailC.text.trim(),
                                      password: auth.passC.text,
                                    );
                                    await auth.loadMyRole();
                                    Get.offAllNamed(Routes.home);
                                  } else {
                                    Get.toNamed(
                                      Routes.roleSelect,
                                      arguments: {
                                        'email': auth.emailC.text.trim(),
                                        'password': auth.passC.text,
                                        'name': auth.nameC.text.trim(),
                                      },
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  Get.snackbar(
                                    'Login gagal',
                                    auth.friendlyAuthError(e),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    e.toString(),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              child: Text(
                                auth.mode == 'login' ? 'Login' : 'Register',
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => setState(
                                () => auth.mode = auth.mode == 'login'
                                    ? 'register'
                                    : 'login',
                              ),
                              child: Text(
                                auth.mode == 'login'
                                    ? 'Create account'
                                    : 'Have an account? Login',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
