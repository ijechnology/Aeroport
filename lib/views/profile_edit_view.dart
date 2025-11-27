// lib/views/profile_edit_view.dart (FINAL SINKRONISASI FOTO)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // <-- Wajib untuk ImageSource
//import 'dart:io'; // <-- Wajib untuk FileImage
import '../controllers/profile_controller.dart';

class ProfileEditView extends StatelessWidget {
  final ProfileController profileC = Get.find<ProfileController>();

  ProfileEditView({super.key});

  // Widget pembantu untuk input sederhana
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    // ... (Kode _buildInputField tetap sama)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET UNTUK DIALOG EDIT FOTO (Disalin dari ProfileView) ---
  void _showImageSourceDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Opsi Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => profileC.pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto Baru'),
              onTap: () => profileC.pickImage(ImageSource.camera),
            ),
            Obx(
              () => profileC.profileImage.value != null
                  ? ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Hapus Foto',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Get.back(); // Tutup dialog picker
                        _showDeleteConfirmationDialog();
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Foto Profil?'),
        content: const Text('Anda yakin ingin menghapus foto profil ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () => profileC.deleteImage(),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  // --- AKHIR WIDGET DIALOG ---

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Data Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER AKUN (Stack untuk Pensil Edit) ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // FOTO PROFIL UTAMA
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(
                      context,
                    ), // <-- ACTION: Memanggil Dialog Edit
                    child: Obx(() {
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        // TAMPILKAN GAMBAR DINAMIS
                        backgroundImage: profileC.profileImage.value != null
                            ? FileImage(profileC.profileImage.value!)
                                  as ImageProvider
                            : null,
                        child: profileC.profileImage.value == null
                            ? Icon(Icons.person, size: 40, color: primaryColor)
                            : null,
                      );
                    }),
                  ),

                  // Ikon Pensil di sudut bawah kanan
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- INPUT USERNAME (READONLY) ---
            _buildInputField(
              label: 'Username (Nama Akun)',
              controller: TextEditingController(text: profileC.username),
              readOnly: true,
            ),
            const SizedBox(height: 30),

            // ... (INPUT DATA KULIAH, KESAN & SARAN, dan TOMBOL SIMPAN) ...
            Text('Data Kuliah', style: Theme.of(context).textTheme.titleMedium),
            const Divider(color: Colors.grey),
            const SizedBox(height: 15),

            _buildInputField(
              label: 'NIM (Nomor Induk Mahasiswa)',
              controller: profileC.nimController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            _buildInputField(
              label: 'Kelas / Semester',
              controller: profileC.kelasController,
            ),
            const SizedBox(height: 30),

            Text(
              'Kesan dan Saran Mata Kuliah',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 15),

            TextField(
              controller: profileC.kesanSaranController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Tulis kesan dan saran Anda di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            ElevatedButton(
              onPressed: profileC.saveProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Simpan Perubahan Profil',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
