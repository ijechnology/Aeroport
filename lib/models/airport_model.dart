// lib/models/airport_model.dart
import 'package:hive/hive.dart';

part 'airport_model.g.dart'; // (Ini tidak akan merah)

// --- Helper private untuk mem-parse koordinat ---
// Ini akan menangani data 'String' ATAU 'num'
double _parseCoordinate(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}
// --- Akhir helper ---

@HiveType(typeId: 1)
class Airport {
  @HiveField(0)
  final String airportName;

  @HiveField(1)
  final String iataCode;

  @HiveField(2)
  final String country;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  Airport({
    required this.airportName,
    required this.iataCode,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      airportName: json['airport_name'] ?? json['name'] ?? '',
      iataCode: json['iata_code'] ?? json['code'] ?? '',
      country: json['country_name'] ?? json['country'] ?? '',

      // --- PERBAIKAN: Gunakan helper pintar ---
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),
    );
  }
}
