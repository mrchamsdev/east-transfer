import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/gold_dio_client.dart';
import '../models/dashboard_data.dart';

class DashboardRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  Future<DashboardData?> getAdminDashboard() async {
    try {
      const url = '/users/adminDashboard';
      if (kDebugMode) debugPrint('🌐 GET ADMIN DASHBOARD: $url');

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          return DashboardData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET ADMIN DASHBOARD ERROR: $e');
      rethrow;
    }
  }
}
