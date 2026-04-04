import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ApiService {
  static const String gatewayIp = '10.0.2.2';
  static const String gatewayUrl = 'http://$gatewayIp';

  // --- LOCAL DEMO STORAGE (The "Mock" Database) ---
  // This ensures the app works perfectly for your pitch even without Supabase
  static List<Map<String, dynamic>> localSurplus = [
    {"id": 101, "item_name": "Organic Tomatoes", "quantity_kg": 5.0, "latitude": 3.8150, "longitude": 103.3280, "price": 12.0},
    {"id": 102, "item_name": "Fresh Spinach", "quantity_kg": 2.5, "latitude": 3.8100, "longitude": 103.3200, "price": 8.0},
  ];
  
  static List<Map<String, dynamic>> localOrders = [];

  // --- Endpoints ---
  static const String diagnoseUrl = '$gatewayUrl/api/vision/api/ai/diagnose';
  static const String assistantUrl = '$gatewayUrl/api/vision/api/ai/assistant';
  static const String surplusUrl = '$gatewayUrl/api/data/api/data/surplus';
  static const String addSurplusUrl = '$gatewayUrl/api/data/api/data/add';
  static const String orderUrl = '$gatewayUrl/api/data/api/data/order';
  static const String historyUrl = '$gatewayUrl/api/data/api/data/history';

  // --- Directions Logic ---
  static Future<void> openMapDirections(double lat, double lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // --- Order Logic ---
  static Future<bool> placeOrder(Map<String, dynamic> cluster, String buyerName, String method) async {
    // 1. Try real DB
    try {
      final response = await http.post(
        Uri.parse(orderUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"listing_id": cluster['id'], "buyer_name": buyerName, "delivery_method": method}),
      );
      if (response.statusCode == 200) return true;
    } catch (e) { print("DB Order failed, using local backup"); }

    // 2. Local Backup (Keep demo running)
    localOrders.add({
      "id": DateTime.now().millisecondsSinceEpoch,
      "buyer_name": buyerName,
      "status": "Pending",
      "delivery_method": method,
      "created_at": DateTime.now().toIso8601String(),
      "surplus": cluster
    });
    return true;
  }

  // --- Listing Logic ---
  static Future<bool> listSurplus(String name, double kg, double lat, double lon, double price) async {
    final newItem = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "item_name": name,
      "quantity_kg": kg,
      "latitude": lat,
      "longitude": lon,
      "price": price,
      "status": "Pending"
    };

    // 1. Try real DB
    try {
      await http.post(Uri.parse(addSurplusUrl), headers: {"Content-Type": "application/json"},
        body: jsonEncode({"item_name": name, "quantity_kg": kg, "latitude": lat, "longitude": lon}),
      );
    } catch (e) { print("DB List failed, using local backup"); }

    // 2. Local Backup
    localSurplus.add(newItem);
    localOrders.add({
      "id": newItem['id'],
      "buyer_name": "Ahmad bin Razak", // User is the seller
      "status": "Pending",
      "delivery_method": "Selling", 
      "created_at": DateTime.now().toIso8601String(),
      "surplus": newItem
    });
    return true;
  }

  // --- Fetch Logic (Combines real DB + local memory) ---
  static Future<List<dynamic>> getNeighborhoodSurplus(double lat, double lon) async {
    List<dynamic> combined = List.from(localSurplus);
    try {
      final response = await http.post(Uri.parse(surplusUrl), headers: {"Content-Type": "application/json"},
        body: jsonEncode({"latitude": lat, "longitude": lon, "radius_km": 5.0}),
      );
      if (response.statusCode == 200) {
        combined.addAll(jsonDecode(response.body)['clusters']);
      }
    } catch (e) { print("DB Fetch failed, using local demo data"); }
    return combined;
  }

  static Future<List<dynamic>> getHistory(String name) async {
    return localOrders; // For demo, we show everything we've done locally
  }

  // --- AI Logic ---
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
