/*import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/gold_dio_client.dart';
import '../models/dashboard_data.dart';

class DashboardRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  /*Future<DashboardData?> getAdminDashboard() async {
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
*/
 Future<DashboardData?> getAdminDashboard({String period = 'Today'}) async {
    try {
      const url = '/users/adminDashboard';
      // NOTE: confirm 'period' is the correct query param name with your backend/API docs.
      final queryParams = {'period': period};
      if (kDebugMode) debugPrint('🌐 GET ADMIN DASHBOARD: $url?period=$period');

      final response = await _dio.get(url, queryParameters: queryParams);
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

*/
/*
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/network/gold_dio_client.dart';
import '../models/dashboard_data.dart';

class DashboardRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  Future<DashboardData?> getAdminDashboard({String period = 'Today'}) async {
    try {
      const url = '/users/adminDashboard';
      final queryParams = _buildQueryParams(period);

      if (kDebugMode) {
        debugPrint('🌐 GET ADMIN DASHBOARD: $url params=$queryParams');
      }

      final response = await _dio.get(url, queryParameters: queryParams);
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

  Map<String, dynamic> _buildQueryParams(String period) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    // All Time: unchanged from original behavior — no date range sent.
    if (period == 'All Time') {
      return {};
    }

    DateTime start;
    DateTime end = now;

    switch (period) {
      case 'Today':
        start = now;
        break;
      case 'Yesterday':
        start = now.subtract(const Duration(days: 1));
        end = start;
        break;
      case 'This Week':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'This Month':
        start = _subtractOneMonth(now);
        break;
      default:
        start = now;
    }

    return {
      'month': dateFormat.format(now),
      'startDate': dateFormat.format(start),
      'endDate': dateFormat.format(end),
    };
  }

  /// Subtracts exactly one calendar month from [date].
  /// Clamps the day if the target month has fewer days
  /// (e.g. Mar 31 → Feb 28/29).
  DateTime _subtractOneMonth(DateTime date) {
    int year = date.year;
    int month = date.month - 1;
    if (month == 0) {
      month = 12;
      year -= 1;
    }
    final daysInTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;
    return DateTime(year, month, day);
  }
}
*/
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/network/gold_dio_client.dart';
import '../models/dashboard_data.dart';

class DashboardRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  Future<DashboardData?> getAdminDashboard({String period = 'Today'}) async {
    try {
      const url = '/users/adminDashboard';
      final queryParams = _buildQueryParams(period);

      if (kDebugMode) {
        debugPrint('🌐 GET ADMIN DASHBOARD: $url params=$queryParams');
      }

      final response = await _dio.get(url, queryParameters: queryParams);
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

  Map<String, dynamic> _buildQueryParams(String period) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    if (period == 'All Time') {
      return {};
    }

    DateTime start;
    DateTime end = now;

    switch (period) {
      case 'Today':
        start = now;
        break;
      case 'Yesterday':
        start = now.subtract(const Duration(days: 1));
        end = start;
        break;
      case 'This Week':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'This Month':
        start = _subtractOneMonth(now);
        break;
      default:
        start = now;
    }

    return {
      'startDate': dateFormat.format(start),
      'endDate': dateFormat.format(end),
    };
  }

  /// Subtracts exactly one calendar month from [date].
  /// Clamps the day if the target month has fewer days
  /// (e.g. Mar 31 → Feb 28/29).
  DateTime _subtractOneMonth(DateTime date) {
    int year = date.year;
    int month = date.month - 1;
    if (month == 0) {
      month = 12;
      year -= 1;
    }
    final daysInTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;
    return DateTime(year, month, day);
  }
}