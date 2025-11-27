// lib/controllers/profile_controller.dart (FINAL - FIX LOGOUT)
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/widgets.dart';
import '../services/hive_service.dart';
import 'auth_controller.dart';
import 'package:flutter/material.dart'; // Tambahkan
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final Box _settingsBox = HiveService.settingsBox;
  final AuthController _authC = Get.find<AuthController>();
  final _profileImagePathKey = 'profileImagePath';
  final Rxn<File> profileImage = Rxn<File>();

  // Controllers untuk input
  final TextEditingController kesanSaranController = TextEditingController();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController kelasController = TextEditingController();

  // Data Dinamis
  final RxString _nim = ''.obs;
  final RxString _kelas = ''.obs;
  final RxString _kesanSaran = ''.obs;
  final RxString _username = ''.obs;

  // Getters
  String get username => _username.value;
  String get nim => _nim.value;
  String get kelas => _kelas.value;
  String get kesanSaran => _kesanSaran.value;

  // Kunci unik per user
  String get _currentUsername => _authC.getUsername();
  String get _kesanSaranKey => '${_currentUsername}_kesan_saran';
  String get _nimKey => '${_currentUsername}_nim';
  String get _classKey => '${_currentUsername}_class';

  @override
  void onInit() {
    super.onInit();
    _username.value = _authC.getUsername();
    loadProfileData();
    loadProfileImage();
  }

  // --- METODE UTAMA (Sama) ---
  void loadProfileData() {
    final savedKesanSaran = _settingsBox.get(_kesanSaranKey, defaultValue: '');
    kesanSaranController.text = savedKesanSaran;
    _kesanSaran.value = savedKesanSaran;

    final savedNIM = _settingsBox.get(_nimKey, defaultValue: '');
    final savedKelas = _settingsBox.get(_classKey, defaultValue: '');

    nimController.text = savedNIM;
    kelasController.text = savedKelas;

    _nim.value = savedNIM;
    _kelas.value = savedKelas;
  }

  void saveProfileData() {
    final kesanSaranText = kesanSaranController.text.trim();
    _settingsBox.put(_kesanSaranKey, kesanSaranText);
    _kesanSaran.value = kesanSaranText;

    final nimText = nimController.text.trim();
    _settingsBox.put(_nimKey, nimText);
    _nim.value = nimText;

    final kelasText = kelasController.text.trim();
    _settingsBox.put(_classKey, kelasText);
    _kelas.value = kelasText;

    loadProfileData();
    Get.back();
  }

  // --- BARU: HANYA MEMBERSIHKAN CACHE TEMPORER ---
  void clearFavorites() {
    Hive.box('favorites').clear();
  }

  // --- BARU: HANYA LOGOUT ---
  void logoutSession() {
    // Session dihapus, tapi data favorit dan profil tetap tersimpan
    _authC.logout();
  }

  void loadProfileImage() {
    final path = _settingsBox.get(_profileImagePathKey);
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
    } else {
      profileImage.value = null; // Tidak ada gambar atau file tidak ditemukan
    }
  }

  // --- BARU: Fungsi untuk Memilih dan Menyimpan Gambar ---
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      final newFile = File(pickedFile.path);

      // Simpan path ke Hive
      await _settingsBox.put(_profileImagePathKey, newFile.path);

      // Update variabel Rx
      profileImage.value = newFile;
      Get.back(); // Tutup dialog picker
      Get.snackbar('Berhasil!', 'Foto profil berhasil diperbarui.');
    }
  }

  // --- BARU: Fungsi untuk Menghapus Gambar ---
  Future<void> deleteImage() async {
    // Hapus path dari Hive
    await _settingsBox.delete(_profileImagePathKey);
    // Hapus variabel Rx
    profileImage.value = null;

    Get.back(); // Tutup dialog konfirmasi
    Get.snackbar('Berhasil!', 'Foto profil berhasil dihapus.');
  }
}
