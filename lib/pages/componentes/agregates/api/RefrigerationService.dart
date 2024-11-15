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

  static Future<Refrigeration> createRefrigeration(Refrigeration refrigeration) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(refrigeration.toJson()),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return Refrigeration.fromJson(jsonData);
      } else {
        throw Exception('Failed to create refrigeration: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating refrigeration: $e');
    }
  }


  static Future<void> deleteRefrigerationById5() async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/5'), // URL del equipo con id 5
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete refrigeration with id 5');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }



}