import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Add this import

void main() {
  runApp(const KebunKomunitiApp());
}

class KebunKomunitiApp extends StatelessWidget {
  const KebunKomunitiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KebunKomuniti',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const MainScreen(), // Change this line!
      debugShowCheckedModeBanner: false,
    );
  }
}
