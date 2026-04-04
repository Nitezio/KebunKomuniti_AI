import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // --- THE SMART GATEWAY FIX ---
  static String get gatewayUrl {
    if (kIsWeb) {
      // In Web, use the current domain (removes 'localhost' hardcoding)
      // This handles Ngrok, Localhost, or a real Domain automatically.
      String origin = Uri.base.origin;
      return origin;
    }
    // In Mobile Emulator, use the standard bridge
    return 'http://10.0.2.2';
  }

  // --- Ngrok Bypass Header ---
  static const Map<String, String> ngrokHeaders = {
    "ngrok-skip-browser-warning": "true",
  };

  // --- Endpoints ---
  static String get diagnoseUrl => '$gatewayUrl/api/vision/api/ai/diagnose';
  static String get assistantUrl => '$gatewayUrl/api/vision/api/ai/assistant';
  static String get surplusUrl => '$gatewayUrl/api/data/api/data/surplus';
  static String get addSurplusUrl => '$gatewayUrl/api/data/api/data/add';
  static String get orderUrl => '$gatewayUrl/api/data/api/data/order';
  static String get historyUrl => '$gatewayUrl/api/data/api/data/history';

  // --- Price Regulation Data ---
  static const Map<String, double> regulatedPrices = {
    "Tomatoes": 5.50, "Chili Padi": 16.00, "Spinach (Bayam)": 4.50, "Okra (Bendi)": 7.00, "Mustard Green (Sawi)": 5.00, "Eggplant (Terung)": 6.50, "Mango": 15.00, "Papaya": 4.50,
  };

  static List<Map<String, dynamic>> localSurplus = [
    {"id": 201, "item_name": "Tomatoes", "quantity_kg": 5.0, "latitude": 3.8150, "longitude": 103.3280, "price": 27.50, "price_per_kg": 5.50, "method": "Pickup", "seller_name": "Neighbor Siti"},
  ];
  static List<Map<String, dynamic>> localOrders = [];

  static Future<void> approveTransaction(int orderId, bool isBuyer) async {
    final index = localOrders.indexWhere((o) => o['id'] == orderId);
    if (index != -1) {
      localOrders[index]['status'] = "Completed";
      localOrders[index]['completed_at'] = DateTime.now().toIso8601String();
      localSurplus.removeWhere((item) => item['id'] == localOrders[index]['surplus']['id']);
    }
  }

  static Future<void> openMapDirections(double lat, double lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  static Future<Map<String, dynamic>?> analyzePlant(XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(diagnoseUrl));
      request.headers.addAll(ngrokHeaders); // BYPASS NGROK WARNING
      
      if (kIsWeb) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getListingAssistant(XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(assistantUrl));
      request.headers.addAll(ngrokHeaders);
      
      if (kIsWeb) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        return jsonDecode(responseData)['data'];
      }
      return null;
    } catch (e) { return null; }
  }

  static Future<bool> placeOrder(Map<String, dynamic> cluster, String buyerName, String method) async {
    localOrders.add({
      "id": DateTime.now().millisecondsSinceEpoch, "buyer_name": buyerName, "seller_name": cluster['seller_name'] ?? "Neighbor", "status": "Pending", "delivery_method": method, "created_at": DateTime.now().toIso8601String(), "surplus": cluster
    });
    return true;
  }

  static Future<bool> listSurplus(String name, double kg, double lat, double lon, double price, String method, String? imagePath) async {
    localSurplus.add({
      "id": DateTime.now().millisecondsSinceEpoch,
      "item_name": name, "quantity_kg": kg, "latitude": lat, "longitude": lon, "price": price, "price_per_kg": (price/kg), "method": method, "image_path": imagePath, "seller_name": "Ahmad bin Razak"
    });
    return true;
  }

  static Future<List<dynamic>> getNeighborhoodSurplus(double lat, double lon) async => List.from(localSurplus);
  static Future<List<dynamic>> getHistory(String name) async => List.from(localOrders);

  static Future<String> pingBackend() async {
    try {
      final response = await http.get(Uri.parse('$gatewayUrl/health'), headers: ngrokHeaders).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 ? "Success" : "Offline";
    } catch (e) { return "Offline"; }
  }
}
