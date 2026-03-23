import 'dart:async';
import 'package:flutter/material.dart';
import '../models/irrigation_data.dart';
import '../models/irrigation_history_item.dart';
import '../service/api_service.dart';
import '../service/notification_service.dart';
import '../widgets/info_card.dart';
import '../widgets/status_card.dart';
import 'history_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  IrrigationData currentData = IrrigationData.empty();
  List<IrrigationHistoryItem> history = [];

  bool isLoading = true;
  String? errorMessage;
  Timer? _timer;

  DateTime? lastNotification;

  @override
  void initState() {
    super.initState();
    loadAllData();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadAllData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadAllData() async {
    try {
      final latest = await ApiService.fetchLatestData();
      final historyData = await ApiService.fetchHistory();

      checkNotifications(latest);

      setState(() {
        currentData = latest;
        history = historyData.reversed.toList();
        errorMessage = null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // 🔔 LOGIQUE NOTIFICATIONS
  void checkNotifications(IrrigationData data) {
    final now = DateTime.now();

    if (lastNotification != null &&
        now.difference(lastNotification!).inSeconds < 30) {
      return;
    }

    if (data.moisture < 30) {
      NotificationService.showNotification(
        title: "🚨 Arrosage urgent",
        body: "Humidité critique (${data.moisture.toStringAsFixed(1)}%)",
      );
    } else if (data.aiDecision == 1) {
      NotificationService.showNotification(
        title: "🌱 Arrosage recommandé",
        body:
        "Volume conseillé : ${data.waterQuantity.toStringAsFixed(2)} L",
      );
    }

    if (data.aiDecision == 1 && data.flow == 0) {
      NotificationService.showNotification(
        title: "⚠️ Défaillance système",
        body: "Aucun débit détecté",
      );
    }

    lastNotification = now;
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String formatTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute}";
  }

  Widget buildDashboard() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 10),
            Text(errorMessage!),
            ElevatedButton(
              onPressed: loadAllData,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🔵 HEADER
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("HydroSense",
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 5),
              Text(
                currentData.decisionLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                currentData.statusMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 📊 STATUS
        StatusCard(
          title: "État vanne",
          value: currentData.valveLabel,
          color: currentData.valveState == 1
              ? Colors.green
              : Colors.red,
          icon: Icons.water,
        ),

        const SizedBox(height: 10),

        StatusCard(
          title: "Décision IA",
          value: currentData.decisionLabel,
          color: currentData.aiDecision == 1
              ? Colors.green
              : Colors.orange,
          icon: Icons.psychology,
        ),

        const SizedBox(height: 20),

        // 📊 INFOS
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: "Humidité",
                value:
                "${currentData.moisture.toStringAsFixed(1)} %",
                icon: Icons.grass,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InfoCard(
                title: "Débit",
                value:
                "${currentData.flow.toStringAsFixed(2)} L/min",
                icon: Icons.speed,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: "Quantité",
                value:
                "${currentData.waterQuantity.toStringAsFixed(2)} L",
                icon: Icons.water_drop,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InfoCard(
                title: "Heure",
                value: formatTime(currentData.timestamp),
                icon: Icons.access_time,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 📋 TABLE HISTORIQUE
        const Text(
          "Historique récent",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Humidité')),
              DataColumn(label: Text('Débit')),
              DataColumn(label: Text('Vanne')),
              DataColumn(label: Text('Quantité')),
              DataColumn(label: Text('Heure')),
            ],
            rows: history.take(10).map((item) {
              return DataRow(cells: [
                DataCell(Text(item.id.toString())),
                DataCell(Text("${item.moisture.toStringAsFixed(1)}%")),
                DataCell(Text("${item.flow.toStringAsFixed(2)}")),
                DataCell(Text(item.valveLabel)),
                DataCell(Text("${item.waterQuantity.toStringAsFixed(2)}")),
                DataCell(Text(formatTime(item.timestamp))),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildDashboard(),
      HistoryPage(history: history),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("HydroSense"),
        actions: [
          IconButton(
            onPressed: loadAllData,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home), label: "Accueil"),
          NavigationDestination(
              icon: Icon(Icons.history), label: "Historique"),
          NavigationDestination(
              icon: Icon(Icons.settings), label: "Paramètres"),
        ],
      ),
    );
  }
}