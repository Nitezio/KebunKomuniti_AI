import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _serverStatus = "Connected";
  bool _isLoading = false;

  void _testConnection() async {
    setState(() => _isLoading = true);
    String result = await ApiService.pingBackend();
    setState(() {
      _isLoading = false;
      _serverStatus = result.contains("Success") ? "Online" : "Offline";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status: $result")));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWideScreen ? 600 : double.infinity),
          child: SingleChildScrollView( // Changed from CustomScrollView to fix overlap
            child: Column(
              children: [
                // 1. New Overlap-Proof Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.green.shade400, Colors.green.shade800],
                    ),
                    borderRadius: isWideScreen 
                      ? const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32))
                      : BorderRadius.zero,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "MY ACCOUNT",
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const SizedBox(height: 24),
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Ahmad bin Razak",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Community Farmer • $_serverStatus",
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // 2. Content Body
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Account Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildSettingRow("Language", "English (MY)", Icons.language),
                      _buildSettingRow("Location Privacy", "3km Radius", Icons.location_on),
                      
                      ListTile(
                        onTap: _testConnection,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.sync, color: Colors.grey.shade600),
                        title: const Text("Sync with Hub"),
                        trailing: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Icon(Icons.chevron_right, color: Colors.grey),
                      ),

                      const SizedBox(height: 48),

                      const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildActivityRow("AI Scan: Tomato Leaf", "2 hours ago", Icons.document_scanner),
                      _buildActivityRow("Sold 2kg Chili", "Yesterday", Icons.sell),
                      
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityRow(String title, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: Colors.green.shade700),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 16),
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey.shade600, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}
