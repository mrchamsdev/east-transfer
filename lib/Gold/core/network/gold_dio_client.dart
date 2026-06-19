import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gold_api_constants.dart';
import 'gold_session.dart';

/// Global [NavigatorKey] used by [GoldDioClient] to redirect to the
/// Welcome/Login screen when a 401 is received anywhere in the app.
final GlobalKey<NavigatorState> goldNavigatorKey = GlobalKey<NavigatorState>();

/// Singleton Dio client for the Gold module.
///
/// Features:
///  • Attaches Bearer token automatically via interceptor.
///  • Prints clean [URL] [PAYLOAD] [RESPONSE] logs in debug mode.
///  • Converts 401 → logs an expiry warning (extend with refresh if needed).
class GoldDioClient {
  GoldDioClient._();

  static GoldDioClient? _instance;
  static GoldDioClient get instance => _instance ??= GoldDioClient._();

  Dio? _dio;

  /// Returns the configured [Dio] instance (lazy init).
  Dio get dio {
    _dio ??= _buildDio();
    return _dio!;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: GoldApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Custom structured logger ─────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read token from GoldSession (in-memory, instant)
          final token = GoldSession.instance.token
              ?? await _getFallbackToken();
          if (token != null && token.isNotEmpty) {
            if (options.headers['Authorization'] != null ||
                !options.headers.containsKey('Authorization')) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          if (kDebugMode) {
            _logRequest(options);
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _logResponse(response);
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            _logError(e);
          }
          // ── Auto-logout on 401 ───────────────────────────────────────────
          if (e.response?.statusCode == 401) {
            await GoldSession.instance.clear();
            final nav = goldNavigatorKey.currentState;
            if (nav != null) {
              // Pop everything and go back to the root welcome screen.
              nav.pushNamedAndRemoveUntil('/', (_) => false);
            }
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  // ── Pretty loggers ─────────────────────────────────────────────────────────

  void _logRequest(RequestOptions options) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString();
    final payload = options.data;

    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════');
    debugPrint('║ 📤 REQUEST  $method');
    debugPrint('║ 🌐 URL     : $url');
    if (payload != null) {
      final body = payload is Map || payload is List
          ? const JsonEncoder.withIndent('  ').convert(payload)
          : payload.toString();
      debugPrint('║ 📦 PAYLOAD :');
      for (final line in body.split('\n')) {
        debugPrint('║   $line');
      }
    }
    debugPrint('╚══════════════════════════════════════════════════════════');
  }

  void _logResponse(Response response) {
    final method = response.requestOptions.method.toUpperCase();
    final url = response.requestOptions.uri.toString();
    final status = response.statusCode ?? 0;
    final isOk = status >= 200 && status < 300;
    final icon = isOk ? '✅' : '⚠️ ';

    String body;
    try {
      body = const JsonEncoder.withIndent('  ').convert(response.data);
    } catch (_) {
      body = response.data?.toString() ?? '(empty)';
    }

    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════');
    debugPrint('║ $icon RESPONSE  $method  [$status]');
    debugPrint('║ 🌐 URL      : $url');
    debugPrint('║ 📨 RESPONSE :');
    for (final line in body.split('\n')) {
      debugPrint('║   $line');
    }
    debugPrint('╚══════════════════════════════════════════════════════════');
  }

  void _logError(DioException e) {
    final method = e.requestOptions.method.toUpperCase();
    final url = e.requestOptions.uri.toString();
    final status = e.response?.statusCode ?? 0;

    String body;
    try {
      body = const JsonEncoder.withIndent('  ').convert(e.response?.data);
    } catch (_) {
      body = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    }

    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════');
    debugPrint('║ ❌ ERROR    $method  [$status]');
    debugPrint('║ 🌐 URL     : $url');
    debugPrint('║ 💬 MESSAGE : ${e.message}');
    debugPrint('║ 📨 BODY    :');
    for (final line in body.split('\n')) {
      debugPrint('║   $line');
    }
    if (status == 401) {
      debugPrint('║ 🔒 401 Unauthorised – token may be expired.');
    }
    debugPrint('╚══════════════════════════════════════════════════════════');
  }

  // ── Token helpers ──────────────────────────────────────────────────────────

  /// Reads token from GoldSession memory.
  /// Falls back to SharedPreferences if session not yet loaded.
  Future<String?> _getFallbackToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('[GoldDio] Could not read token: $e');
      return null;
    }
  }

  /// Returns true when a valid session token exists.
  Future<bool> isLoggedIn() => GoldSession.instance.load();

  /// Persist token — delegates to GoldSession.
  Future<void> saveToken(String token) async {
    // Token-only save (full session saved via AuthRepository.saveSession)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    debugPrint('[GoldDio] ✅ Token saved.');
  }

  /// Wipe token — delegates to GoldSession.
  Future<void> clearToken() => GoldSession.instance.clear();
}

// ── Exception model ────────────────────────────────────────────────────────────

/// Unified network exception thrown by [GoldNetworkService].
class GoldNetworkException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  const GoldNetworkException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() =>
      'GoldNetworkException($statusCode): $message\nData: $data';
}
