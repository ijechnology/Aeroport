// lib/services/flight_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/flight_model.dart';
import '../config/api_key.dart' as keys; // <-- 1. IMPORT CONFIG KEY

class FlightService {
  // --- 2. PERBAIKAN: Ambil key dari config, BUKAN hardcode ---
  static final String _apiKey = keys.aviationstackApiKey;

  static Future<List<FlightModel>> getFlights(String from, String to) async {
    // 3. Pastikan sudah 'https://'
    final url = Uri.parse(
      "https://api.aviationstack.com/v1/flights?access_key=$_apiKey&dep_iata=$from&arr_iata=$to",
    );

    print('Requesting flights: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));
      print('Flights API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] == null) {
          print('Flights API returned no data field');
          return [];
        }

        final list = data['data'] as List;

        if (list.isEmpty) {
          print(
            'Flights API returned 0 items (No flights found on this route)',
          );
          return [];
        }

        print('Flights API returned ${list.length} items');
        return list.map((f) => FlightModel.fromJson(f)).toList();
      } else {
        // --- INI ERROR-MU (429) ---
        print('Error body: ${response.body}');
        throw Exception('Failed to fetch flights: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Flights API request timed out');
      throw Exception('Request timeout. Coba lagi.');
    } catch (e) {
      print('Flights API error: $e');
      throw Exception('Gagal memuat penerbangan: $e');
    }
  }
}
