import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'service/notification_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
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
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
      ),
      home: const HomePage(),
    );
  }
}