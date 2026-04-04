import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService {
  static const String gatewayIp = '10.0.2.2';
  static const String gatewayUrl = 'http://$gatewayIp';

  // AI Routes
  static const String diagnoseUrl = '$gatewayUrl/api/vision/api/ai/diagnose';
  static const String assistantUrl = '$gatewayUrl/api/vision/api/ai/assistant';

  // Data Routes
  static const String surplusUrl = '$gatewayUrl/api/data/api/data/surplus';
  static const String addSurplusUrl = '$gatewayUrl/api/data/api/data/add';
  static const String orderUrl = '$gatewayUrl/api/data/api/data/order';
  static const String historyUrl = '$gatewayUrl/api/data/api/data/history';

  // --- AI Assistant (The Seller's Helper) ---
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
    } catch (e) {
      print("Assistant Error: $e");
      return null;
    }
  }

  // --- Marketplace Order ---
  static Future<bool> placeOrder(int id, String name, String method) async {
    try {
      final response = await http.post(
        Uri.parse(orderUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"listing_id": id, "buyer_name": name, "delivery_method": method}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Order History ---
  static Future<List<dynamic>> getHistory(String name) async {
    try {
      final response = await http.get(Uri.parse('$historyUrl/$name'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['orders'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- Existing Logic ---
  static Future<String> pingBackend() async {
    try {
      final response = await http.get(Uri.parse('$gatewayUrl/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 ? "Success" : "Offline";
    } catch (e) {
      return "Error";
    }
  }

  static Future<Map<String, dynamic>?> analyzePlant(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(diagnoseUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getNeighborhoodSurplus(double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(surplusUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"latitude": lat, "longitude": lon, "radius_km": 5.0}),
      );
      return response.statusCode == 200 ? jsonDecode(response.body)['clusters'] : [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> listSurplus(String name, double kg, double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(addSurplusUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"item_name": name, "quantity_kg": kg, "latitude": lat, "longitude": lon}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
