// lib/models/flight_model.dart
import 'package:hive/hive.dart';

part 'flight_model.g.dart'; // <-- TAMBAHAN (Mungkin akan merah dulu, abaikan)

@HiveType(typeId: 0) // <-- TAMBAHAN (ID harus unik untuk setiap model)
class FlightModel {
  @HiveField(0) // <-- TAMBAHAN (Index harus urut)
  final String airline;

  @HiveField(1)
  final String flightNumber;

  @HiveField(2)
  final String departureAirport;

  @HiveField(3)
  final String arrivalAirport;

  @HiveField(4)
  final DateTime departureTime;

  @HiveField(5)
  final DateTime arrivalTime;

  FlightModel({
    required this.airline,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
  });

  // Factory 'fromJson' tidak perlu diubah.
  // Hive tidak menggunakan ini, tapi API-mu menggunakannya. Biarkan saja.
  factory FlightModel.fromJson(Map<String, dynamic> json) {
    final depTimeStr = json['departure']?['scheduled'] ?? '';
    final arrTimeStr = json['arrival']?['scheduled'] ?? '';

    // Fungsi helper untuk mem-parsing string waktu sebagai UTC (PENTING!)
    // Ini menjamin perhitungan durasi yang akurat (seperti yang kita bahas di Analisis 1)
    DateTime _parseTime(String timeStr) {
      if (timeStr.isEmpty) return DateTime.now();

      String fixed = timeStr.trim();

      // 1. Hapus Z di belakang
      if (fixed.endsWith('Z')) {
        fixed = fixed.substring(0, fixed.length - 1);
      }

      // 2. Hapus offset timezone seperti +00:00, +07:00, -04:00
      fixed = fixed.replaceAll(RegExp(r'(\+|-)\d{2}:\d{2}$'), '');

      // 3. Tambahkan Z → jadikan UTC normal
      fixed = fixed + 'Z';

      return DateTime.parse(fixed).toLocal();
    }

    return FlightModel(
      airline:
          json['airline']?['name'] ??
          'Unknown Airline', // <-- Sedikit perbaikan
      flightNumber: json['flight']?['iata'] ?? 'N/A', // <-- Sedikit perbaikan
      departureAirport:
          json['departure']?['iata'] ?? 'Unknown', // <-- Sedikit perbaikan
      arrivalAirport:
          json['arrival']?['iata'] ?? 'Unknown', // <-- Sedikit perbaikan
      departureTime: _parseTime(depTimeStr),
      arrivalTime: _parseTime(arrTimeStr),
    );
  }
}
