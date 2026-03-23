import 'dart:math';
import '../models/irrigation_history_item.dart';

class MockData {
  static List<IrrigationHistoryItem> generateHistory() {
    final random = Random();
    List<IrrigationHistoryItem> data = [];

    double moisture = 70;

    for (int i = 0; i < 50; i++) {
      // simulation baisse humidité
      moisture -= random.nextDouble() * 2;

      // simulation arrosage
      if (moisture < 40) {
        moisture += 20;
      }

      final flow = moisture < 45 ? random.nextDouble() * 1.5 : 0.0;

      data.add(
        IrrigationHistoryItem.fromData(
          id: i,
          timestamp: DateTime.now().subtract(Duration(minutes: 50 - i)),
          moisture: moisture.clamp(20, 100),
          flow: flow,
          valveState: flow > 0 ? 1 : 0,
          aiDecision: moisture < 45 ? 1 : 0,
          waterQuantity: flow > 0 ? random.nextDouble() * 2 : 0,
        ),
      );
    }

    return data;
  }
}