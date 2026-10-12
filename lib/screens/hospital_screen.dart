import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalScreen extends StatefulWidget {
  final bool isTab;
  const HospitalScreen({super.key, this.isTab = false});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  // Center of Sri Lanka approx
  LatLng _currentPosition = const LatLng(7.8731, 80.7718);
  bool _isLoading = true;
  late final MapController _mapController;

  List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'National Hospital of Sri Lanka',
      'lat': 6.9192,
      'lng': 79.8660,
      'address': 'Regent St, Colombo 01000'
    },
  ];

  Future<void> _fetchNearbyHospitals(LatLng position) async {
    // Search radius in meters - 10km
    const double radius = 10000;
    final String overpassQuery = '''
      [out:json];
      (
        node["amenity"="hospital"](around:$radius,${position.latitude},${position.longitude});
        way["amenity"="hospital"](around:$radius,${position.latitude},${position.longitude});
        relation["amenity"="hospital"](around:$radius,${position.latitude},${position.longitude});
      );
      out center;
    ''';

    final Uri url = Uri.parse('https://overpass-api.de/api/interpreter');

    try {
      final response = await http.post(
        url,
        headers: {
          'User-Agent': 'CeylonSnakesApp/1.0',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'data': overpassQuery},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'];

        if (elements.isNotEmpty) {
          final List<Map<String, dynamic>> fetchedHospitals = [];

          for (var element in elements) {
            final tags = element['tags'];
            final name = tags['name'] ?? tags['name:en'] ?? 'Hospital';

            double lat = 0;
            double lng = 0;

            if (element['type'] == 'node') {
              lat = element['lat'];
              lng = element['lon'];
            } else if (element['center'] != null) {
              lat = element['center']['lat'];
              lng = element['center']['lon'];
            }

            if (lat != 0 && lng != 0) {
              fetchedHospitals.add({
                'name': name,
                'lat': lat,
                'lng': lng,
                'address': tags['addr:street'] ?? 'Nearby Hospital',
              });
            }
          }

          if (mounted) {
            setState(() {
              _hospitals = fetchedHospitals;
              _isLoading = false;
            });
            return;
          }
        }
      } else {
        debugPrint('Overpass API Error: Status Code ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception during hospital fetch: $e');
    }

    // Fallback or just stop loading if failed
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          // Keep loading true until we fetch hospitals
        });
        _mapController.move(_currentPosition, 13.0);
        await _fetchNearbyHospitals(_currentPosition);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchMapsUrl(double lat, double lng) async {
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Hospitals',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 7.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ceylon_snakes.app',
              ),
              MarkerLayer(
                markers: [
                  // Current Location Marker
                  Marker(
                    point: _currentPosition,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  // Hospital Markers
                  ..._hospitals.map((hospital) {
                    return Marker(
                      point: LatLng(hospital['lat'], hospital['lng']),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                _buildHospitalDetailSheet(hospital),
                          );
                        },
                        child: const Icon(
                          Icons.local_hospital,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Locating you..."),
                    ],
                  ),
                ),
              ),
            ),

          // Hospital List Overlay
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Nearest Hospitals",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _hospitals.length,
                        itemBuilder: (context, index) {
                          final hospital = _hospitals[index];
                          // Sort or calculations could go here
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.local_hospital,
                                  color: Colors.blue),
                            ),
                            title: Text(hospital['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(hospital['address']),
                            trailing: IconButton(
                              icon: const Icon(Icons.directions,
                                  color: Colors.blue),
                              onPressed: () => _launchMapsUrl(
                                  hospital['lat'], hospital['lng']),
                            ),
                            onTap: () {
                              _mapController.move(
                                  LatLng(hospital['lat'], hospital['lng']),
                                  15.0);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalDetailSheet(Map<String, dynamic> hospital) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.red, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hospital['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hospital['address'],
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _launchMapsUrl(hospital['lat'], hospital['lng']);
              },
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
