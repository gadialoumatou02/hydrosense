import 'dart:async';
import 'package:flutter/material.dart';
import '../models/irrigation_data.dart';
import '../models/irrigation_history_item.dart';
import '../service/api_service.dart';
import '../service/notification_service.dart';
import '../widgets/info_card.dart';
import '../widgets/status_card.dart';
import '../widgets/moisture_chart.dart';
import '../widgets/flow_chart.dart';
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

  IrrigationData? previousData;
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
        previousData = currentData;
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

  void checkNotifications(IrrigationData data) {
    final now = DateTime.now();

    if (lastNotification != null &&
        now.difference(lastNotification!).inSeconds < 20) {
      return;
    }

    final prev = previousData;

    final bool becameIrrigationRecommended =
        prev != null && prev.aiDecision == 0 && data.aiDecision == 1;

    final bool urgentMoisture =
        data.moisture < 30 && (prev == null || prev.moisture >= 30);

    final bool systemFailure =
        data.aiDecision == 1 &&
            (data.flow <= 0 || data.valveState == 0) &&
            (prev == null ||
                !(prev.aiDecision == 1 &&
                    (prev.flow <= 0 || prev.valveState == 0)));

    if (urgentMoisture) {
      NotificationService.showNotification(
        id: 1,
        title: '🚨 Arrosage urgent',
        body: 'Humidité critique : ${data.moisture.toStringAsFixed(1)} %',
      );
      lastNotification = now;
      return;
    }

    if (systemFailure) {
      NotificationService.showNotification(
        id: 2,
        title: '⚠️ Défaillance du système',
        body: 'Arrosage demandé mais vanne fermée ou débit nul.',
      );
      lastNotification = now;
      return;
    }

    if (becameIrrigationRecommended) {
      NotificationService.showNotification(
        id: 3,
        title: '🌱 Arrosage recommandé',
        body:
        'L’IA recommande ${data.waterQuantity.toStringAsFixed(2)} L d’eau.',
      );
      lastNotification = now;
      return;
    }

    if (prev == null && data.aiDecision == 1) {
      NotificationService.showNotification(
        id: 4,
        title: '🌱 Arrosage recommandé',
        body:
        'Volume conseillé : ${data.waterQuantity.toStringAsFixed(2)} L',
      );
      lastNotification = now;
    }
  }

  void triggerRecommendedNotification() {
    final testData = IrrigationData(
      timestamp: DateTime.now(),
      moisture: 45.0,
      flow: 1.1,
      valveState: 1,
      aiDecision: 1,
      waterQuantity: 1.50,
    );

    previousData = IrrigationData.empty();
    checkNotifications(testData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification arrosage envoyé')),
    );
  }

  void triggerUrgentNotification() {
    final testData = IrrigationData(
      timestamp: DateTime.now(),
      moisture: 22.0,
      flow: 0.7,
      valveState: 1,
      aiDecision: 1,
      waterQuantity: 2.30,
    );

    previousData = IrrigationData(
      timestamp: DateTime.now(),
      moisture: 40.0,
      flow: 0.0,
      valveState: 0,
      aiDecision: 0,
      waterQuantity: 0.0,
    );

    checkNotifications(testData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification urgente envoyé')),
    );
  }

  void triggerFailureNotification() {
    final testData = IrrigationData(
      timestamp: DateTime.now(),
      moisture: 28.0,
      flow: 0.0,
      valveState: 0,
      aiDecision: 1,
      waterQuantity: 1.80,
    );

    previousData = IrrigationData(
      timestamp: DateTime.now(),
      moisture: 35.0,
      flow: 0.8,
      valveState: 1,
      aiDecision: 0,
      waterQuantity: 0.5,
    );

    checkNotifications(testData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification défaillance envoyé')),
    );
  }

  String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget buildDashboard() {
    if (isLoading && errorMessage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Serveur indisponible — mode test activé',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(errorMessage!),
                  const SizedBox(height: 8),
                  const Text(
                    'Les notifications automatiques sont désactivées. '
                        'Tu peux tester manuellement les alertes ci-dessous.',
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4FACFE),
                  Color(0xFF00C6FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HydroSense',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentData.decisionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentData.statusMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mise à jour : ${formatDate(currentData.timestamp)} à ${formatTime(currentData.timestamp)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (errorMessage != null) ...[
            const Text(
              'Tests notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: triggerRecommendedNotification,
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Arrosage'),
                ),
                FilledButton.icon(
                  onPressed: triggerUrgentNotification,
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Urgent'),
                ),
                FilledButton.icon(
                  onPressed: triggerFailureNotification,
                  icon: const Icon(Icons.error_outline),
                  label: const Text('Défaillance'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          StatusCard(
            title: 'État de la vanne',
            value: currentData.valveLabel,
            color: currentData.valveState == 1 ? Colors.green : Colors.red,
            icon: currentData.valveState == 1
                ? Icons.water
                : Icons.water_drop_outlined,
          ),
          const SizedBox(height: 12),

          StatusCard(
            title: 'Décision IA',
            value: currentData.decisionLabel,
            color: currentData.aiDecision == 1 ? Colors.green : Colors.orange,
            icon: Icons.psychology,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: 'Humidité',
                  value: '${currentData.moisture.toStringAsFixed(1)} %',
                  icon: Icons.grass,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: 'Débit',
                  value: '${currentData.flow.toStringAsFixed(2)} L/min',
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: 'Quantité d’eau',
                  value: '${currentData.waterQuantity.toStringAsFixed(2)} L',
                  icon: Icons.water_drop,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: 'Heure',
                  value: formatTime(currentData.timestamp),
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Évolution de l’humidité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: MoistureChart(data: history),
          ),
          const SizedBox(height: 24),

          const Text(
            'Évolution du débit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: FlowChart(data: history),
          ),
          const SizedBox(height: 24),

          const Text(
            'Historique récent',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: SingleChildScrollView(
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
                  return DataRow(
                    cells: [
                      DataCell(Text(item.id.toString())),
                      DataCell(Text('${item.moisture.toStringAsFixed(1)} %')),
                      DataCell(Text('${item.flow.toStringAsFixed(3)} L/min')),
                      DataCell(Text(item.valveLabel)),
                      DataCell(Text('${item.waterQuantity.toStringAsFixed(2)} L')),
                      DataCell(Text(formatTime(item.timestamp))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
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
        title: const Text(
          'HydroSense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadAllData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
