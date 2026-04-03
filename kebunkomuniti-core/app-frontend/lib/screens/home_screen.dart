import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _serverStatus = "Ready to connect";
  bool _isLoading = false;

  void _testConnection() async {
    setState(() {
      _isLoading = true;
      _serverStatus = "Establishing connection...";
    });

    String result = await ApiService.pingBackend();

    setState(() {
      _isLoading = false;
      _serverStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "System Hub",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade900),
              ),
              Text(
                "Manage your local micro-services.",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.dns_rounded, size: 48, color: Colors.green.shade600),
                    ),
                    const SizedBox(height: 24),
                    const Text("Gateway Status", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      _serverStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _serverStatus.contains("Error") ? Colors.red.shade700 : Colors.black87),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Ping Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _testConnection,
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.sensors),
                  label: Text(_isLoading ? "Pinging..." : "Test Gateway Connection", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}