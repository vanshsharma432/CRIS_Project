import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/tokens.dart';
import '../constants/strings.dart';

class MRApiService {
  static const String _baseUrl = 'http://10.64.24.46:8080/quota-backend';

  /// Fetch single EQ Request by Request No
  static Future<Map<String, dynamic>?> fetchEQRequest(
      String eqRequestNo) async {
    final url = Uri.parse(
        '$_baseUrl/auth/mr/getEQRequest?eqRequestNo=$eqRequestNo');

    try {
      final token = await TokenStorage.getToken();
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
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
      final token = await TokenStorage.getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
      final token = await TokenStorage.getToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
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
      final token = await TokenStorage.getToken();
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
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

class AuthService {
  /// Fetches captcha image and UUID from the backend.
  static Future<Map<String, dynamic>> fetchCaptcha() async {
    final response = await http.get(Uri.parse(AppConstants.captchaEndpoint));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final captchaImage = base64Decode(json['data']['captchaImage']);
      final uuid = json['data']['uuid'];
      return {
        'captchaImage': captchaImage,
        'uuid': uuid,
      };
    } else {
      throw Exception("Failed to load captcha");
    }
  }

  /// Requests an OTP for the given mobile number and captcha.
  static Future<String> requestOtp({
    required String username,
    required String uuid,
    required String captcha,
  }) async {
    final body = {
      "username": username,
      "uuid": uuid,
      "captcha": captcha,
    };
    final response = await http.post(
      Uri.parse(AppConstants.otpEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return json['message'] ?? 'OTP response received';
    } else {
      throw Exception(json['message'] ?? "Failed to fetch OTP");
    }
  }

  /// Validates the OTP and captcha, returns accessToken on success.
  static Future<Map<String, dynamic>> validateOtp({
   required String username,
  required String otp,
  required String uuid,
  required String captcha,
}) async {
  final body = {
    "username": username,
    "otp": otp,
    "uuid": uuid,
    "captcha": captcha,
  };
  final response = await http.post(
    Uri.parse(AppConstants.otpValidateEndpoint),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );
  final json = jsonDecode(response.body);
  if (response.statusCode == 200 && json['success'] == true) {
    return json; // Return the full response so you can access token and lists
  } else {
    throw Exception(json['message'] ?? "Login failed");
  }
}
}

class QuotaService {
  /// Fetches PNR status (returns data or throws with message).
  static Future<Map<String, dynamic>?> fetchPNRStatus({
    required String accessToken,
    required String pnrNumber,
  }) async {
    final uri = Uri.parse(AppConstants.pnrEnquiryEndpoint)
        .replace(queryParameters: {'pnr': pnrNumber});
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'PNR Not Found');
      }
    } else {
      throw Exception(data['message'] ?? 'PNR Not Found');
    }
  }

  /// Submits a quota request for the given PNR and passenger details.
  static Future<String> submitQuotaRequest({
    required String accessToken,
    required String pnr,
    required int? priority,
    required List<Map<String, dynamic>> passengerList,
    String remarks = "Need reservation",
  }) async {
    final body = {
      "pnr": pnr,
      "priority": priority,
      "remarks": remarks,
      "passengerList": passengerList,
    };
    final response = await http.post(
      Uri.parse(AppConstants.saveEqRequestEndpoint),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['message'] ?? 'Quota request submitted successfully!';
    } else {
      throw Exception(data['message'] ?? 'Failed to submit quota request.');
    }
  }
}
