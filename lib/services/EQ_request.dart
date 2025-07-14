// lib/services/mr_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/tokens.dart';

class MRApiService {
  static const String _baseUrl = 'http://10.64.24.46:8080/quota-backend';



  static Future<Map<String, dynamic>?> fetchEQRequest(String eqRequestNo) async {
    final url = Uri.parse('$_baseUrl/auth/mr/getEQRequest?eqRequestNo=$eqRequestNo');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        } else {
          print("API Error: ${jsonResponse['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during API call: $e");
    }

    return null;
  }

    static Future<bool> updatePriority({
    required String eqRequestNo,
    required int priority,
    required String remarks,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/mr/takeAction');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': editToken,
        },
        body: jsonEncode([
          {
            "eqRequestNo": eqRequestNo,
            "priority": priority,
            "remarks": remarks,
          }
        ]),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update priority: $e');
    }
  }
}

