class IrrigationData {
  final DateTime timestamp;
  final double moisture;
  final double flow;
  final int valveState;
  final int aiDecision;
  final double waterQuantity;

  const IrrigationData({
    required this.timestamp,
    required this.moisture,
    required this.flow,
    required this.valveState,
    required this.aiDecision,
    required this.waterQuantity,
  });

  factory IrrigationData.fromJson(Map<String, dynamic> json) {
    return IrrigationData(
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

  factory IrrigationData.empty() {
    return IrrigationData(
      timestamp: DateTime.now(),
      moisture: 0,
      flow: 0,
      valveState: 0,
      aiDecision: 0,
      waterQuantity: 0,
    );
  }

  String get valveLabel => valveState == 1 ? 'Ouverte' : 'Fermée';

  String get decisionLabel => aiDecision == 1 ? 'Arroser' : 'Ne pas arroser';

  String get statusMessage =>
      aiDecision == 1 ? 'Arrosage recommandé ou en cours' : 'Aucun arrosage nécessaire';
}