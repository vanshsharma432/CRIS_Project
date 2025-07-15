import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/tokens.dart';

class MRApiService {
  static const String _baseUrl = 'http://10.64.24.46:8080/quota-backend';

  /// Fetch single EQ Request by Request No
  static Future<Map<String, dynamic>?> fetchEQRequest(
      String eqRequestNo) async {
    final url = Uri.parse(
        '$_baseUrl/auth/mr/getEQRequest?eqRequestNo=$eqRequestNo');

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

  /// Change Priority by MR Cell
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

  /// List EQ Requests by Zone User
  static Future<List<Map<String, dynamic>>> fetchZoneRequests({
    required String trainStartDate,
    required String trainNo,
    required String divisionCode,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/auth/zone/getAllSentRequests'
          '?trainStartDate=$trainStartDate'
          '&trainNo=$trainNo'
          '&divisionCode=$divisionCode',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          print("API Error: ${jsonResponse['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in fetchZoneRequests: $e");
    }

    return [];
  }

  /// Fetch Train List for Dropdown
  static Future<List<String>> fetchTrainList() async {
    final url = Uri.parse('$_baseUrl/auth/basic/trains');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List data = jsonResponse['data'];
          return data
              .map<String>((item) => item['trainNo']?.toString() ?? '')
              .where((trainNo) => trainNo.isNotEmpty)
              .toList();
        } else {
          print("API Error: ${jsonResponse['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in fetchTrainList: $e");
    }

    return [];
  }
}
