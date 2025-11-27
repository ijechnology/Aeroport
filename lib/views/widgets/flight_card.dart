// lib/views/widgets/flight_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/flight_model.dart';
import '../flight_detail_page.dart';
import '../../config/app_theme.dart'; // tambahkan biar bisa pakai warna tema

class FlightCard extends StatelessWidget {
  final FlightModel flight;
  const FlightCard({super.key, required this.flight});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    String result = '';
    if (hours > 0) result += '${hours}j ';
    if (minutes > 0 || hours == 0) result += '${minutes}m';
    return result.trim();
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final duration = flight.arrivalTime.difference(flight.departureTime);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FlightDetailPage(flight: flight)),
        );
      },
      child: Card(
        color: AppTheme.lightBlue, // nyatu sama tema
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    flight.airline,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      flight.flightNumber,
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- BODY (Rute + Durasi) ---
              Row(
                children: [
                  // Waktu Berangkat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(flight.departureTime),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(flight.departureTime), // Contoh: 06 Nov 2023
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        flight.departureAirport,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  // Tengah (Durasi + Icon)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.grey,
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const Icon(
                                Icons.flight_takeoff_rounded,
                                size: 18,
                                color: AppTheme.primaryBlue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Waktu Tiba
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(flight.arrivalTime),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(flight.arrivalTime), // Contoh: 06 Nov 2023
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        flight.arrivalAirport,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
