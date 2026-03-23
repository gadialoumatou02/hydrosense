class IrrigationHistoryItem {
  final int id;
  final DateTime timestamp;
  final double moisture;
  final double flow;
  final int valveState;
  final int aiDecision;
  final double waterQuantity;

  const IrrigationHistoryItem({
    required this.id,
    required this.timestamp,
    required this.moisture,
    required this.flow,
    required this.valveState,
    required this.aiDecision,
    required this.waterQuantity,
  });

  factory IrrigationHistoryItem.fromJson(Map<String, dynamic> json) {
    return IrrigationHistoryItem(
      id: json['id'] ?? 0,
      timestamp: DateTime.tryParse(
        (json['timestamp'] ?? '').toString().replaceFirst(' ', 'T'),
      ) ??
          DateTime.now(),
      moisture: (json['moisture'] ?? 0).toDouble(),
      flow: (json['flow'] ?? 0).toDouble(),
      valveState: json['valve_state'] ?? 0,
      aiDecision: json['ai_decision'] ?? 0,
      waterQuantity: (json['water_quantity'] ?? 0).toDouble(),
    );
  }

  factory IrrigationHistoryItem.fromData({
    required int id,
    required DateTime timestamp,
    required double moisture,
    required double flow,
    required int valveState,
    required int aiDecision,
    required double waterQuantity,
  }) {
    return IrrigationHistoryItem(
      id: id,
      timestamp: timestamp,
      moisture: moisture,
      flow: flow,
      valveState: valveState,
      aiDecision: aiDecision,
      waterQuantity: waterQuantity,
    );
  }

  String get valveLabel => valveState == 1 ? 'Ouverte' : 'Fermée';

  String get decisionLabel => aiDecision == 1 ? 'Arroser' : 'Ne pas arroser';
}