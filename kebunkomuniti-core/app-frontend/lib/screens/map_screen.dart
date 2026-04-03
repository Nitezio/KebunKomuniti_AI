import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _kuantanCenter = const LatLng(3.8126, 103.3256);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Trendy edge-to-edge map look
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9), // Glass effect
        title: Text('Neighborhood Map', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _kuantanCenter,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.kebun_komuniti',
          ),
          MarkerLayer(
            markers: [
              // User Location Pin
              Marker(
                point: _kuantanCenter,
                width: 60,
                height: 60,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              // Surplus Pin
              Marker(
                point: const LatLng(3.8200, 103.3300),
                width: 120,
                height: 80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_basket_rounded, color: Colors.green.shade600, size: 16),
                          const SizedBox(width: 6),
                          Text("5kg Tomatoes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade900)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white, size: 30), // Pin pointer
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}