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
  final LatLng _userLocation = const LatLng(3.8126, 103.3256); // Kuantan Center
  List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketplaceData();
  }

  // --- The Commercial "Bottom Sheet" Popup ---
  void _showProduceDetails(Map<String, dynamic> cluster) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator bar
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cluster['item_name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("Nearby Community Hub", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.shopping_basket, color: Colors.green.shade700, size: 30),
                  )
                ],
              ),
              const Divider(height: 32),
              
              _buildDetailRow(Icons.scale_outlined, "Total Available", "${cluster['quantity_kg']} kg"),
              _buildDetailRow(Icons.location_on_outlined, "Distance", "Approx. 1.2 km away"),
              _buildDetailRow(Icons.verified_user_outlined, "Quality", "AI Verified Healthy"),

              const SizedBox(height: 30),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Directions"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ordering functionality coming soon!")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Order Now"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _fetchMarketplaceData() async {
    setState(() => _isLoading = true);
    final clusters = await ApiService.getNeighborhoodSurplus(_userLocation.latitude, _userLocation.longitude);

    List<Marker> newMarkers = [];
    newMarkers.add(
      Marker(
        point: _userLocation,
        width: 60, height: 60,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
      ),
    );

    for (var cluster in clusters) {
      newMarkers.add(
        Marker(
          point: LatLng(cluster['latitude'], cluster['longitude']),
          width: 150, height: 80,
          child: GestureDetector(
            onTap: () => _showProduceDetails(cluster), // THE INTERACTIVE FIX
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
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchMarketplaceData)],
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
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}
