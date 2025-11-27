// lib/main.dart (VERSI BERSIH DAN STABIL)
import 'package:aeroport_new/config/app_theme.dart';
import 'package:aeroport_new/controllers/favorites_controller.dart';
import 'package:aeroport_new/controllers/plan_controller.dart';
import 'package:aeroport_new/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aeroport_new/controllers/auth_controller.dart';
import 'package:aeroport_new/services/hive_service.dart';
import 'package:aeroport_new/services/notification_service.dart';
import 'views/login_view.dart';
import 'views/widgets/bottom_navbar.dart';
import 'package:timezone/data/latest.dart' as tz; // PENTING

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Timezone (Harus di sini untuk menghindari crash)
  tz.initializeTimeZones();
  // HAPUS: await NotificationService.configureLocalTimeZone(); <-- DIHAPUS KARENA MENGGUNAKAN flutter_native_timezone

  // 2. Inisialisasi Database Hive
  try {
    await HiveService.init();
  } catch (e) {
    print('Gagal inisialisasi Hive: $e');
    return;
  }

  // 3. Inisialisasi Notifikasi (Fungsi notifikasi dasar tetap aman)
  try {
    await NotificationService.initializeNotification();
  } catch (e) {
    print('Peringatan: NotificationService.init() gagal: $e');
  }

  // 4. Inisialisasi Controllers
  Get.put(AuthController());
  Get.put(ProfileController());
  Get.put(PlanController());
  Get.put(FavoritesController());

  // 5. Cek Login dan Jalankan Aplikasi
  final AuthController authC = Get.find<AuthController>();

  runApp(MyApp(isLoggedIn: authC.isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aeroport',
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const BottomNavbar() : const LoginView(),
    );
  }
}
