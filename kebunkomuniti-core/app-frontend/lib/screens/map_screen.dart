import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'sell_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _userLocation = const LatLng(3.8126, 103.3256); // Kuantan Center
  List<dynamic> _allClusters = [];
  List<Marker> _visibleMarkers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMarketplaceData();
  }

  void _filterMarkers(String query) {
    List<Marker> filtered = [];
    filtered.add(Marker(point: _userLocation, width: 60, height: 60, child: const Icon(Icons.my_location, color: Colors.blue, size: 30)));

    for (var cluster in _allClusters) {
      if (cluster['item_name'].toString().toLowerCase().contains(query.toLowerCase())) {
        filtered.add(
          Marker(
            point: LatLng(cluster['latitude'], cluster['longitude']),
            width: 150, height: 80,
            child: GestureDetector(
              onTap: () => _showProduceDetails(cluster),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                    child: Text("${cluster['quantity_kg']}kg ${cluster['item_name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.green, size: 30),
                ],
              ),
            ),
          ),
        );
      }
    }
    setState(() => _visibleMarkers = filtered);
  }

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
                        Text("Verified Neighborhood Hub", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
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
              
              // --- THE FIX: ALL DETAILS NOW SHOWN ---
              _buildDetailRow(Icons.scale_outlined, "Total Available", "${cluster['quantity_kg']} kg"),
              _buildDetailRow(Icons.payments_outlined, "Total Price", "RM ${cluster['price']?.toStringAsFixed(2) ?? '0.00'}"),
              _buildDetailRow(Icons.local_shipping_outlined, "Method", cluster['method'] ?? "Pickup"),
              _buildDetailRow(Icons.location_on_outlined, "Distance", "Approx. 0.8 km away"),

              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ApiService.openMapDirections(cluster['latitude'], cluster['longitude']);
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("Directions"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        bool success = await ApiService.placeOrder(cluster, "Ahmad bin Razak", cluster['method'] ?? "Pickup");
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order reserved! Check your Activity tab.")));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
    
    // FETCH DATA
    var clusters = await ApiService.getNeighborhoodSurplus(_userLocation.latitude, _userLocation.longitude);

    // --- THE FIX: ADDING MORE DEMO MARKERS ---
    if (clusters.length < 5) {
      clusters = [
        {"id": 201, "item_name": "Organic Tomatoes", "quantity_kg": 5.0, "latitude": 3.8150, "longitude": 103.3280, "price": 27.50, "method": "Pickup"},
        {"id": 202, "item_name": "Fresh Spinach", "quantity_kg": 2.5, "latitude": 3.8100, "longitude": 103.3200, "price": 11.25, "method": "Delivery"},
        {"id": 203, "item_name": "Chili Padi", "quantity_kg": 1.2, "latitude": 3.8200, "longitude": 103.3300, "price": 19.20, "method": "Pickup"},
        {"id": 204, "item_name": "Bendi (Okra)", "quantity_kg": 3.0, "latitude": 3.8180, "longitude": 103.3220, "price": 21.00, "method": "Pickup"},
        {"id": 205, "item_name": "Papaya", "quantity_kg": 10.0, "latitude": 3.8050, "longitude": 103.3350, "price": 45.00, "method": "Delivery"},
        {"id": 206, "item_name": "Mango (Harum Manis)", "quantity_kg": 4.5, "latitude": 3.8250, "longitude": 103.3150, "price": 67.50, "method": "Pickup"},
        {"id": 207, "item_name": "Mustard Green", "quantity_kg": 2.0, "latitude": 3.8080, "longitude": 103.3180, "price": 10.00, "method": "Delivery"},
      ];
    }

    setState(() {
      _allClusters = clusters;
      _isLoading = false;
    });
    _filterMarkers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: _filterMarkers,
          decoration: InputDecoration(
            hintText: "Search produce...",
            prefixIcon: const Icon(Icons.search, color: Colors.green),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.green), onPressed: _fetchMarketplaceData)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SellScreen())),
        label: const Text("Sell Surplus"),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: _userLocation, initialZoom: 13.0),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.kebun_komuniti'),
              MarkerLayer(markers: _visibleMarkers),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}
