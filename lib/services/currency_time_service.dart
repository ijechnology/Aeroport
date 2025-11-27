// lib/services/currency_time_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_key.dart' as keys;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class CurrencyTimeService {
  // --- BAGIAN CURRENCY (TIDAK BERUBAH) ---
  static const String _baseUrl = 'https://api.exchangerate.host';
  static final String _apiKey = keys.exchangeRateApiKey;

  final Map<String, String> _currencyMap = {
    'CGK': 'IDR', 'DPS': 'IDR', 'SUB': 'IDR', 'SIN': 'SGD', 'KUL': 'MYR',
    'BKK': 'THB', 'SGN': 'VND', 'MNL': 'PHP', 'NRT': 'JPY', 'HND': 'JPY',
    'ICN': 'KRW', 'PEK': 'CNY', 'PVG': 'CNY', 'DEL': 'INR', 'HKG': 'HKD',
    'SYD': 'AUD', 'DXB': 'AED', 'DOH': 'QAR', 'JED': 'SAR', 'IST': 'TRY',
    'LHR': 'GBP', 'CDG': 'EUR', 'FRA': 'EUR', 'AMS': 'EUR', 'MAD': 'EUR',
    'FCO': 'EUR', 'ZRH': 'CHF', 'JFK': 'USD', 'LAX': 'USD', 'YYZ': 'CAD',
    'MEX': 'MXN', 'GRU': 'BRL',
    // (Bisa tambahkan IATA bandara Papua di sini jika ada, misal 'DJJ')
    'DJJ': 'IDR',
  };

  Future<Map<String, dynamic>> getExchangeRates(
    String baseIata,
    String arrivalIata,
  ) async {
    // (Logika API Currency tidak berubah)
    String baseCurrency = _currencyMap[baseIata] ?? 'USD';
    String arrivalCurrency = _currencyMap[arrivalIata] ?? 'USD';
    final url = Uri.parse('$_baseUrl/live?access_key=$_apiKey');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true || data['quotes'] == null) {
          throw Exception('Currency API returned an error: ${data['error']}');
        }
        return {
          'base': baseCurrency,
          'target': arrivalCurrency,
          'rates': data['quotes'] as Map<String, dynamic>,
        };
      } else {
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- BAGIAN TIMEZONE (LOGIKA BARU) ---

  final Map<String, String> _ianaTimezoneMap = {
    // (Daftar negara lain tetap sama)
    'CGK': 'Asia/Jakarta', 'DPS': 'Asia/Makassar', 'SUB': 'Asia/Jakarta',
    'SIN': 'Asia/Singapore', 'KUL': 'Asia/Kuala_Lumpur', 'BKK': 'Asia/Bangkok',
    'SGN': 'Asia/Ho_Chi_Minh', 'MNL': 'Asia/Manila', 'NRT': 'Asia/Tokyo',
    'HND': 'Asia/Tokyo', 'ICN': 'Asia/Seoul', 'PEK': 'Asia/Shanghai',
    'PVG': 'Asia/Shanghai', 'DEL': 'Asia/Kolkata', 'HKG': 'Asia/Hong_Kong',
    'SYD': 'Australia/Sydney', 'DXB': 'Asia/Dubai', 'DOH': 'Asia/Qatar',
    'JED': 'Asia/Riyadh', 'IST': 'Europe/Istanbul', 'LHR': 'Europe/London',
    'CDG': 'Europe/Paris', 'FRA': 'Europe/Berlin', 'AMS': 'Europe/Amsterdam',
    'MAD': 'Europe/Madrid', 'FCO': 'Europe/Rome', 'ZRH': 'Europe/Zurich',
    'JFK': 'America/New_York',
    'LAX': 'America/Los_Angeles',
    'YYZ': 'America/Toronto',
    'MEX': 'America/Mexico_City', 'GRU': 'America/Sao_Paulo',
    // (Tambahkan IATA bandara Papua di sini)
    'DJJ': 'Asia/Jayapura', // (Contoh: Jayapura)
    // --- PERBAIKAN: Tambahkan WIT ---
    'WIB': 'Asia/Jakarta',
    'WITA': 'Asia/Makassar',
    'WIT': 'Asia/Jayapura', // <-- TAMBAHKAN INI
    'London': 'Europe/London',
  };

  // Helper untuk mendapatkan lokasi IANA, default ke UTC
  tz.Location _getTzLocation(String code) {
    final String ianaName = _ianaTimezoneMap[code] ?? 'UTC';
    return tz.getLocation(ianaName);
  }

  // Fungsi untuk mendapatkan nama zona waktu bandara (misal "WITA")
  String getAirportZoneCode(String iata) {
    String ianaName = _ianaTimezoneMap[iata] ?? 'UTC';
    if (ianaName == 'Asia/Jakarta') return 'WIB';
    if (ianaName == 'Asia/Makassar') return 'WITA';
    if (ianaName == 'Asia/Jayapura') return 'WIT'; // <-- TAMBAHKAN INI
    if (ianaName == 'Asia/Seoul') return 'KST';
    if (ianaName == 'Europe/London') return 'GMT';
    if (ianaName == 'UTC') return 'UTC';
    return ianaName.split('/').last;
  }

  // Fungsi konversi utama (Tidak berubah)
  String convertTime(DateTime flightTimeUtc, String targetZoneCode) {
    final tz.Location targetLocation = _getTzLocation(targetZoneCode);
    final tz.TZDateTime targetTime = tz.TZDateTime.from(
      flightTimeUtc,
      targetLocation,
    );
    return DateFormat('HH:mm').format(targetTime);
  }
}
