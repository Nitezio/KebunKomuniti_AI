import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ApiService {
  static const String gatewayIp = '10.0.2.2';
  static const String gatewayUrl = 'http://$gatewayIp';

  // --- Price Regulation Data ---
  static const Map<String, double> regulatedPrices = {
    "Tomatoes": 5.50,
    "Chili Padi": 16.00,
    "Spinach (Bayam)": 4.50,
    "Okra (Bendi)": 7.00,
    "Mustard Green (Sawi)": 5.00,
    "Eggplant (Terung)": 6.50,
    "Mango": 15.00,
    "Papaya": 4.50,
  };

  // --- THE CENTRAL MARKETPLACE (Local Demo Storage) ---
  // All markers now live here so they can be deleted upon completion.
  static List<Map<String, dynamic>> localSurplus = [
    {"id": 201, "item_name": "Tomatoes", "quantity_kg": 5.0, "latitude": 3.8150, "longitude": 103.3280, "price": 27.50, "price_per_kg": 5.50, "method": "Pickup", "seller_name": "Neighbor Siti"},
    {"id": 202, "item_name": "Spinach (Bayam)", "quantity_kg": 2.5, "latitude": 3.8100, "longitude": 103.3200, "price": 11.25, "price_per_kg": 4.50, "method": "Delivery", "seller_name": "Neighbor Ali"},
    {"id": 203, "item_name": "Chili Padi", "quantity_kg": 1.2, "latitude": 3.8200, "longitude": 103.3300, "price": 19.20, "price_per_kg": 16.00, "method": "Pickup", "seller_name": "Neighbor Chong"},
    {"id": 204, "item_name": "Okra (Bendi)", "quantity_kg": 3.0, "latitude": 3.8180, "longitude": 103.3220, "price": 21.00, "price_per_kg": 7.00, "method": "Pickup", "seller_name": "Neighbor Kumar"},
    {"id": 205, "item_name": "Papaya", "quantity_kg": 10.0, "latitude": 3.8050, "longitude": 103.3350, "price": 45.00, "price_per_kg": 4.50, "method": "Delivery", "seller_name": "Neighbor Tan"},
    {"id": 206, "item_name": "Mango", "quantity_kg": 4.5, "latitude": 3.8250, "longitude": 103.3150, "price": 67.50, "price_per_kg": 15.00, "method": "Pickup", "seller_name": "Neighbor Lee"},
  ];
  
  static List<Map<String, dynamic>> localOrders = [];

  // --- THE MASTER HANDSHAKE FIX ---
  static Future<void> approveTransaction(int orderId, bool isBuyer) async {
    final index = localOrders.indexWhere((o) => o['id'] == orderId);
    if (index != -1) {
      // 1. Mark as complete
      localOrders[index]['status'] = "Completed";
      localOrders[index]['completed_at'] = DateTime.now().toIso8601String();
      localOrders[index]['buyer_approved'] = true;
      localOrders[index]['seller_approved'] = true;
      
      // 2. THE MAP FIX: Remove from the map permanently
      int listingId = localOrders[index]['surplus']['id'];
      localSurplus.removeWhere((item) => item['id'] == listingId);
    }
  }

  // --- Routes & Connectivity ---
  static const String diagnoseUrl = '$gatewayUrl/api/vision/api/ai/diagnose';
  static const String assistantUrl = '$gatewayUrl/api/vision/api/ai/assistant';
  static const String surplusUrl = '$gatewayUrl/api/data/api/data/surplus';
  static const String addSurplusUrl = '$gatewayUrl/api/data/api/data/add';
  static const String orderUrl = '$gatewayUrl/api/data/api/data/order';
  static const String historyUrl = '$gatewayUrl/api/data/api/data/history';

  static Future<void> openMapDirections(double lat, double lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  static Future<bool> placeOrder(Map<String, dynamic> cluster, String buyerName, String method) async {
    // Claim existing if possible
    final existingIndex = localOrders.indexWhere((o) => o['surplus']['id'] == cluster['id']);
    if (existingIndex != -1) {
      localOrders[existingIndex]['buyer_name'] = buyerName;
      localOrders[existingIndex]['delivery_method'] = method;
      return true;
    }

    localOrders.add({
      "id": DateTime.now().millisecondsSinceEpoch,
      "buyer_name": buyerName,
      "seller_name": cluster['seller_name'] ?? "Neighbor",
      "status": "Pending", 
      "buyer_approved": false,
      "seller_approved": false,
      "delivery_method": method,
      "created_at": DateTime.now().toIso8601String(),
      "surplus": {
        ...cluster,
        "price": cluster['price'] ?? 0.0,
        "price_per_kg": cluster['price_per_kg'] ?? 0.0,
      }
    });
    return true;
  }

  static Future<bool> listSurplus(String name, double kg, double lat, double lon, double price, String method, String? imagePath) async {
    final newItem = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "item_name": name,
      "quantity_kg": kg,
      "latitude": lat,
      "longitude": lon,
      "price": price,
      "price_per_kg": kg > 0 ? (price / kg) : 0.0,
      "method": method,
      "image_path": imagePath,
      "seller_name": "Ahmad bin Razak"
    };
    
    localSurplus.add(newItem);
    
    localOrders.add({
      "id": newItem['id'],
      "buyer_name": "Awaiting Buyer",
      "seller_name": "Ahmad bin Razak",
      "status": "Pending",
      "buyer_approved": false,
      "seller_approved": false,
      "delivery_method": method, 
      "created_at": DateTime.now().toIso8601String(),
      "surplus": newItem
    });
    return true;
  }

  static Future<List<dynamic>> getNeighborhoodSurplus(double lat, double lon) async {
    return List.from(localSurplus);
  }

  static Future<List<dynamic>> getHistory(String name) async {
    return List.from(localOrders);
  }

  static Future<Map<String, dynamic>?> getListingAssistant(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(assistantUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        return jsonDecode(responseData)['data'];
      }
      return null;
    } catch (e) { return null; }
  }

  static Future<Map<String, dynamic>?> analyzePlant(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(diagnoseUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      }
      return null;
    } catch (e) { return null; }
  }

  static Future<String> pingBackend() async {
    try {
      final response = await http.get(Uri.parse('$gatewayUrl/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 ? "Success" : "Offline";
    } catch (e) { return "Offline"; }
  }
}
