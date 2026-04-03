import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Center of Kuantan (Example)
  final LatLng _userLocation = const LatLng(3.8126, 103.3256);
  List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketplaceData();
  }

  Future<void> _fetchMarketplaceData() async {
    setState(() => _isLoading = true);
    
    // Fetch clustered hubs from the backend
    final clusters = await ApiService.getNeighborhoodSurplus(_userLocation.latitude, _userLocation.longitude);

    List<Marker> newMarkers = [];

    // 1. Add User Location Pin
    newMarkers.add(
      Marker(
        point: _userLocation,
        width: 60,
        height: 60,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
      ),
    );

    // 2. Add Dynamic Surplus Hub Pins
    for (var cluster in clusters) {
      newMarkers.add(
        Marker(
          point: LatLng(cluster['latitude'], cluster['longitude']),
          width: 150,
          height: 80,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Text(
                  "${cluster['quantity_kg']}kg ${cluster['item_name']}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.green, size: 30),
            ],
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Marketplace'),
        backgroundColor: Colors.white.withOpacity(0.9),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchMarketplaceData),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: _userLocation, initialZoom: 13.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kebun_komuniti',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}
