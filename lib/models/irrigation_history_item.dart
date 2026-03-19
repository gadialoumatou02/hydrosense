class IrrigationHistoryItem {
  final double soilMoisture;
  final double temperature;
  final double recommendedVolumeMl;
  final double wateredVolumeMl;
  final String decision;
  final String valveState;
  final String status;
  final DateTime timestamp;

  const IrrigationHistoryItem({
    required this.soilMoisture,
    required this.temperature,
    required this.recommendedVolumeMl,
    required this.wateredVolumeMl,
    required this.decision,
    required this.valveState,
    required this.status,
    required this.timestamp,
  });

  factory IrrigationHistoryItem.fromJson(Map<String, dynamic> json) {
    return IrrigationHistoryItem(
      soilMoisture: (json['soil_moisture'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      recommendedVolumeMl: (json['recommended_volume_ml'] ?? 0).toDouble(),
      wateredVolumeMl: (json['watered_volume_ml'] ?? 0).toDouble(),
      decision: json['decision'] ?? 'INCONNU',
      valveState: json['valve_state'] ?? 'CLOSED',
      status: json['status'] ?? 'IDLE',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}