import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _serverStatus = "Waiting to ping server...";
  bool _isLoading = false;

  void _testConnection() async {
    setState(() {
      _isLoading = true;
      _serverStatus = "Pinging...";
    });

    // Call your API service
    String result = await ApiService.pingBackend();

    setState(() {
      _isLoading = false;
      _serverStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KebunKomuniti', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 80, color: Colors.green[600]),
              const SizedBox(height: 20),
              const Text(
                "Backend Connection Status:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _serverStatus,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Show a loading spinner if fetching, otherwise show the button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.network_ping),
                label: const Text("Ping Backend API"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}