import 'package:dio/dio.dart';
import 'package:bank_scan/Gold/core/network/gold_api_constants.dart';
import 'package:bank_scan/Gold/core/network/gold_dio_client.dart';
import '../models/gold_purchase_model.dart';
import 'package:flutter/foundation.dart';

class GoldRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  /// Fetch all gold purchases grouped by month
  /// GET /api/gold/allGoldPurchases
  Future<List<GoldMonthGroup>> getAllGoldPurchases() async {
    try {
      final response = await _dio.get(GoldApiConstants.allGoldPurchases);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List data = response.data['data'];
        return data.map((json) => GoldMonthGroup.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('[GoldRepository] Error getAllGoldPurchases: $e');
      rethrow;
    }
  }

  /// Fetch single gold purchase by ID
  /// GET /api/gold/goldPurchase/:id
  Future<GoldPurchase?> getGoldPurchaseById(int id) async {
    try {
      final url = GoldApiConstants.goldPurchaseById(id.toString());
      if (kDebugMode) {
        debugPrint('🔍 FETCHING RECORD DETAILS');
        debugPrint('🆔 ID  : $id');
        debugPrint('🌐 API : $url');
      }
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        // Handle wrapper if present (common in this API)
        if (response.data is Map && response.data['status'] == 'success' && response.data['data'] != null) {
          return GoldPurchase.fromJson(response.data['data']);
        }
        // Fallback for direct object
        return GoldPurchase.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('[GoldRepository] Error getGoldPurchaseById: $e');
      rethrow;
    }
  }

  /// Step 1: Create Gold Purchase (Party Details)
  /// POST /api/gold/createGold
  Future<int?> createGold(GoldPurchase purchase) async {
    try {
      final response = await _dio.post(
        GoldApiConstants.createGold,
        data: purchase.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Correctly handle the response.data['data']['id'] structure
        if (response.data['data'] != null && response.data['data']['id'] != null) {
          return response.data['data']['id'];
        }
        return response.data['id'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('[GoldRepository] Error createGold: $e');
      rethrow;
    }
  }

  /// Step 2: Add Items to a Gold Purchase
  /// POST /api/gold/createItems
  Future<bool> createItems(int purchaseId, List<GoldBilledItem> items) async {
    try {
      final response = await _dio.post(
        GoldApiConstants.createItems,
        data: {
          "purchaseId": purchaseId,
          "items": items.map((e) => e.toJson()).toList(),
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('[GoldRepository] Error createItems: $e');
      rethrow;
    }
  }

  /// Update Party details
  /// PUT /api/gold/updateParty/:id
  Future<bool> updateParty(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        GoldApiConstants.updateParty(id.toString()),
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Update Gold purchase details
  /// PUT /api/gold/updateGold/:id
  Future<bool> updateGold(int id, GoldPurchase purchase) async {
    try {
      final response = await _dio.put(
        GoldApiConstants.updateGold(id.toString()),
        data: purchase.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Update Gold purchase details partially
  /// PUT /api/gold/updateGold/:id
  Future<bool> updateGoldPartial(int id, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) print('[GoldRepository] PUT updateGoldPartial ID: $id');
      if (kDebugMode) print('[GoldRepository] Payload: $data');
      final response = await _dio.put(
        GoldApiConstants.updateGold(id.toString()),
        data: data,
      );
      if (kDebugMode) print('[GoldRepository] Response Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('[GoldRepository] Error updateGoldPartial: $e');
      rethrow;
    }
  }

  /// Delete Gold purchase
  /// DELETE /api/gold/gold/:id
  Future<bool> deleteGold(int id) async {
    try {
      final response = await _dio.delete(GoldApiConstants.deleteGold(id.toString()));
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Party
  /// DELETE /api/gold/party/:id
  Future<bool> deleteParty(int id) async {
    try {
      final response = await _dio.delete(GoldApiConstants.deleteParty(id.toString()));
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
