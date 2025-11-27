// lib/services/airport_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/airport_model.dart';
import '../config/api_key.dart' as keys;
import 'hive_service.dart';

class AirportService {
  static const String _baseUrl = 'https://api.aviationstack.com/v1';
  static final String _apiKey = keys.aviationstackApiKey;

  // --- PERUBAHAN: Daftar ini sekarang jauh lebih lengkap (30 negara) ---
  static const List<String> _countryCodesToCache = [
    // Asia & Oceania
    'ID', // Indonesia
    'SG', // Singapore
    'MY', // Malaysia
    'TH', // Thailand
    'VN', // Vietnam
    'PH', // Philippines
    'JP', // Japan
    'KR', // South Korea
    'CN', // China
    'IN', // India
    'HK', // Hong Kong
    'AU', // Australia
    // Middle East
    'AE', // UAE (Dubai)
    'QA', // Qatar (Doha)
    'SA', // Saudi Arabia
    'TR', // Turkey
    // Europe
    'GB', // UK (London)
    'FR', // France (Paris)
    'DE', // Germany (Frankfurt)
    'NL', // Netherlands (Amsterdam)
    'ES', // Spain
    'IT', // Italy
    'CH', // Switzerland
    // Americas
    'US', // USA
    'CA', // Canada
    'MX', // Mexico
    'BR', // Brazil
  ];

  final Box _cacheBox = HiveService.airportCacheBox;
  final String _cacheKey = 'masterAirportList';

  // Fungsi utama (Logika Cache tidak berubah)
  Future<List<Airport>> loadAirports() async {
    List<Airport> cachedAirports = _loadFromCache();
    if (cachedAirports.isNotEmpty) {
      print('Berhasil memuat ${cachedAirports.length} bandara dari CACHE');
      return cachedAirports;
    }

    print(
      'Cache kosong. Memulai API call untuk ${_countryCodesToCache.length} negara...',
    );
    List<Airport> apiAirports = await _fetchFromApi();

    await _saveToCache(apiAirports);
    return apiAirports;
  }

  // --- Private Functions ---

  List<Airport> _loadFromCache() {
    final List<dynamic>? cachedList = _cacheBox.get(_cacheKey);
    if (cachedList != null) {
      return cachedList.cast<Airport>().toList();
    }
    return [];
  }

  Future<void> _saveToCache(List<Airport> airports) async {
    await _cacheBox.put(_cacheKey, airports);
    print('Berhasil menyimpan ${airports.length} bandara ke cache Hive.');
  }

  // Fungsi fetch API (sekarang me-loop daftar yang baru)
  Future<List<Airport>> _fetchFromApi() async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY') {
      throw Exception('API key tidak dikonfigurasi');
    }

    List<Airport> allAirports = [];

    for (String code in _countryCodesToCache) {
      final url = Uri.parse(
        "$_baseUrl/airports?access_key=$_apiKey&country_iso2=$code",
      );
      try {
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 20));
        if (response.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(response.body);
          final List<dynamic>? data = body['data'] as List<dynamic>?;
          if (data != null) {
            allAirports.addAll(
              data.map(
                (item) => Airport.fromJson(item as Map<String, dynamic>),
              ),
            );
            print('Sukses load bandara dari: $code');
          }
        }
      } catch (e) {
        print('Error saat mengambil data $code: $e');
      }
    }

    final unique = <String, Airport>{};
    for (var airport in allAirports) {
      if (airport.iataCode.isNotEmpty) unique[airport.iataCode] = airport;
    }

    print(
      'Total ${unique.values.length} bandara unik berhasil dimuat dari API',
    );
    return unique.values.toList();
  }

  // Fungsi search/filter (ini tidak berubah)
  List<Airport> searchLocalAirports(List<Airport> masterList, String query) {
    if (query.isEmpty) {
      return masterList;
    }
    final lowerQuery = query.toLowerCase();
    return masterList.where((airport) {
      final nameMatch = airport.airportName.toLowerCase().contains(lowerQuery);
      final codeMatch = airport.iataCode.toLowerCase().contains(lowerQuery);
      return nameMatch || codeMatch;
    }).toList();
  }
}
