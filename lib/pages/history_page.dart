import 'package:flutter/material.dart';
import '../models/irrigation_history_item.dart';
import '../widgets/moisture_chart.dart';
import '../widgets/flow_chart.dart';

class HistoryPage extends StatelessWidget {
  final List<IrrigationHistoryItem> history;

  const HistoryPage({
    super.key,
    required this.history,
  });

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
                Icon(Icons.history, size: 46, color: Colors.blueGrey),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Évolution de l’humidité',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          'Historique détaillé',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Heure')),
              ],
              rows: history.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.id.toString())),
                    DataCell(Text('${item.moisture.toStringAsFixed(1)} %')),
                    DataCell(Text('${item.flow.toStringAsFixed(3)} L/min')),
                    DataCell(Text(item.valveLabel)),
                    DataCell(Text('${item.waterQuantity.toStringAsFixed(2)} L')),
                    DataCell(Text(formatDate(item.timestamp))),
                    DataCell(Text(formatTime(item.timestamp))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}