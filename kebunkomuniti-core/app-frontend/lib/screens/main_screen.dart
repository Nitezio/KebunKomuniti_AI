import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'camera_screen.dart';
import 'home_screen.dart';
import 'activity_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // THE REFRESH FIX: 
  // We now use a function to return the widget. 
  // This forces the page to reload its data every time you tap the tab.
  Widget _getPage(int index) {
    switch (index) {
      case 0: return const MapScreen();
      case 1: return const CameraScreen();
      case 2: return const ActivityScreen();
      case 3: return const HomeScreen();
      default: return const MapScreen();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex), // No more cache, always fresh data for the demo
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: Colors.green.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Colors.green),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner, color: Colors.green),
            label: 'AI Doctor',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.green),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Colors.green),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
