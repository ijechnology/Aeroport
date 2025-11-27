// lib/views/flight_detail_page.dart
import 'dart:async';
import 'package:aeroport_new/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/flight_model.dart';
import '../models/airport_model.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/plan_controller.dart';
import '../services/currency_time_service.dart';
import '../services/map_service.dart';

class FlightDetailPage extends StatefulWidget {
  final FlightModel flight;
  const FlightDetailPage({super.key, required this.flight});

  @override
  State<FlightDetailPage> createState() => _FlightDetailPageState();
}

class _FlightDetailPageState extends State<FlightDetailPage> {
  final FavoritesController favoritesC = Get.find<FavoritesController>();
  final PlanController planC = Get.find<PlanController>();
  final CurrencyTimeService _currencyService = CurrencyTimeService();
  final MapService _mapService = MapService();

  String _selectedZone = 'LOCAL';
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Airport? _departureAirport;
  bool _isMapLoading = false;
  String _distanceResult = '';
  late Future<Map<String, dynamic>> _ratesFuture;

  @override
  void initState() {
    super.initState();
    _ratesFuture = _currencyService.getExchangeRates(
      widget.flight.departureAirport,
      widget.flight.arrivalAirport,
    );
    _setupAirportMarker();
  }

  void _setupAirportMarker() {
    _departureAirport = planC.getAirportByIata(widget.flight.departureAirport);
    if (_departureAirport != null && _departureAirport!.latitude != 0.0) {
      final airportMarker = Marker(
        markerId: const MarkerId('airport_marker'),
        position: LatLng(
          _departureAirport!.latitude,
          _departureAirport!.longitude,
        ),
        infoWindow: InfoWindow(
          title: _departureAirport!.airportName,
          snippet: 'Departure Airport',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      setState(() {
        _markers.add(airportMarker);
      });
    }
  }

  void _findUserAndCalculateDistance() async {
    if (_departureAirport == null) {
      Get.snackbar('Error', 'Airport data not found.');
      return;
    }

    setState(() {
      _isMapLoading = true;
      _distanceResult = 'Detecting your location...';
    });

    try {
      final result = await _mapService.getPositionAndDistance(
        _departureAirport!.latitude,
        _departureAirport!.longitude,
      );
      final Position userPosition = result['position'];
      final double distanceKm = result['distanceKm'];
      final userMarker = Marker(
        markerId: const MarkerId('user_marker'),
        position: LatLng(userPosition.latitude, userPosition.longitude),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );

      setState(() {
        _markers.add(userMarker);
        _distanceResult = '~ ${distanceKm.toStringAsFixed(1)} km';
        _isMapLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              userPosition.latitude < _departureAirport!.latitude
                  ? userPosition.latitude
                  : _departureAirport!.latitude,
              userPosition.longitude < _departureAirport!.longitude
                  ? userPosition.longitude
                  : _departureAirport!.longitude,
            ),
            northeast: LatLng(
              userPosition.latitude > _departureAirport!.latitude
                  ? userPosition.latitude
                  : _departureAirport!.latitude,
              userPosition.longitude > _departureAirport!.longitude
                  ? userPosition.longitude
                  : _departureAirport!.longitude,
            ),
          ),
          50.0,
        ),
      );
    } catch (e) {
      setState(() {
        _distanceResult = e.toString().replaceAll('Exception: ', '');
        _isMapLoading = false;
      });
    }
  }

  String _formatTime(DateTime time) => DateFormat('HH:mm').format(time);
  String _formatDate(DateTime time) => DateFormat('d MMM yyyy').format(time);
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.flight.arrivalTime.difference(
      widget.flight.departureTime,
    );

