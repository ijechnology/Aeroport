// lib/services/hive_service.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/flight_model.dart';
import '../models/airport_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Pastikan semua Adapter sudah terdaftar
    Hive.registerAdapter(FlightModelAdapter());
    Hive.registerAdapter(AirportAdapter());

    // Buka semua box
    await Hive.openBox('users');
    await Hive.openBox('session');
    await Hive.openBox('favorites');
    await Hive.openBox('airport_cache');
    await Hive.openBox('settings'); // <-- TAMBAHKAN BOX INI
  }

  static Box get usersBox => Hive.box('users');
  static Box get sessionBox => Hive.box('session');
  static Box get favoritesBox => Hive.box('favorites');
  static Box get airportCacheBox => Hive.box('airport_cache');

  // --- PERBAIKAN: TAMBAHKAN GETTER settingsBox INI ---
  static Box get settingsBox => Hive.box('settings');
}
