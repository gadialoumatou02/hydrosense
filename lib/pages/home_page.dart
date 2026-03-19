import 'dart:async';
import 'package:flutter/material.dart';
import '../models/irrigation_data.dart';
import '../models/irrigation_history_item.dart';
import '../service/api_service.dart';
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
  final List<IrrigationHistoryItem> history = [];

  bool isLoading = true;
  String? errorMessage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadLatestData();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadLatestData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadLatestData() async {
    try {
      final data = await ApiService.fetchLatestData();

      setState(() {
        currentData = data;
        errorMessage = null;
        isLoading = false;

        history.insert(
          0,
          IrrigationHistoryItem.fromData(
            timestamp: data.timestamp,
            moisture: data.moisture,
            flow: data.flow,
            valveState: data.valveState,
            aiDecision: data.aiDecision,
            waterQuantity: data.waterQuantity,
          ),
        );

        if (history.length > 50) {
          history.removeLast();
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  String formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$minute';
  }

  Color valveColor(int valveState) {
    return valveState == 1 ? Colors.green : Colors.red;
  }

  IconData valveIcon(int valveState) {
    return valveState == 1 ? Icons.water : Icons.water_drop_outlined;
  }

  Color decisionColor(int aiDecision) {
    return aiDecision == 1 ? Colors.green : Colors.orange;
  }

  IconData decisionIcon(int aiDecision) {
    return aiDecision == 1 ? Icons.check_circle : Icons.pause_circle;
  }

  Widget buildDashboard() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Impossible de charger les données.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loadLatestData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadLatestData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
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
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Système d’arrosage intelligent',
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
                    fontSize: 30,
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
                const SizedBox(height: 12),
                Text(
                  'Dernière mise à jour : ${formatDateTime(currentData.timestamp)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          StatusCard(
            title: 'État de la vanne',
            value: currentData.valveLabel,
            color: valveColor(currentData.valveState),
            icon: valveIcon(currentData.valveState),
          ),
          const SizedBox(height: 12),

          StatusCard(
            title: 'Décision de l’IA',
            value: currentData.decisionLabel,
            color: decisionColor(currentData.aiDecision),
            icon: decisionIcon(currentData.aiDecision),
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
                  title: 'Vanne',
                  value: currentData.valveLabel,
                  icon: Icons.settings_input_component,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Dernières lectures',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (history.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Aucune donnée reçue pour le moment.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...history.take(5).map(
                  (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.decisionLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Humidité : ${item.moisture.toStringAsFixed(1)} %'),
                    Text('Débit : ${item.flow.toStringAsFixed(2)} L/min'),
                    Text('Vanne : ${item.valveLabel}'),
                    Text(
                      'Quantité d’eau : ${item.waterQuantity.toStringAsFixed(2)} L',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(item.timestamp),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
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
            onPressed: loadLatestData,
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