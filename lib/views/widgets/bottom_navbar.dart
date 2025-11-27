// lib/views/bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

// Import halaman yang benar
import '../plan_view.dart';
import '../favorites_view.dart'; // <-- INI YANG BARU
import '../profile_view.dart';
// import 'airport_view.dart'; // <-- HAPUS INI KARENA FILE SUDAH DIHAPUS

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;

  // Sesuaikan ikon dengan halamannya
  final iconList = const [
    Iconsax.home_1, // Untuk Halaman PlanView (Home/Pencarian)
    Iconsax.star, // Untuk Halaman FavoritesView
    Iconsax.profile_circle, // Untuk Halaman ProfileView
  ];

  // Sesuaikan halaman dengan ikonnya
  final List<Widget> _pages = [
    PlanView(), // Index 0
    FavoritesView(), // Index 1 (Pastikan kamu sudah buat file ini)
    ProfileView(), // Index 2
  ];

  // Tema biru-putih (ambil dari theme nanti, tapi untuk sementara gpp)
  final Color primaryBlue = const Color(0xFF0D47A1); // Pakai warna dari theme
  final Color bgColor = Colors.white;
  final Color inactiveColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        // Gunakan IndexedStack agar state halaman tetap terjaga
        index: _currentIndex,
        children: _pages,
      ),

      // Animated Bottom Navigation Bar
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex,
        gapLocation: GapLocation.none, // tidak ada lubang
        notchSmoothness: NotchSmoothness.defaultEdge,
        activeColor: primaryBlue,
        inactiveColor: inactiveColor,
        backgroundColor: bgColor,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
