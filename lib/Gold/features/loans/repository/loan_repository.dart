import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/gold_dio_client.dart';
import '../models/loan_models.dart';

class CreatePersonResult {
  final int? personId;
  final String? error;

  CreatePersonResult({this.personId, this.error});
}

class LoanRepository {
  final Dio _dio = GoldDioClient.instance.dio;
  // Stream to broadcast loan records updates
  final StreamController<List<LoanRecord>> _loanRecordsController = StreamController<List<LoanRecord>>.broadcast();

  Stream<List<LoanRecord>> get loanRecordsStream => _loanRecordsController.stream;

  // Helper to refresh and broadcast loan records
  Future<void> _refreshLoanRecords() async {
    try {
      final records = await getRecords();
      _loanRecordsController.add(records);
    } catch (_) {
      // ignore errors during refresh
    }
  }


  // ── Records & Dues ────────────────────────────────────────────────────────
  
  Future<List<LoanRecord>> getRecords() async {
    try {
      const url = '/loan/records';
      if (kDebugMode) debugPrint('🌐 GET LOAN RECORDS: $url');

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => LoanRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET LOAN RECORDS ERROR: $e');
      rethrow;
    }
  }

  Future<List<LoanDue>> getDues() async {
    try {
      const url = '/loan/dues';
      if (kDebugMode) debugPrint('🌐 GET LOAN DUES: $url');

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data['dues'] ?? [];
        return data.map((json) => LoanDue.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET LOAN DUES ERROR: $e');
      rethrow;
    }
  }

  Future<PersonDetails?> getPersonDetails(int id) async {
    try {
      final url = '/loan/personDetails/$id';
      if (kDebugMode) debugPrint('🌐 GET PERSON DETAILS: $url');

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        return PersonDetails.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET PERSON DETAILS ERROR: $e');
      rethrow;
    }
  }



  // ── Create & Update Person ────────────────────────────────────────────────

  Future<CreatePersonResult> createPerson(Map<String, dynamic> data, {String? idProofImagePath, String? witnessIdProofImagePath}) async {
    try {
      const url = '/loan/person';
      final formData = FormData.fromMap(data);
      debugPrint('📦 FormData fields: ${formData.fields}');
      debugPrint('📦 FormData files: ${formData.files.map((e) => e.key).toList()}');
      if (idProofImagePath != null) {
        formData.files.add(MapEntry('idProofImage', await MultipartFile.fromFile(idProofImagePath, filename: idProofImagePath.split('/').last)));
      }
      if (witnessIdProofImagePath != null) {
        formData.files.add(MapEntry('witnessIdProofImage', await MultipartFile.fromFile(witnessIdProofImagePath, filename: witnessIdProofImagePath.split('/').last)));
      }

      if (kDebugMode) debugPrint('🌐 CREATE PERSON: $url');
      final response = await _dio.post(url, data: formData);
      
      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return CreatePersonResult(error: resData['message']?.toString() ?? 'Failed to create person');
        }
        if (resData['status'] == 'success' && resData['data'] != null) {
          final createdId = resData['data']['id'];
          if (createdId != null) {
            return CreatePersonResult(personId: int.tryParse(createdId.toString()));
          }
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) return CreatePersonResult();
      return CreatePersonResult(error: 'Failed to create person');
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ CREATE PERSON ERROR: ${e.response?.data}');
      if (e.response?.data is Map) return CreatePersonResult(error: e.response?.data['message'] ?? 'Failed to create person');
      return CreatePersonResult(error: e.message);
    } catch (e) {
      return CreatePersonResult(error: e.toString());
    }
  }

  Future<String?> updatePerson(int id, Map<String, dynamic> data, {String? idProofImagePath, String? witnessIdProofImagePath}) async {
    try {
      final url = '/loan/person/update/$id';
      final formData = FormData.fromMap(data);
      if (idProofImagePath != null) {
        formData.files.add(MapEntry('idProofImage', await MultipartFile.fromFile(idProofImagePath, filename: idProofImagePath.split('/').last)));
      }
      if (witnessIdProofImagePath != null) {
        formData.files.add(MapEntry('witnessIdProofImage', await MultipartFile.fromFile(witnessIdProofImagePath, filename: witnessIdProofImagePath.split('/').last)));
      }

      if (kDebugMode) debugPrint('🌐 UPDATE PERSON: $url');
      final response = await _dio.put(url, data: formData);

      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return resData['message']?.toString() ?? 'Failed to update person';
        }
      }

      if (response.statusCode == 200) return null;
      return 'Failed to update person';
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE PERSON ERROR: ${e.response?.data}');
      if (e.response?.data is Map) return e.response?.data['message'] ?? 'Failed to update person';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Create & Update Loan ──────────────────────────────────────────────────

