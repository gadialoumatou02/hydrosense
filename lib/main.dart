import 'package:flutter/material.dart';
import 'package:hydrosense/pages/home_page.dart';

void main() {
  runApp(const HydroSenseApp());
}

class HydroSenseApp extends StatelessWidget {
  const HydroSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
      ),
      home: const HomePage(),
    );
  }
}
