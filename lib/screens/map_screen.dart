import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // We are centering the map right on Kuantan, Pahang!
  final LatLng _kuantanCenter = const LatLng(3.8126, 103.3256);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Surplus Map', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _kuantanCenter,
          initialZoom: 13.0,
        ),
        children: [
          // 1. The actual map layer (Free OpenStreetMap!)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.kebun_komuniti',
          ),
          // 2. The pins on the map
          MarkerLayer(
            markers: [
              Marker(
                point: _kuantanCenter,
                width: 80,
                height: 80,
                child: const Column( // This one is fine because it only has Icon and Text
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 40),
                    Text("You", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Marker(
                point: const LatLng(3.8200, 103.3300), // A dummy location nearby
                width: 80,
                height: 80,
                child: Column( // <--- THE FIX: I removed 'const' from this line!
                  children: [
                    const Icon(Icons.eco, color: Colors.green, size: 40),
                    Container(
                      color: Colors.white70,
                      child: const Text(" 5kg Tomatoes ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    )
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