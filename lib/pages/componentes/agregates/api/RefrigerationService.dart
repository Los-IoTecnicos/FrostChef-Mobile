import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Refrigeration.dart';

class RefrigerationService {
  static const String apiUrl = 'https://66f616ba436827ced975e4d6.mockapi.io/api/v1/refrigeration';

  static Future<List<Refrigeration>> getRefrigerationList() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Refrigeration.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load refrigeration data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
