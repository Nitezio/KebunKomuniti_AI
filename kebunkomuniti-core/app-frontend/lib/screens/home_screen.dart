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
    setState(() {
      _isLoading = true;
    });

    String result = await ApiService.pingBackend();

    setState(() {
      _isLoading = false;
      _serverStatus = result.contains("Success") ? "Online" : "Offline";
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connection Status: $result")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: CustomScrollView(
        slivers: [
          // 1. Sleek Header (Commercial Look)
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green.shade700,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // Fixed: Centered Title
              title: const Text("My Account", style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.green.shade400, Colors.green.shade800],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Colors.green),
                      ),
                      const SizedBox(height: 10),
                      const Text("Ahmad bin Razak", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Community Farmer • $_serverStatus", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Settings Section (Moved Up)
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

                  const SizedBox(height: 40),

                  // 3. Activity Section (Moved to Bottom)
                  const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildActivityRow("AI Scan: Tomato Leaf", "2 hours ago", Icons.document_scanner),
                  _buildActivityRow("Sold 2kg Chili", "Yesterday", Icons.sell),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String title, String time, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: Colors.green),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 16),
    );
  }

  Widget _buildSettingRow(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
