import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bank_scan/Gold/core/network/gold_api_constants.dart';

class FaceAuthResponse {
  final bool isSuccess;
  final String? message;
  final Map<String, dynamic>? data;

  FaceAuthResponse({required this.isSuccess, this.message, this.data});

  factory FaceAuthResponse.success(Map<String, dynamic> data) {
    return FaceAuthResponse(isSuccess: true, data: data);
  }

  factory FaceAuthResponse.error(String message) {
    return FaceAuthResponse(isSuccess: false, message: message);
  }
}

class FaceAuthRepository {
  static final FaceAuthRepository instance = FaceAuthRepository._internal();
  FaceAuthRepository._internal();

  String _extractError(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return (decoded['message'] ?? decoded['error'] ?? fallback).toString();
      }
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }

  Future<FaceAuthResponse> enableFace(String token, String biometricDeviceId) async {
    try {
      final url = '${GoldApiConstants.baseUrl}/users/enableFace';
      final payload = {
        'biometricDeviceId': biometricDeviceId,
      };

      debugPrint('--- API CALL: enableFace ---');
      debugPrint('URL: $url');
      debugPrint('Headers: Authorization: Bearer $token, device-id: $biometricDeviceId');
      debugPrint('Payload: ${jsonEncode(payload)}');
      debugPrint('----------------------------');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'device-id': biometricDeviceId,
        },
        body: jsonEncode(payload),
      );

      debugPrint('--- API RESPONSE: enableFace ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('--------------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return FaceAuthResponse.success(decoded);
      } else {
        return FaceAuthResponse.error(_extractError(response, 'Failed to enable Face ID'));
      }
    } catch (e) {
      return FaceAuthResponse.error('Network error while enabling Face ID');
    }
  }

  Future<FaceAuthResponse> faceLogin(String email, String biometricDeviceId) async {
    try {
      final url = '${GoldApiConstants.baseUrl}/users/faceLogin';
      final payload = {
        'email': email,
        'biometricDeviceId': biometricDeviceId,
      };

      debugPrint('--- API CALL: faceLogin ---');
      debugPrint('URL: $url');
      debugPrint('Headers: device-id: $biometricDeviceId');
      debugPrint('Payload: ${jsonEncode(payload)}');
      debugPrint('---------------------------');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'device-id': biometricDeviceId,
        },
        body: jsonEncode(payload),
      );

      debugPrint('--- API RESPONSE: faceLogin ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('-------------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return FaceAuthResponse.success(decoded);
      } else {
        return FaceAuthResponse.error(_extractError(response, 'Face Login failed'));
      }
    } catch (e) {
      return FaceAuthResponse.error('Network error during Face Login');
    }
  }
}
