import 'airport_model.dart';

class FlightInfo {
  final String airline;
  final String flightCode;
  final String aircraft;
  final String status;
  final double distanceKm;
  final Duration estimatedDuration;
  final Airport departure;
  final Airport arrival;

  FlightInfo({
    required this.airline,
    required this.flightCode,
    required this.aircraft,
    required this.status,
    required this.distanceKm,
    required this.estimatedDuration,
    required this.departure,
    required this.arrival,
  });
}
