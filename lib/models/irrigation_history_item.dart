class IrrigationHistoryItem {
  final DateTime timestamp;
  final double moisture;
  final double flow;
  final int valveState;
  final int aiDecision;
  final double waterQuantity;

  const IrrigationHistoryItem({
    required this.timestamp,
    required this.moisture,
    required this.flow,
    required this.valveState,
    required this.aiDecision,
    required this.waterQuantity,
  });

  factory IrrigationHistoryItem.fromData({
    required DateTime timestamp,
    required double moisture,
    required double flow,
    required int valveState,
    required int aiDecision,
    required double waterQuantity,
  }) {
    return IrrigationHistoryItem(
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