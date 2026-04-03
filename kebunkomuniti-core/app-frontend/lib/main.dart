import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Add this import

void main() {
  runApp(const KebunKomunitiApp());
}

class KebunKomunitiApp extends StatelessWidget {
  const KebunKomunitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KebunKomuniti',
      // Inside main.dart
      theme: ThemeData(
        useMaterial3: true, // <--- Add this!
        colorSchemeSeed: Colors.green, // Lets Flutter generate a perfect matching palette
        // ...
      ),
      home: const MainScreen(), // Change this line!
      debugShowCheckedModeBanner: false,
    );
  }
}
