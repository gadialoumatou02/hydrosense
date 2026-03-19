class IrrigationData {
  final double soilMoisture;
  final double temperature;
  final double flowRateLMin;
  final double wateredVolumeMl;
  final double recommendedVolumeMl;
  final String decision;
  final String valveState;
  final String status;
  final String message;
  final DateTime timestamp;

  const IrrigationData({
    required this.soilMoisture,
    required this.temperature,
    required this.flowRateLMin,
    required this.wateredVolumeMl,
    required this.recommendedVolumeMl,
    required this.decision,
    required this.valveState,
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory IrrigationData.fromJson(Map<String, dynamic> json) {
    return IrrigationData(
      soilMoisture: (json['soil_moisture'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      flowRateLMin: (json['flow_rate_l_min'] ?? 0).toDouble(),
      wateredVolumeMl: (json['watered_volume_ml'] ?? 0).toDouble(),
      recommendedVolumeMl: (json['recommended_volume_ml'] ?? 0).toDouble(),
      decision: json['decision'] ?? 'INCONNU',
      valveState: json['valve_state'] ?? 'CLOSED',
      status: json['status'] ?? 'IDLE',
      message: json['message'] ?? 'Aucun message',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  factory IrrigationData.empty() {
    return IrrigationData(
      soilMoisture: 0,
      temperature: 0,
      flowRateLMin: 0,
      wateredVolumeMl: 0,
      recommendedVolumeMl: 0,
      decision: 'INCONNU',
      valveState: 'CLOSED',
      status: 'IDLE',
      message: 'En attente des données...',
      timestamp: DateTime.now(),
    );
  }
}