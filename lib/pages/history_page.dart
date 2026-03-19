import 'package:flutter/material.dart';
import '../models/irrigation_history_item.dart';

class HistoryPage extends StatelessWidget {
  final List<IrrigationHistoryItem> history;

  const HistoryPage({
    super.key,
    required this.history,
  });

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month ${hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history,
                  size: 46,
                  color: Colors.blueGrey,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucun historique disponible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];

        return Container(
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
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text('Humidité du sol : ${item.soilMoisture.toStringAsFixed(1)} %'),
              Text('Température : ${item.temperature.toStringAsFixed(1)} °C'),
              Text(
                'Volume conseillé : ${item.recommendedVolumeMl.toStringAsFixed(0)} ml',
              ),
              Text(
                'Volume arrosé : ${item.wateredVolumeMl.toStringAsFixed(0)} ml',
              ),
              Text('État vanne : ${item.valveState}'),
              Text('Statut : ${item.status}'),
              const SizedBox(height: 6),
              Text(
                formatTime(item.timestamp),
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}