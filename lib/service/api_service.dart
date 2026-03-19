import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/irrigation_data.dart';

class ApiService {
  // Remplace cette URL par l'adresse donnée par ton binôme
  static const String baseUrl = 'http://192.168.1.100:5000';
  static const String latestEndpoint = '/api/latest';

  static Future<IrrigationData> fetchLatestData() async {
    final uri = Uri.parse('$baseUrl$latestEndpoint');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return IrrigationData.fromJson(decoded);
    } else {
      throw Exception(
        'Erreur API: ${response.statusCode} - ${response.body}',
      );
    }
  }
}