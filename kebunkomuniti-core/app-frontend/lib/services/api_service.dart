import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService {
  // Pointing to your teammate's machine, but now hitting the NGINX Gateway (Port 80)
  static const String gatewayIp = '10.0.2.2';
  static const String gatewayUrl = 'http://$gatewayIp:8000';

  // THE ROUTING FIX:
  // NGINX intercepts '/api/vision/' and proxies it to the backend.
  // The backend specifically expects '/api/ai/diagnose'.
  // Combining them gets us safely through the gateway without changing backend code!
  static const String diagnoseUrl = '$gatewayUrl/api/vision/api/ai/diagnose';

  // --- DAY 1: Real Network Ping Test ---
  // Now pings the actual NGINX /health route created by your teammate
  static Future<String> pingBackend() async {
    try {
      final response = await http.get(Uri.parse('$gatewayUrl/health'));
      if (response.statusCode == 200) {
        // NGINX returns: {"status": "Gateway Operational"}
        var data = jsonDecode(response.body);
        return "Success: ${data['status']}";
      }
      return "Error: Gateway responded with ${response.statusCode}";
    } catch (e) {
      return "Connection failed. Is the teammate's Docker running? Error: $e";
    }
  }

  // --- DAY 3: AI Diagnosis Request ---
  static Future<Map<String, dynamic>?> analyzePlant(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(diagnoseUrl));

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