  Future<String?> createLoan(Map<String, dynamic> data, {String? agreementImagePath}) async {
    try {
      const url = '/loan/loan';
      final formData = FormData.fromMap(data);
      debugPrint('📦 FormData fields: ${formData.fields}');
      debugPrint('📦 FormData files: ${formData.files.map((e) => e.key).toList()}');
      if (agreementImagePath != null) {
        formData.files.add(MapEntry('agreementImage', await MultipartFile.fromFile(agreementImagePath, filename: agreementImagePath.split('/').last)));
      }

      if (kDebugMode) debugPrint('🌐 CREATE LOAN: $url');
      final response = await _dio.post(url, data: formData);

      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return resData['message']?.toString() ?? 'Failed to create loan';
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // After successful creation, refresh UI data
        await _refreshLoanRecords();
        return null;
      }
      return 'Failed to create loan';
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ CREATE LOAN ERROR: ${e.response?.data}');
      if (e.response?.data is Map) return e.response?.data['message'] ?? 'Failed to create loan';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateLoan(int id, Map<String, dynamic> data, {String? agreementImagePath}) async {
    try {
      final url = '/loan/loan/update/$id';
      final formData = FormData.fromMap(data);
      if (agreementImagePath != null) {
        formData.files.add(MapEntry('agreementImage', await MultipartFile.fromFile(agreementImagePath, filename: agreementImagePath.split('/').last)));
      }

      if (kDebugMode) debugPrint('🌐 UPDATE LOAN: $url');
      final response = await _dio.put(url, data: formData);

      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return resData['message']?.toString() ?? 'Failed to update loan';
        }
      }

      if (response.statusCode == 200) {
        // After successful update, refresh UI data
        await _refreshLoanRecords();
        return null;
      }
      return 'Failed to update loan';
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE LOAN ERROR: ${e.response?.data}');
      if (e.response?.data is Map) return e.response?.data['message'] ?? 'Failed to update loan';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Create & Update Payment ───────────────────────────────────────────────

  Future<String?> createPaymentUpdate(Map<String, dynamic> data, {String? filePath}) async {
    try {
      const url = '/loan/paymentUpdate';
      final formData = FormData.fromMap(data);
      if (filePath != null) {
        formData.files.add(MapEntry('file', await MultipartFile.fromFile(filePath, filename: filePath.split('/').last)));
      }

      if (kDebugMode) debugPrint('🌐 CREATE PAYMENT UPDATE: $url');
      final response = await _dio.post(url, data: formData);

      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return resData['message']?.toString() ?? 'Failed to create payment update';
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) return null;
      return 'Failed to create payment update';
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ CREATE PAYMENT UPDATE ERROR: ${e.response?.data}');
      if (e.response?.data is Map) return e.response?.data['message'] ?? 'Failed to create payment update';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> editPaymentUpdate(int id, Map<String, dynamic> data, {String? filePath}) async {
    try {
      final url = '/loan/paymentUpdate/update/$id';
      final formData = FormData.fromMap(data);
      if (filePath != null) {
        formData.files.add(MapEntry('file', await MultipartFile.fromFile(filePath, filename: filePath.split('/').last)));
      }

      if (kDebugMode) debugPrint('🌐 UPDATE PAYMENT UPDATE: $url');
      final response = await _dio.put(url, data: formData);

      if (response.data != null && response.data is Map) {
        final resData = response.data;
        if (resData['status'] == 'error') {
           return resData['message']?.toString() ?? 'Failed to update payment update';
        }
      }

      if (response.statusCode == 200) return null;
      return 'Failed to update payment update';
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ UPDATE PAYMENT UPDATE ERROR: ${e.response?.data}');
      if (e.response?.data is Map) return e.response?.data['message'] ?? 'Failed to update payment update';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> deletePerson(int id) async {
    try {
      final url = '/loan/person/delete/$id';
      if (kDebugMode) debugPrint('🌐 DELETE PERSON: $url');
      final response = await _dio.delete(url);
      if (response.statusCode == 200) return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ DELETE PERSON FIRST TRY ERROR: $e');
    }

    try {
      final url = '/loan/delete/$id';
      if (kDebugMode) debugPrint('🌐 DELETE PERSON FALLBACK: $url');
      final response = await _dio.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ DELETE PERSON FALLBACK ERROR: $e');
      return false;
    }
  }
  Future<Loan?> getLoanById(int loanId) async {
    try {
      final url = '/loan/loan/$loanId';
      if (kDebugMode) debugPrint('🌐 GET LOAN BY ID: $url');

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          return Loan.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ GET LOAN BY ID ERROR: $e');
      rethrow;
    }
  }
}