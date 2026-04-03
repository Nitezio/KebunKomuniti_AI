import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, or your real Laptop IP for physical phones.
  static const String gatewayIp = '10.0.2.2';
  static const String gatewayUrl = 'http://$gatewayIp';

  // Endpoints routed via NGINX Gateway
  static const String diagnoseUrl = '$gatewayUrl/api/vision/api/ai/diagnose';
  static const String surplusUrl = '$gatewayUrl/api/data/api/data/surplus';

  // --- Connection Test ---
  static Future<String> pingBackend() async {
    try {
      final response = await http.get(Uri.parse('$gatewayUrl/health')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return "Success: ${data['status']}";
      }
      return "Error: Gateway responded with ${response.statusCode}";
    } catch (e) {
      return "Connection failed. Is Docker running? Error: $e";
    }
  }

  // --- AI Diagnosis ---
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
      print("AI Error: $e");
      return null;
    }
  }

  // --- Neighborhood Aggregator (The Marketplace) ---
  static Future<List<dynamic>> getNeighborhoodSurplus(double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(surplusUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "latitude": lat,
          "longitude": lon,
          "radius_km": 5.0
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['clusters'] ?? [];
      }
      return [];
    } catch (e) {
      print("Marketplace Error: $e");
      return [];
    }
  }
}