    return Scaffold(
      appBar: AppBar(title: Text("${widget.flight.airline} Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJourneyHeader(duration),
            const Divider(height: 32),
            _buildMapSection(context),
            const SizedBox(height: 16),
            _buildTimeConverterTool(context),
            const SizedBox(height: 16),
            _buildCurrencyExchangeTool(context),
            const Divider(height: 32),
            Text(
              "FLIGHT INFORMATION",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Airline", widget.flight.airline),
            _buildDetailRow("Flight Number", widget.flight.flightNumber),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyFavoriteButton(context),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    if (_departureAirport == null) {
      return const Center(child: Text("Airport location not available"));
    }

    final initialCameraPosition = CameraPosition(
      target: LatLng(_departureAirport!.latitude, _departureAirport!.longitude),
      zoom: 11.0,
    );

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "DISTANCE TO AIRPORT (LBS)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_isMapLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_distanceResult.isNotEmpty)
                  Center(
                    child: Text(
                      _distanceResult,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text("Show My Location & Calculate Distance"),
                    onPressed: _findUserAndCalculateDistance,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyHeader(Duration duration) {
    final departureAirportName =
        planC.getAirportByIata(widget.flight.departureAirport)?.airportName ??
        widget.flight.departureAirport;
    final arrivalAirportName =
        planC.getAirportByIata(widget.flight.arrivalAirport)?.airportName ??
        widget.flight.arrivalAirport;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    departureAirportName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text("(${widget.flight.departureAirport})"),
                ],
              ),
            ),
            Icon(
              Icons.flight_rounded,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    arrivalAirportName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text("(${widget.flight.arrivalAirport})"),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(widget.flight.departureTime),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(widget.flight.departureTime),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(widget.flight.arrivalTime),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(widget.flight.arrivalTime),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeConverterTool(BuildContext context) {
    final String departureZoneCode = _currencyService.getAirportZoneCode(
      widget.flight.departureAirport,
    );
    final String arrivalZoneCode = _currencyService.getAirportZoneCode(
      widget.flight.arrivalAirport,
    );

    String departureTimeStr, arrivalTimeStr, displayedZoneLabel;
    if (_selectedZone == 'LOCAL') {
      departureTimeStr = _currencyService.convertTime(
        widget.flight.departureTime,
        departureZoneCode,
      );
      arrivalTimeStr = _currencyService.convertTime(
        widget.flight.arrivalTime,
        arrivalZoneCode,
      );
      departureTimeStr += " ($departureZoneCode)";
      arrivalTimeStr += " ($arrivalZoneCode)";
      displayedZoneLabel = "Display: Local Airport Time";
    } else {
      departureTimeStr = _currencyService.convertTime(
        widget.flight.departureTime,
        _selectedZone,
      );
      arrivalTimeStr = _currencyService.convertTime(
        widget.flight.arrivalTime,
        _selectedZone,
      );
      displayedZoneLabel = "Display: $_selectedZone Time";
    }

    final List<String> zones = ['LOCAL', 'WIB', 'WITA', 'WIT', 'London'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TIME ZONE ASSISTANT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow("Departure Time", departureTimeStr),
            _buildDetailRow("Arrival Time", arrivalTimeStr),
            const SizedBox(height: 16),
            Text(
              displayedZoneLabel,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: zones.map((zone) {
                return ChoiceChip(
                  label: Text(zone == 'LOCAL' ? 'Local Airport' : zone),
                  selected: _selectedZone == zone,
                  onSelected: (isSelected) {
                    if (isSelected) setState(() => _selectedZone = zone);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyExchangeTool(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CURRENCY EXCHANGE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _ratesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Failed to load rates: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!['rates'] == null) {
                  return const Text('Exchange data not available.');
                }

                final data = snapshot.data!;
                final String base = data['base'];
                final String target = data['target'];
                final Map<String, dynamic> rates = data['rates'];

                double baseAmount =
                    (base == 'IDR' ||
                        base == 'VND' ||
                        base == 'JPY' ||
                        base == 'KRW')
                    ? 100000
                    : 100;
                final num? baseToUsdRateNum = rates['USD$base'];
                if (baseToUsdRateNum == null || baseToUsdRateNum == 0) {
                  return const Text(
                    'Base currency not supported by free API plan.',
                  );
                }

                final double baseAmountInUsd =
                    baseAmount / baseToUsdRateNum.toDouble();
                final num? targetRate = rates['USD$target'];
                final num? eurRate = rates['USDEUR'];

                List<Widget> rateWidgets = [];
                if (targetRate != null && target != base && target != 'USD') {
                  rateWidgets.add(
                    _buildDetailRow(
                      "Destination Currency ($target)",
                      "${NumberFormat("#,##0.00").format(baseAmountInUsd * targetRate)} $target",
                    ),
                  );
                }
                if ('USD' != base) {
                  rateWidgets.add(
                    _buildDetailRow(
                      "US Dollar (USD)",
                      "${NumberFormat("#,##0.00").format(baseAmountInUsd)} USD",
                    ),
                  );
                }
                if (eurRate != null && 'EUR' != base) {
                  rateWidgets.add(
                    _buildDetailRow(
                      "Euro (EUR)",
                      "${NumberFormat("#,##0.00").format(baseAmountInUsd * eurRate)} EUR",
                    ),
                  );
                }

                return Column(
                  children: [
                    Text(
                      "Base currency reference:",
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "${NumberFormat("#,##0").format(baseAmount)} $base",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    if (rateWidgets.isEmpty)
                      const Text("No exchange data available."),
                    ...rateWidgets,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    ),
  );

  Widget _buildStickyFavoriteButton(BuildContext context) {
    final flight = widget.flight;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        bool isCurrentlyFavorite = favoritesC.isFavorite(flight.flightNumber);

        void onPressedAction() async {
          bool willBeFavorite = !isCurrentlyFavorite;
          favoritesC.toggleFavorite(flight);
          if (willBeFavorite) {
            await NotificationService.showFlightFavoriteNotification(
              flightNumber: flight.flightNumber,
              origin: flight.departureAirport,
              destination: flight.arrivalAirport,
            );
          }
        }

        return isCurrentlyFavorite
            ? ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text("Saved to Favorites"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onPressedAction,
              )
            : OutlinedButton.icon(
                icon: const Icon(Icons.star_border_rounded),
                label: const Text("Save Flight Route"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onPressedAction,
              );
      }),
    );
  }
}
