// lib/views/plan_view.dart (MODERN & PROFESIONAL)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plan_controller.dart';
import '../models/airport_model.dart';
import 'widgets/flight_card.dart';
import 'airport_search_view.dart';
import '../controllers/profile_controller.dart';

class PlanView extends StatelessWidget {
  final PlanController controller = Get.find<PlanController>();
  final ProfileController profileC = Get.find<ProfileController>();

  PlanView({super.key});

  Widget _buildClickableInput({
    required BuildContext context,
    required String hint,
    required Rxn<Airport> selectedAirport,
    required String type,
    required IconData icon,
    Color? backgroundColor,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = backgroundColor ?? Colors.white;

    return InkWell(
      onTap: () => Get.to(() => AirportSearchView(type: type)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Obx(() {
              final airport = selectedAirport.value;
              return Expanded(
                child: Text(
                  airport == null
                      ? hint
                      : '${airport.airportName} (${airport.iataCode})',
                  style: TextStyle(
                    fontSize: 15,
                    color: airport == null
                        ? Colors.grey[600]
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: airport == null
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final username = profileC.username;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // abu lembut modern
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== HEADER ====
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 60,
                      left: 24,
                      right: 24,
                      bottom: 80,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${username.isNotEmpty ? username : 'Pengguna'} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ayo rencanakan penerbanganmu!',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // ==== INPUT "FROM" FLOATING ====
                  Positioned(
                    bottom: -40,
                    left: 20,
                    right: 20,
                    child: _buildClickableInput(
                      context: context,
                      hint: 'Pilih Bandara Asal',
                      selectedAirport: controller.selectedFrom,
                      type: 'from',
                      icon: Icons.flight_takeoff,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // ==== INPUT TUJUAN ====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildClickableInput(
                  context: context,
                  hint: 'Pilih Bandara Tujuan',
                  selectedAirport: controller.selectedTo,
                  type: 'to',
                  icon: Icons.flight_land,
                ),
              ),

              const SizedBox(height: 16),

              // ==== BUTTON ====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.fetchFlights(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Cari Penerbangan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // ==== HASIL PENERBANGAN ====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Penerbangan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (controller.isAirportLoading.value ||
                        controller.isLoading.value)
                      const Center(child: CircularProgressIndicator())
                    else if (controller.flights.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Text(
                            "Belum ada penerbangan ditemukan.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: controller.flights
                            .map(
                              (flight) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: FlightCard(flight: flight),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }
}
