// lib/services/map_service.dart
import 'package:geolocator/geolocator.dart';

class MapService {
  // Fungsi baru yang mengembalikan lokasi user DAN jarak
  Future<Map<String, dynamic>> getPositionAndDistance(
    double airportLat,
    double airportLon,
  ) async {
    try {
      // 1. Cek izin & dapatkan lokasi
      Position userPosition = await _determinePosition();

      // 2. Hitung jarak
      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        airportLat,
        airportLon,
      );

      // 3. Kembalikan semua data yang kita butuhkan
      return {'position': userPosition, 'distanceKm': distanceInMeters / 1000};
    } catch (e) {
      print('Gagal menghitung jarak: $e');
      rethrow; // Biarkan UI yang menangani error
    }
  }

  // Fungsi private untuk handle izin & ambil lokasi
  // (Ini adalah kode standar dari package geolocator)
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi (GPS) mati.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen, buka pengaturan HP.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }
}
