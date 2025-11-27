// lib/views/profile_view.dart (UI FINAL: STRUKTUR BERSIH DAN STABIL)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
//import 'dart:io';
import '../controllers/profile_controller.dart';
import 'profile_edit_view.dart';
import 'login_view.dart';
import '../services/notification_service.dart';

class ProfileView extends StatelessWidget {
  final ProfileController profileC = Get.find<ProfileController>();

  ProfileView({super.key});

  final double cardRadius = 14.0;
  final double avatarRadius = 40.0;

  // Widget Pembantu untuk Menu List
  Widget _buildProfileTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    IconData? trailingIcon,
    required Color iconColor,
  }) {
    //final primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: trailingIcon != null
              ? Icon(trailingIcon, size: 20, color: iconColor)
              : const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 72, right: 12),
          child: Divider(height: 1, color: Colors.black12),
        ),
      ],
    );
  }

  // Widget Pembantu untuk Ringkasan Kesan & Saran
  Widget _buildKesanSaranCard(
    BuildContext context,
    String text,
    Color primaryColor,
  ) {
    String preview = text.isEmpty
        ? 'Anda belum mengisi kesan dan saran. Tekan "Kelola Data Profil" untuk mengisi.'
        : text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kesan & Saran Matkul:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const Divider(height: 15),
          Text(
            preview,
            style: TextStyle(
              fontStyle: text.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: Colors.grey[700],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Header bagian atas (foto dan identitas)
  Widget _buildFixedHeader(
    BuildContext context,
    Color primary,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      color: primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Obx(() {
              if (profileC.profileImage.value != null) {
                return CircleAvatar(
                  radius: 45,
                  backgroundImage: FileImage(profileC.profileImage.value!),
                );
              } else {
                return Icon(Icons.person, size: 50, color: primary);
              }
            }),
          ),
          const SizedBox(height: 10),
          Text(
            profileC.username.isEmpty ? 'Unknown User' : profileC.username,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'NIM: ${profileC.nim.isEmpty ? '-' : profileC.nim} • Kelas: ${profileC.kelas.isEmpty ? '-' : profileC.kelas}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final Color dangerColor = Colors.red.shade700;

    void performLogout() async {
      profileC.logoutSession();
      Get.offAll(() => LoginView());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: primaryColor,
        elevation: 4,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              _buildFixedHeader(context, primaryColor, textTheme),

              // CARD MENU UTAMA
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cardRadius),
                        ),
                        child: Column(
                          children: [
                            // Kelola Data Profil
                            _buildProfileTile(
                              context: context,
                              icon: Iconsax.edit,
                              iconColor: primaryColor,
                              title: 'Kelola Data Profil',
                              subtitle: 'Ubah NIM, Kelas, dan Kesan/Saran',
                              onTap: () => Get.to(() => ProfileEditView()),
                            ),
                            // Tes Notifikasi Lokal
                            _buildProfileTile(
                              context: context,
                              icon: Iconsax.notification,
                              iconColor: primaryColor,
                              title: 'Tes Notifikasi Lokal',
                              subtitle: 'Tampilkan banner popup di HP',
                              onTap: () async {
                                await NotificationService.showTestNotification();
                              },
                            ),
                            // Bersihkan Data Favorit
                            _buildProfileTile(
                              context: context,
                              icon: Iconsax.trash,
                              iconColor: dangerColor,
                              title: 'Bersihkan Data Favorit',
                              subtitle:
                                  'Hapus data rute yang disimpan pengguna',
                              onTap: profileC.clearFavorites,
                              trailingIcon: Iconsax.trash,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      // Kesan & Saran (Preview)
                      _buildKesanSaranCard(
                        context,
                        profileC.kesanSaran,
                        primaryColor,
                      ),

                      // Tombol Logout
                      ElevatedButton(
                        onPressed: performLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dangerColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(cardRadius),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
