import 'dart:async';
import 'package:flutter/material.dart';
import '../models/irrigation_data.dart';
import '../models/irrigation_history_item.dart';
import '../service/websocket_service.dart';
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

  late final WebSocketService _webSocketService;
  StreamSubscription<IrrigationData>? _subscription;

  IrrigationData currentData = IrrigationData.empty();
  final List<IrrigationHistoryItem> history = [];

  @override
  void initState() {
    super.initState();

    _webSocketService = WebSocketService(
      // Remplace l’IP par l’IP de ton backend
      url: 'ws://192.168.1.100:8000/ws',
    );

    _webSocketService.connect();

    _subscription = _webSocketService.stream.listen((data) {
      setState(() {
        currentData = data;
        history.insert(
          0,
          IrrigationHistoryItem(
            soilMoisture: data.soilMoisture,
            temperature: data.temperature,
            recommendedVolumeMl: data.recommendedVolumeMl,
            wateredVolumeMl: data.wateredVolumeMl,
            decision: data.decision,
            valveState: data.valveState,
            status: data.status,
            timestamp: data.timestamp,
          ),
        );

        if (history.length > 50) {
          history.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color decisionColor(String decision) {
    switch (decision) {
      case 'ARROSER':
        return Colors.green;
      case 'ARROSAGE_BIENTOT':
        return Colors.orange;
      case 'NE_PAS_ARROSER':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData decisionIcon(String decision) {
    switch (decision) {
      case 'ARROSER':
        return Icons.check_circle;
      case 'ARROSAGE_BIENTOT':
        return Icons.schedule;
      case 'NE_PAS_ARROSER':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color valveColor(String valveState) {
    switch (valveState) {
      case 'OPEN':
        return Colors.green;
      case 'CLOSED':
        return Colors.red;
      case 'ERROR':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData valveIcon(String valveState) {
    switch (valveState) {
      case 'OPEN':
        return Icons.water;
      case 'CLOSED':
        return Icons.water_drop_outlined;
      case 'ERROR':
        return Icons.warning_amber_rounded;
      default:
        return Icons.device_unknown;
    }
  }

  Widget buildDashboard() {
    return ListView(
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
                currentData.decision,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentData.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Dernière mise à jour : ${formatTime(currentData.timestamp)}',
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
          value: currentData.valveState,
          color: valveColor(currentData.valveState),
          icon: valveIcon(currentData.valveState),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Décision du système',
          value: currentData.decision,
          color: decisionColor(currentData.decision),
          icon: decisionIcon(currentData.decision),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'État global',
          value: currentData.status,
          color: Colors.blue,
          icon: Icons.settings_remote,
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: 'Humidité du sol',
                value: '${currentData.soilMoisture.toStringAsFixed(1)} %',
                icon: Icons.grass,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoCard(
                title: 'Température',
                value: '${currentData.temperature.toStringAsFixed(1)} °C',
                icon: Icons.thermostat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: 'Débit',
                value: '${currentData.flowRateLMin.toStringAsFixed(2)} L/min',
                icon: Icons.speed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoCard(
                title: 'Volume conseillé',
                value: '${currentData.recommendedVolumeMl.toStringAsFixed(0)} ml',
                icon: Icons.water_drop,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InfoCard(
          title: 'Volume arrosé',
          value: '${currentData.wateredVolumeMl.toStringAsFixed(0)} ml',
          icon: Icons.opacity,
        ),
        const SizedBox(height: 24),

        const Text(
          'Derniers événements',
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
                    item.decision,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Humidité: ${item.soilMoisture.toStringAsFixed(1)}% | Temp: ${item.temperature.toStringAsFixed(1)}°C',
                  ),
                  Text(
                    'Volume conseillé: ${item.recommendedVolumeMl.toStringAsFixed(0)} ml',
                  ),
                  Text(
                    'Vanne: ${item.valveState} | Statut: ${item.status}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reçu à ${formatTime(item.timestamp)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
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
        title: const Text(
          'HydroSense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: pages[selectedIndex],
      ),
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