import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'gold_dio_client.dart';

/// Gold-module network service using [GoldDioClient].
///
/// Every method returns `[statusCode, responseBody]`.
/// Full request/response logging is handled by [GoldDioClient]'s interceptor.
///
/// Service classes:
///   [GoldGetService]      – authenticated GET
///   [GoldPostService]     – unauthenticated POST  (login, register, OTP, etc.)
///   [GoldPostAuthService] – authenticated POST
///   [GoldPutService]      – unauthenticated PUT
///   [GoldPutAuthService]  – authenticated PUT
///   [GoldDeleteService]   – authenticated DELETE
///   [GoldPatchService]    – authenticated PATCH
///   [GoldUploadService]   – authenticated multipart file upload

// ── Shared Dio instance ───────────────────────────────────────────────────────

Dio get _dio => GoldDioClient.instance.dio;

// ── Error builder ─────────────────────────────────────────────────────────────

/// Extracts statusCode + body from a [DioException].
/// The interceptor already prints the error block; here we just return data.
List<dynamic> _buildError(DioException e, String tag) {
  final code = e.response?.statusCode ?? 500;
  final body = e.response?.data;
  if (kDebugMode) {
    debugPrint('[$tag] ❌ DioException $code: ${e.message}');
  }
  return [code, body];
}

// ── GET (authenticated) ───────────────────────────────────────────────────────

/// Authenticated GET request.
class GoldGetService {
  final String url;
  final Map<String, dynamic>? queryParams;

  const GoldGetService(this.url, {this.queryParams});

  Future<List<dynamic>> data() async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
      );
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'GET');
    } catch (e) {
      debugPrint('[GET] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}

// ── POST (no auth) ────────────────────────────────────────────────────────────

/// Unauthenticated POST — used for login, register, OTP flows.
/// The Authorization header is explicitly removed so the interceptor
/// does not inject a stale token.
class GoldPostService {
  final String url;
  final Map<String, dynamic> body;

  const GoldPostService(this.url, this.body);

  Future<List<dynamic>> data() async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: {'Authorization': null}, // strip token for public endpoints
          validateStatus: (status) => status != null,
        ),
      );
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'POST');
    } catch (e) {
      debugPrint('[POST] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}

// ── POST (authenticated) ──────────────────────────────────────────────────────

/// Authenticated POST request.
class GoldPostAuthService {
  final String url;
  final Map<String, dynamic> body;

  const GoldPostAuthService(this.url, this.body);

  Future<List<dynamic>> data() async {
    try {
      final response = await _dio.post(url, data: body);
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'POST(auth)');
    } catch (e) {
      debugPrint('[POST(auth)] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}

// ── PUT (no auth) ─────────────────────────────────────────────────────────────

/// Unauthenticated PUT — used for setPassword (called right after sign-up).
class GoldPutService {
  final String url;
  final Map<String, dynamic> body;

  const GoldPutService(this.url, this.body);

  Future<List<dynamic>> data() async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        options: Options(
          headers: {'Authorization': null},
          validateStatus: (status) => status != null,
        ),
      );
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'PUT');
    } catch (e) {
      debugPrint('[PUT] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}

// ── PUT (authenticated) ───────────────────────────────────────────────────────

/// Authenticated PUT request (full update).
class GoldPutAuthService {
  final String url;
  final Map<String, dynamic> body;

  const GoldPutAuthService(this.url, this.body);

  Future<List<dynamic>> data() async {
    try {
      final response = await _dio.put(url, data: body);
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'PUT(auth)');
    } catch (e) {
      debugPrint('[PUT(auth)] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}

// ── DELETE (authenticated) ────────────────────────────────────────────────────

/// Authenticated DELETE with optional body.
class GoldDeleteService {
  final String url;
  final Map<String, dynamic>? body;

  const GoldDeleteService(this.url, {this.body});

  Future<List<dynamic>> data() async {
    try {
      final response = await _dio.delete(url, data: body);
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'DELETE');
    } catch (e) {
      debugPrint('[DELETE] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}

// ── PATCH (authenticated) ─────────────────────────────────────────────────────

/// Authenticated PATCH request (partial update).
class GoldPatchService {
  final String url;
  final Map<String, dynamic> body;

  const GoldPatchService(this.url, this.body);

  Future<List<dynamic>> data() async {
    try {
      final response = await _dio.patch(url, data: body);
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'PATCH');
    } catch (e) {
      debugPrint('[PATCH] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}

// ── Multipart file upload (authenticated) ─────────────────────────────────────

/// Authenticated multipart POST for file uploads.
///
/// Example:
/// ```dart
/// final svc = GoldUploadService(
///   url: GoldApiConstants.goldList,
///   fields: {'title': 'Receipt'},
///   filePath: '/data/.../image.jpg',
///   fileFieldName: 'image',
/// );
/// final res = await svc.data();
/// ```
class GoldUploadService {
  final String url;
  final Map<String, dynamic> fields;
  final String filePath;
  final String fileFieldName;

  const GoldUploadService({
    required this.url,
    this.fields = const {},
    required this.filePath,
    this.fileFieldName = 'file',
  });

  Future<List<dynamic>> data() async {
    try {
      final formData = FormData.fromMap({
        ...fields,
        fileFieldName: await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(url, data: formData);
      return [response.statusCode ?? 200, response.data];
    } on DioException catch (e) {
      return _buildError(e, 'UPLOAD');
    } catch (e) {
      debugPrint('[UPLOAD] ❌ Unexpected error: $e');
      return [500, null];
    }
  }
}
