// lib/controllers/favorites_controller.dart
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/flight_model.dart';
import '../services/hive_service.dart';

class FavoritesController extends GetxController {
  // Ambil box 'favorites' yang sudah kita buat
  final Box _favoritesBox = HiveService.favoritesBox;

  // Ini adalah list reaktif yang akan dilihat oleh UI
  final RxList<FlightModel> favoriteFlights = <FlightModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites(); // Langsung load data favorit saat controller di-inisialisasi
  }

  // Mengambil data dari Hive dan memasukkannya ke list reaktif
  void loadFavorites() {
    final favoritesMap = _favoritesBox.toMap();
    // Ubah data dari Map<dynamic, dynamic> menjadi List<FlightModel>
    favoriteFlights.value = favoritesMap.values.cast<FlightModel>().toList();
  }

  // Fungsi untuk mengecek apakah sebuah flight sudah ada di list favorit
  // Kita buat reaktif dengan membaca dari list .value
  bool isFavorite(String flightNumber) {
    return favoriteFlights.any((flight) => flight.flightNumber == flightNumber);
  }

  // Fungsi utama untuk menambah/menghapus favorit (toggle)
  void toggleFavorite(FlightModel flight) {
    // Kita gunakan flightNumber sebagai 'key' unik di database
    if (_favoritesBox.containsKey(flight.flightNumber)) {
      // Jika sudah ada (isFavorite), hapus
      _favoritesBox.delete(flight.flightNumber);
    } else {
      // Jika belum ada, tambahkan
      _favoritesBox.put(flight.flightNumber, flight);
    }
    // Muat ulang list agar UI terupdate
    loadFavorites();
  }
}
