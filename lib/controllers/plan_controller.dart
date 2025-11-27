// lib/controllers/plan_controller.dart
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import '../models/flight_model.dart';
import '../models/airport_model.dart';
import '../services/flight_service.dart';
import '../services/airport_service.dart';

class PlanController extends GetxController {
  // Rute
  final Rxn<Airport> selectedFrom = Rxn<Airport>();
  final Rxn<Airport> selectedTo = Rxn<Airport>();
  RxList<FlightModel> flights = <FlightModel>[].obs;
  RxBool isLoading = false.obs;

  final AirportService airportService = AirportService();

  // Bandara
  RxBool isAirportLoading = false.obs;
  List<Airport> _masterAirportList = [];
  final RxMap<String, List<Airport>> groupedSearchResults =
      <String, List<Airport>>{}.obs;

  // --- LOGIKA CACHE PENERBANGAN (BARU) ---
  List<FlightModel> _cachedFlights = [];
  String _cachedRoute = ""; // Untuk menyimpan rute (misal: "CGKSIN")
  DateTime? _cacheTimestamp; // Kapan cache ini dibuat
  // --- AKHIR LOGIKA CACHE ---

  @override
  void onInit() {
    super.onInit();
    _loadAirportData();
  }

  // (Fungsi _loadAirportData, _groupAirports, searchAirports, setAirport, getAirportByIata tidak berubah)
  void _loadAirportData() async {
    try {
      isAirportLoading.value = true;
      _masterAirportList = await airportService.loadAirports();
      groupedSearchResults.value = _groupAirports(_masterAirportList);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data bandara: $e');
    } finally {
      isAirportLoading.value = false;
    }
  }

  Map<String, List<Airport>> _groupAirports(List<Airport> airports) {
    final grouped = groupBy(airports, (Airport airport) => airport.country);
    return grouped;
  }

  void searchAirports(String query) {
    if (query.isEmpty) {
      groupedSearchResults.value = _groupAirports(_masterAirportList);
      return;
    }
    final lowerQuery = query.toLowerCase();
    final filteredList = _masterAirportList.where((airport) {
      final nameMatch = airport.airportName.toLowerCase().contains(lowerQuery);
      final codeMatch = airport.iataCode.toLowerCase().contains(lowerQuery);
      return nameMatch || codeMatch;
    }).toList();
    groupedSearchResults.value = _groupAirports(filteredList);
  }

  void setAirport(String type, Airport airport) {
    if (type == 'from')
      selectedFrom.value = airport;
    else
      selectedTo.value = airport;
    Get.back();
    groupedSearchResults.value = _groupAirports(_masterAirportList);
  }

  Airport? getAirportByIata(String iataCode) {
    try {
      return _masterAirportList.firstWhere(
        (airport) => airport.iataCode == iataCode,
      );
    } catch (e) {
      return null;
    }
  }

  // --- FUNGSI FETCHFLIGHTS (SUDAH DIPERBARUI) ---
  Future<void> fetchFlights() async {
    if (selectedFrom.value == null || selectedTo.value == null) {
      Get.snackbar('Error', 'Harap pilih bandara asal dan tujuan');
      return;
    }

    final fromIata = selectedFrom.value!.iataCode;
    final toIata = selectedTo.value!.iataCode;
    final String currentRoute = "$fromIata-$toIata";

    // --- LOGIKA CEK CACHE (BARU) ---
    if (_cachedRoute == currentRoute && _cacheTimestamp != null) {
      // Rute sama, cek waktunya
      final Duration difference = DateTime.now().difference(_cacheTimestamp!);
      if (difference.inMinutes < 15) {
        // Jika cache masih baru (kurang dari 15 menit)
        print("Menggunakan cache penerbangan untuk rute $currentRoute...");
        flights.value = _cachedFlights; // Langsung pakai data cache
        return; // Lewati (skip) panggilan API
      }
    }
    // --- AKHIR LOGIKA CEK CACHE ---

    // Jika cache tidak ada, beda rute, atau sudah lebih dari 15 menit,
    // lanjutkan panggil API
    try {
      isLoading.value = true;
      print("Memanggil API penerbangan untuk rute $currentRoute...");

      final result = await FlightService.getFlights(fromIata, toIata);

      // --- LOGIKA SIMPAN CACHE (BARU) ---
      _cachedFlights = result; // Simpan hasil ke cache
      _cachedRoute = currentRoute; // Simpan rute ke cache
      _cacheTimestamp = DateTime.now(); // Simpan waktu ke cache
      // --- AKHIR LOGIKA SIMPAN CACHE ---

      flights.value = result; // Tampilkan hasil ke UI
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll("Exception: ", ""));
      flights.value = []; // Kosongkan list jika error
    } finally {
      isLoading.value = false;
    }
  }
}
