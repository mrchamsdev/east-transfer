import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/gold_api_constants.dart';
import '../../../core/network/gold_dio_client.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  /// Fetch all expense categories
  /// GET /api/expenseCategory
  Future<List<ExpenseCategory>> getCategories() async {
    try {
      final url = GoldApiConstants.expenseCategory;
      if (kDebugMode) debugPrint('🌐 GET CATEGORIES: $url');
      
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ExpenseCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET CATEGORIES ERROR: $e');
      rethrow;
    }
  }

  /// Create a new category
  /// POST /api/expenseCategory
  Future<bool> createCategory(ExpenseCategory category, {String? filePath}) async {
    try {
      final url = GoldApiConstants.expenseCategory;
      // Always send multipart/form-data to ensure server parses body correctly
      dynamic payload = FormData.fromMap({
        'name': category.name,
        'type': category.type ?? 'Personal',
        if (filePath != null) 'icon': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });

      if (kDebugMode) {
        debugPrint('🌐 CREATE CATEGORY: $url');
        debugPrint('📦 PAYLOAD: ${filePath != null ? 'FormData (with file)' : payload}');
      }

      final response = await _dio.post(url, data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ CREATE CATEGORY ERROR: $e');
      return false;
    }
  }

  /// Update an existing category
  /// PUT /api/expenseCategory/:id
  Future<bool> updateCategory(int id, ExpenseCategory category, {String? filePath}) async {
    try {
      final url = GoldApiConstants.expenseCategoryById(id.toString());
      dynamic payload = FormData.fromMap({
        'name': category.name,
        if (filePath != null) 'icon': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });

      if (kDebugMode) {
        debugPrint('🌐 UPDATE CATEGORY: $url');
        debugPrint('📦 PAYLOAD: ${filePath != null ? 'FormData (with file)' : payload}');
      }

      final response = await _dio.put(url, data: payload);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE CATEGORY ERROR: $e');
      return false;
    }
  }

  /// Soft delete a category
  /// DELETE /api/expenseCategory/:id
  Future<bool> deleteCategory(int id) async {
    try {
      final url = GoldApiConstants.expenseCategoryById(id.toString());
      if (kDebugMode) debugPrint('🌐 DELETE CATEGORY: $url');

      final response = await _dio.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ DELETE CATEGORY ERROR: $e');
      return false;
    }
  }
}
