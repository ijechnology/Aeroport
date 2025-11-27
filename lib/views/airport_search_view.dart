// lib/views/airport_search_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plan_controller.dart';
import '../models/airport_model.dart';

class AirportSearchView extends StatelessWidget {
  final String type; // 'from' atau 'to'
  final PlanController controller = Get.find<PlanController>();

  AirportSearchView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          type == 'from' ? 'Pilih Bandara Asal' : 'Pilih Bandara Tujuan',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cari nama bandara atau kode IATA...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                controller.searchAirports(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isAirportLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat data bandara...'),
                    ],
                  ),
                );
              }

              // --- PERUBAHAN: Logika Tampilan Grouped List ---
              if (controller.groupedSearchResults.isEmpty) {
                return const Center(child: Text('Bandara tidak ditemukan'));
              }

              // Ambil daftar negara (keys dari Map)
              final countries = controller.groupedSearchResults.keys.toList();

              // Urutkan negara berdasarkan abjad
              countries.sort();

              return ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final String countryName = countries[index];
                  final List<Airport> airportsInCountry =
                      controller.groupedSearchResults[countryName]!;

                  // Gunakan ExpansionTile untuk "accordion"
                  return ExpansionTile(
                    title: Text(
                      countryName.isEmpty ? "Lainnya" : countryName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Secara default, biarkan tile terbuka jika
                    // ini adalah hasil pencarian (hanya 1 negara)
                    initiallyExpanded: countries.length == 1,
                    children: airportsInCountry
                        .map(
                          (airport) => ListTile(
                            title: Text(airport.airportName),
                            subtitle: Text("(${airport.iataCode})"),
                            onTap: () {
                              controller.setAirport(type, airport);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              );
              // --- AKHIR PERUBAHAN ---
            }),
          ),
        ],
      ),
    );
  }
}
