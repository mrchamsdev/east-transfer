import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/gold_dio_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  Future<List<User>> getAllUsers() async {
    try {
      const url = '/users/all';
      if (kDebugMode) debugPrint('🌐 GET ALL USERS: $url');

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        dynamic responseData = response.data['data'];
        List dataList = [];
        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData['users'] is List) {
          dataList = responseData['users'];
        }
        return dataList.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET ALL USERS ERROR: $e');
      rethrow;
    }
  }

  Future<User?> getUser(int id) async {
    try {
      final url = '/users/user/$id';
      if (kDebugMode) debugPrint('🌐 GET USER: $url');

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        dynamic responseData = response.data['data'];
        dynamic userData;
        if (responseData is Map) {
          userData = responseData['user'] ?? responseData;
        } else {
          userData = responseData;
        }
        
        if (userData != null && userData is Map<String, dynamic>) {
          return User.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET USER ERROR: $e');
      rethrow;
    }
  }

  Future<String?> createUser(User user) async {
    try {
      const url = '/users';
      final payload = user.toJson();
      if (kDebugMode) {
        debugPrint('🌐 CREATE USER: $url');
        debugPrint('📦 PAYLOAD: $payload');
      }

      final response = await _dio.post(url, data: payload);
      
      // If the request didn't fail at the network level, parse the JSON payload
      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return resData['message']?.toString() ?? 'Failed to create user.';
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Success
      }
      return 'Unknown error occurred';
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ CREATE USER ERROR: ${e.response?.data}');
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data is Map) {
          return e.response?.data['message'] ?? 'Failed to create user.';
        }
      }
      return e.message ?? 'Network error occurred.';
    } catch (e) {
      if (kDebugMode) debugPrint('❌ CREATE USER ERROR: $e');
      return e.toString();
    }
  }

  Future<String?> updateUser(int id, User user, {String? filePath}) async {
    try {
      final url = '/users/updateUser/$id';
      dynamic payload;

      if (filePath != null) {
        payload = FormData.fromMap({
          'name': user.name,
          'lastName': user.lastName ?? '',
          'email': user.email ?? '',
          'phoneNumber': user.phoneNumber ?? '',
          'role': user.role ?? '',
          'gender': user.gender ?? '',
          'modules': user.modules.join(','),
          'profile': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
        });
      } else {
        payload = user.toJson();
      }

      if (kDebugMode) {
        debugPrint('🌐 UPDATE USER: $url');
        debugPrint('📦 PAYLOAD: ${filePath != null ? 'FormData (with profile)' : payload}');
      }

      final response = await _dio.put(url, data: payload);
      
      // Parse JSON payload even if status code is 200
      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return resData['message']?.toString() ?? 'Failed to update user.';
        }
      }

      if (response.statusCode == 200) {
        return null; // Success
      }
      return 'Unknown error occurred';
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE USER ERROR: ${e.response?.data}');
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data is Map) {
          return e.response?.data['message'] ?? 'Failed to update user.';
        }
      }
      return e.message ?? 'Network error occurred.';
    } catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE USER ERROR: $e');
      return e.toString();
    }
  }

  Future<bool> updateAccountStatus(int id, {required bool activate}) async {
    try {
      final url = '/users/accountStatus/$id';
      final payload = {
        "status": activate ? "Active" : "deActive",
        "doYouWantToDelete": activate ? "NO" : "Yes",
        "deActivationDate": DateTime.now().toIso8601String(),
      };
      if (kDebugMode) {
        debugPrint('🌐 UPDATE ACCOUNT STATUS: $url');
        debugPrint('📦 PAYLOAD: $payload');
      }

      final response = await _dio.put(url, data: payload);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE ACCOUNT STATUS ERROR: $e');
      return false;
    }
  }
}
