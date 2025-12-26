import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../config/theme.dart';
import '../../models/location_model.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapController mapController;
  LatLng selectedLocation = const LatLng(-6.2088, 106.8456); // Jakarta, Indonesia
  List<Marker> markers = [];
  String selectedAddress = 'Pilih lokasi di peta';
  bool _isLoading = true;
  double _zoom = 13;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    // Tunggu map render dulu sebelum move
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Layanan lokasi dinonaktifkan. Silakan aktifkan di setting.',
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin lokasi ditolak.'),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin lokasi ditolak selamanya. Ubah di pengaturan.'),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      final newLocation = LatLng(position.latitude, position.longitude);
      
      // Get address from coordinates
      String address = await _getAddressFromLatLng(newLocation);
      
      if (mounted) {
        setState(() {
          selectedLocation = newLocation;
          selectedAddress = address;
          _zoom = 15;
          _addMarker(selectedLocation);
          _isLoading = false;
        });
        try {
          mapController.move(selectedLocation, _zoom);
        } catch (e) {
          debugPrint('Map move error: $e');
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Set default lokasi Jakarta
          selectedLocation = const LatLng(-6.2088, 106.8456);
          selectedAddress = 'Jakarta, Indonesia (Default)';
          _addMarker(selectedLocation);
        });
        try {
          mapController.move(selectedLocation, _zoom);
        } catch (e) {
          debugPrint('Map move error: $e');
        }
      }
    }
  }

  Future<String> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        String address =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}';
        return address.replaceAll(RegExp(r',\s*$'), ''); // Remove trailing comma
      }
      return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
    }
  }

  void _addMarker(LatLng location) {
    setState(() {
      markers = [
        Marker(
          point: location,
          width: 80,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ];
      selectedAddress = 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      selectedLocation = point;
    });
    String address = await _getAddressFromLatLng(point);
    setState(() {
      selectedAddress = address;
    });
    _addMarker(point);
  }

  void _confirmLocation() {
    Navigator.pop(
      context,
      LocationModel(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
        address: selectedAddress,
      ),
    );
  }

  void _zoomIn() {
  setState(() => _zoom = (_zoom + 1).clamp(2.0, 19.0));
  mapController.move(selectedLocation, _zoom);
}

void _zoomOut() {
  setState(() => _zoom = (_zoom - 1).clamp(2.0, 19.0));
  mapController.move(selectedLocation, _zoom);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryGold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: selectedLocation,
                initialZoom: _zoom,
                onTap: _onMapTap,
                onMapReady: () {
                  setState(() => _mapReady = true);
                  // Auto move ke user location setelah map ready
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    mapController.move(selectedLocation, _zoom);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.solarease',
                  retinaMode: true,
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          // Zoom buttons
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add, color: AppTheme.primaryGold),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove, color: AppTheme.primaryGold),
                ),
              ],
            ),
          ),
          // Location info card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedAddress,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}