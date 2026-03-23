import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/irrigation_history_item.dart';

class FlowChart extends StatelessWidget {
  final List<IrrigationHistoryItem> data;

  const FlowChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(height: 220, child: Center(child: Text('Aucune donnée')));
    }

    double maxFlow = data
        .map((e) => e.flow)
        .fold<double>(0, (prev, el) => el > prev ? el : prev);

    if (maxFlow <= 0) {
      maxFlow = 1;
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxFlow * 1.2,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Débit (L/min)'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxFlow > 1 ? maxFlow / 4 : 0.25,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Mesures'),
              sideTitles: SideTitles(
                showTitles: true,
                interval: (data.length / 5).clamp(1, 999).toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final item = data[index];
                  final hour = item.timestamp.hour.toString().padLeft(2, '0');
                  final minute = item.timestamp.minute.toString().padLeft(2, '0');
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('$hour:$minute', style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.flow);
              }).toList(),
              dotData: const FlDotData(show: false),
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}