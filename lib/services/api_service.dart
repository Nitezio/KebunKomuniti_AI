import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService {
  // Your teammate's local IP Address
  static const String backendUrl = 'http://10.203.82.220:8000/api/ai/diagnose';

  // --- DAY 1: Network Ping Test (This fixes your error!) ---
  static Future<String> pingBackend() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
      if (response.statusCode == 200) return "Success: Reached the network!";
      return "Error: Server responded with ${response.statusCode}";
    } catch (e) {
      return "Connection failed: $e";
    }
  }

  // --- DAY 3: AI Diagnosis Request ---
  static Future<Map<String, dynamic>?> analyzePlant(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Network error: $e");
      return null;
    }
  }
}