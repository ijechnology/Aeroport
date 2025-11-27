import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class AirlineService {
  final String apiKey =
      'a853dcb3c434474d4752ded1bb78d3d1'; // <-- gantikan kalau mau pakai AviationStack API

  // Try fetch airlines by country from AviationStack (may be limited)
  Future<List<Map<String, dynamic>>> fetchAirlinesFromAPI(
    String countryName,
  ) async {
    try {
      final url = Uri.parse(
        'http://api.aviationstack.com/v1/airlines?access_key=$apiKey&country_name=${Uri.encodeComponent(countryName)}',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = (json['data'] as List<dynamic>?) ?? [];
        return data
            .map((e) {
              return {
                'name': e['name'] ?? '',
                'iata_code': e['iata_code'] ?? '',
                'icao_code': e['icao_code'] ?? '',
                'country': e['country_name'] ?? countryName,
              };
            })
            .cast<Map<String, dynamic>>()
            .toList();
      }
    } catch (_) {
      // ignore errors and fallback to bundle
    }
    return [];
  }

  // Fallback: read bundled JSON stored in assets/data/airlines_by_country.json
  Future<List<Map<String, dynamic>>> loadAirlinesFromBundle(
    String countryName,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/data/airlines_by_country.json',
    );
    final Map<String, dynamic> obj = jsonDecode(raw);
    final key = countryName.toLowerCase();
    // if direct match not found, try 'global'
    final list =
        (obj[key] as List<dynamic>?) ?? (obj['global'] as List<dynamic>?) ?? [];
    return list
        .map(
          (e) => {
            'name': e['name'] ?? '',
            'iata_code': e['iata'] ?? '',
            'icao_code': e['icao'] ?? '',
            'country': countryName,
          },
        )
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // Public method: try API first, then fallback to bundle
  Future<List<Map<String, dynamic>>> getAirlinesForCountry(
    String countryName,
  ) async {
    if (countryName.trim().isEmpty) {
      return await loadAirlinesFromBundle('global');
    }
    final apiList = await fetchAirlinesFromAPI(countryName);
    if (apiList.isNotEmpty) return apiList;
    return await loadAirlinesFromBundle(countryName);
  }
}
