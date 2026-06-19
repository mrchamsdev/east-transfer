import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../../../core/network/gold_dio_client.dart';

class ExpenseRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  /// Fetch all expenses grouped by month
  /// GET /api/expense/all
  Future<List<ExpenseMonthGroup>> getAllExpenses() async {
    try {
      const url = '/expense/all';
      if (kDebugMode) debugPrint('🌐 GET ALL EXPENSES: $url');
      final response = await _dio.get(url);
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List data = response.data['data'] ?? [];
        return data.map((json) => ExpenseMonthGroup.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET ALL EXPENSES ERROR: $e');
      rethrow;
    }
  }

  /// Fetch a single expense by ID
  /// GET /api/expense/:id
  Future<Expense?> getExpenseById(int id) async {
    try {
      final url = '/expense/$id';
      if (kDebugMode) debugPrint('🌐 GET EXPENSE BY ID: $url');
      final response = await _dio.get(url);
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final expense = Expense.fromJson(response.data['data']);
        _cleanHistory(expense);
        return expense;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET EXPENSE BY ID ERROR: $e');
      rethrow;
    }
  }

  /// Create a new expense record
  /// POST /api/expense
  Future<Expense?> createExpense({
    required int expenseCategoryId,
    required int companyId,
    required String expenseDate,
    required double amount,
    required String amountType,
    required String description,
    String? comment,
    String? note,
  }) async {
    try {
      const url = '/expense';
      final payload = {
        'expenseCategoryId': expenseCategoryId,
        'companyId': companyId,
        'expenseDate': expenseDate,
        'amount': amount,
        'amountType': amountType,
        'description': description,
        if (comment != null) 'comment': comment,
        if (note != null) 'note': note,
      };
      
      if (kDebugMode) {
        debugPrint('🌐 CREATE EXPENSE: $url');
        debugPrint('📦 PAYLOAD: $payload');
      }

      final response = await _dio.post(url, data: payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['status'] == 'success' && response.data['data'] != null) {
          return Expense.fromJson(response.data['data']);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ CREATE EXPENSE ERROR: $e');
      rethrow;
    }
  }

  /// Update an existing expense record
  /// PUT /api/expense/update/:id
  Future<Expense?> updateExpense(
    int id, {
    required int expenseCategoryId,
    required int companyId,
    required String expenseDate,
    required double amount,
    required String amountType,
    required String description,
    String? comment,
    String? note,
    String? file,
  }) async {
    try {
      final url = '/expense/update/$id';
      final payload = {
        'expenseCategoryId': expenseCategoryId,
        'companyId': companyId,
        'expenseDate': expenseDate,
        'amount': amount,
        'amountType': amountType,
        'description': description,
        if (comment != null) 'comment': comment,
        if (note != null) 'note': note,
        'file': file,
      };

      if (kDebugMode) {
        debugPrint('🌐 UPDATE EXPENSE: $url');
        debugPrint('📦 PAYLOAD: $payload');
      }

      final response = await _dio.put(url, data: payload);
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success' && response.data['data'] != null) {
          return Expense.fromJson(response.data['data']);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE EXPENSE ERROR: $e');
      rethrow;
    }
  }

  /// Upload receipt file for an expense (form data)
  /// PUT /api/expense/update/:id
  Future<bool> uploadExpenseFile(int id, String filePath) async {
    try {
      final url = '/expense/update/$id';
      final fileName = filePath.split('/').last;
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      if (kDebugMode) {
        debugPrint('🌐 UPLOAD EXPENSE FILE: $url');
        debugPrint('📁 FILE PATH: $filePath');
      }

      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ UPLOAD EXPENSE FILE ERROR: $e');
      return false;
    }
  }

  /// Fetch all soft-deleted/trash expenses
  /// GET /api/expense/deleted/all
  Future<List<ExpenseMonthGroup>> getTrashExpenses() async {
    try {
      const url = '/expense/deleted/all';
      if (kDebugMode) debugPrint('🌐 GET TRASH EXPENSES: $url');
      final response = await _dio.get(url);
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List data = response.data['data'] ?? [];
        return data.map((json) => ExpenseMonthGroup.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET TRASH EXPENSES ERROR: $e');
      rethrow;
    }
  }

  /// Remove/delete an expense record permanently or soft delete
  /// DELETE /api/expense/delete/:id
  Future<bool> deleteExpense(int id) async {
    try {
      final url = '/expense/delete/$id';
      if (kDebugMode) debugPrint('🌐 DELETE EXPENSE: $url');
      final response = await _dio.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ DELETE EXPENSE ERROR: $e');
      return false;
    }
  }

  /// Restore a deleted expense record
  /// PUT /api/expense/restore/:id
  Future<bool> restoreExpense(int id) async {
    try {
      final url = '/expense/restore/$id';
      if (kDebugMode) debugPrint('🌐 RESTORE EXPENSE: $url');
      final response = await _dio.put(url);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ RESTORE EXPENSE ERROR: $e');
      return false;
    }
  }
  // Clean history data anomalies, especially for amount field
  void _cleanHistory(Expense expense) {
    if (expense.history == null) return;
    for (var item in expense.history!) {
      final changes = item.changes;
      if (changes == null) continue;
      changes.forEach((field, detail) {
        if (field == 'amount') {
          // Ensure old and new values are formatted as numbers with two decimals
          String? format(String? val) {
            if (val == null) return null;
            final numVal = double.tryParse(val.replaceAll(',', ''));
            if (numVal != null) {
              return numVal.toStringAsFixed(2);
            }
            return val;
          }

          final formattedOld = format(detail.oldValue);
          final formattedNew = format(detail.newValue);
          // Update the map entry with formatted values
          changes[field] = ExpenseHistoryChangeDetail(
            newValue: formattedNew,
            oldValue: formattedOld,
          );
        }
      });
    }
  }
}

