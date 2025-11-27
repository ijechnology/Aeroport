import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_view.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();
    final userC = TextEditingController();
    final passC = TextEditingController();
    final confirmC = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Logo
              Center(
                child: Icon(
                  Icons.flight_takeoff,
                  size: 75,
                  color: Color.fromARGB(255, 0, 0, 255),
                ),
              ),

              const SizedBox(height: 25),

              // Greeting Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Create an account to start your journey with AeroPort.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Username
              TextField(
                controller: userC,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 18),

              // Password
              TextField(
                controller: passC,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 18),

              // Confirm Password
              TextField(
                controller: confirmC,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Confirm Password',
                ),
              ),
              const SizedBox(height: 32),

              // Button (unchanged)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Validasi kosong
                    if (userC.text.isEmpty ||
                        passC.text.isEmpty ||
                        confirmC.text.isEmpty) {
                      Get.snackbar(
                        "Gagal",
                        "Semua kolom harus diisi.",
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
                      return;
                    }

                    // Validasi password tidak sama
                    if (passC.text != confirmC.text) {
                      Get.snackbar(
                        "Gagal",
                        "Password dan Confirm Password tidak sama.",
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
                      return;
                    }

                    // Validasi ke AuthController
                    bool success = authC.register(userC.text, passC.text);
                    if (success) {
                      Get.snackbar(
                        "Berhasil",
                        "Akun berhasil dibuat! Silakan login.",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        duration: const Duration(seconds: 2),
                      );
                      Get.offAll(() => const LoginView());
                    } else {
                      Get.snackbar(
                        "Gagal",
                        "Username sudah terdaftar.",
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
                  child: const Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
