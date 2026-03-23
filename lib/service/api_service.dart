import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/irrigation_data.dart';
import '../models/irrigation_history_item.dart';

class ApiService {
  static const String baseUrl = 'https://unobscured-ashley-unemerged.ngrok-free.dev';

  static Future<IrrigationData> fetchLatestData() async {
    final uri = Uri.parse('$baseUrl/api/latest');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur latest: ${response.statusCode} - ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return IrrigationData.fromJson(decoded);
  }

  static Future<List<IrrigationHistoryItem>> fetchHistory() async {
    final uri = Uri.parse('$baseUrl/api/history');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur history: ${response.statusCode} - ${response.body}');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((e) => IrrigationHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}