import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'camera_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // The actual screens you have built!
  final List<Widget> _pages = [
    const MapScreen(),      // Tab 0: The Community Map
    const CameraScreen(),   // Tab 1: The AI Plant Doctor
    HomeScreen(),           // Tab 2: The Network Ping Test
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Community Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Plant Doctor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_ping),
            label: 'Network Test',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        onTap: _onItemTapped,
      ),
    );
  }
}