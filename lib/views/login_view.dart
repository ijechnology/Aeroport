import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_view.dart';
import 'widgets/bottom_navbar.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();
    final userC = TextEditingController();
    final passC = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Icon(
                Icons.flight_takeoff,
                size: 75,
                color: Color.fromARGB(255, 0, 0, 255),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: userC,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: passC,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  bool success = authC.login(userC.text, passC.text);

                  if (success) {
                    Get.offAll(() => const BottomNavbar());
                  } else {
                    Get.snackbar(
                      "Gagal",
                      "Username atau password salah.",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red.shade600,
                      colorText: Colors.white,
                      borderRadius: 12,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      icon: const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 48),
                ),
                child: const Text('Login'),
              ),

              TextButton(
                onPressed: () => Get.to(() => const RegisterView()),
                child: const Text('Belum punya akun? Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
