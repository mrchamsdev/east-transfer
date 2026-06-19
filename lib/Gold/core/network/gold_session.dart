import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/models/auth_models.dart';

/// Single source of truth for the logged-in user's session.
///
/// Stores data both in memory (fast) and [SharedPreferences] (persistent).
/// Keys match those used by [GoldDioClient] for the auth token.
///
/// Usage anywhere in the app:
/// ```dart
/// final name  = GoldSession.instance.userName;
/// final email = GoldSession.instance.userEmail;
/// final id    = GoldSession.instance.userId;
/// final token = GoldSession.instance.token;
///
/// // Access control
/// if (GoldSession.instance.canRead('Gold')) { ... }
/// if (GoldSession.instance.canWrite('Gold')) { ... }
/// ```
class GoldSession {
  GoldSession._();
  static final GoldSession instance = GoldSession._();

  // ── SharedPreferences keys ─────────────────────────────────────────────────
  static const _kToken               = 'auth_token';
  static const _kUserId              = 'user_id';
  static const _kUserName            = 'user_name';
  static const _kUserEmail           = 'user_email';
  static const _kUserPhone           = 'user_phone';
  static const _kCompanyType         = 'company_type';
  static const _kCompanyName         = 'company_name';
  static const _kUserAccess          = 'user_access'; // JSON-encoded list
  static const _kPasswordChangedDate = 'password_changed_date';

  // ── In-memory cache ────────────────────────────────────────────────────────
  String? _token;
  int?    _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _companyType;
  String? _companyName;
  String? _passwordChangedDate;
  List<UserAccessEntry> _userAccess = [];

  // ── Getters ────────────────────────────────────────────────────────────────

  String? get token               => _token;
  int?    get userId              => _userId;
  String? get userName            => _userName;
  String? get userEmail           => _userEmail;
  String? get userPhone           => _userPhone;
  String? get companyType         => _companyType;
  String? get companyName         => _companyName;
  String? get passwordChangedDate => _passwordChangedDate;

  /// Full list of module access entries for the logged-in user.
  List<UserAccessEntry> get userAccess => List.unmodifiable(_userAccess);

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // ── Access control helpers ─────────────────────────────────────────────────

  /// Returns true if the user has READ access to [module].
  /// Module names are case-insensitive (e.g. 'gold', 'Gold', 'GOLD' all match).
  bool canRead(String module) {
    final entry = _findEntry(module);
    return (entry?.read ?? false) || (entry?.write ?? false);
  }

  /// Returns true if the user has WRITE access to [module].
  bool canWrite(String module) {
    final entry = _findEntry(module);
    return entry?.write ?? false;
  }

  UserAccessEntry? _findEntry(String module) {
    try {
      return _userAccess.firstWhere(
        (e) => e.module.toLowerCase() == module.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Save session after login ───────────────────────────────────────────────

  /// Call this immediately after a successful login.
  /// Writes all fields to memory and [SharedPreferences].
  Future<void> save({
    required String token,
    required int    userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    String? companyType,
    String? companyName,
    String? passwordChangedDate,
    List<UserAccessEntry> userAccess = const [],
  }) async {
    // Memory
    _token               = token;
    _userId              = userId;
    _userName            = userName;
    _userEmail           = userEmail;
    _userPhone           = userPhone;
    _companyType         = companyType;
    _companyName         = companyName;
    _passwordChangedDate = passwordChangedDate;
    _userAccess          = List.from(userAccess);

    // Serialise userAccess → JSON string for persistence
    final accessJson = jsonEncode(userAccess.map((e) => e.toJson()).toList());

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken,    token);
    await prefs.setInt   (_kUserId,   userId);
    await prefs.setString(_kUserName, userName);
    await prefs.setString(_kUserEmail, userEmail);
    if (userPhone           != null) await prefs.setString(_kUserPhone,           userPhone);
    if (companyType         != null) await prefs.setString(_kCompanyType,         companyType);
    if (companyName         != null) await prefs.setString(_kCompanyName,         companyName);
    if (passwordChangedDate != null) await prefs.setString(_kPasswordChangedDate, passwordChangedDate);
    await prefs.setString(_kUserAccess, accessJson);

    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════');
      debugPrint('║ 💾 SESSION SAVED');
      debugPrint('║   userId      : $userId');
      debugPrint('║   userName    : $userName');
      debugPrint('║   userEmail   : $userEmail');
      debugPrint('║   userPhone   : $userPhone');
      debugPrint('║   companyType : $companyType');
      debugPrint('║   companyName : $companyName');
      debugPrint('║   userAccess  : ${userAccess.map((e) => "${e.module}[R:${e.read},W:${e.write}]").join(", ")}');
      debugPrint('║   token       : ${token.substring(0, 20)}...');
      debugPrint('╚══════════════════════════════════════════════════════════');
    }
  }

  // ── Load session on app start ──────────────────────────────────────────────

  /// Called during startup to restore session from [SharedPreferences].
  /// Returns true if a valid token was found.
  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token               = prefs.getString(_kToken);
    _userId              = prefs.getInt(_kUserId);
    _userName            = prefs.getString(_kUserName);
    _userEmail           = prefs.getString(_kUserEmail);
    _userPhone           = prefs.getString(_kUserPhone);
    _companyType         = prefs.getString(_kCompanyType);
    _companyName         = prefs.getString(_kCompanyName);
    _passwordChangedDate = prefs.getString(_kPasswordChangedDate);

    // Restore userAccess from JSON
    final accessJson = prefs.getString(_kUserAccess);
    if (accessJson != null && accessJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(accessJson) as List;
        _userAccess = decoded
            .whereType<Map>()
            .map((e) => UserAccessEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        _userAccess = [];
      }
    }

    if (kDebugMode && isLoggedIn) {
      debugPrint('[GoldSession] ✅ Session restored → userId: $_userId, name: $_userName, modules: ${_userAccess.length}');
    }
    return isLoggedIn;
  }

  // ── Clear on logout ────────────────────────────────────────────────────────

  /// Wipes memory + SharedPreferences. Call on logout.
  Future<void> clear() async {
    _token               = null;
    _userId              = null;
    _userName            = null;
    _userEmail           = null;
    _userPhone           = null;
    _companyType         = null;
    _companyName         = null;
    _passwordChangedDate = null;
    _userAccess          = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserPhone);
    await prefs.remove(_kCompanyType);
    await prefs.remove(_kCompanyName);
    await prefs.remove(_kPasswordChangedDate);
    await prefs.remove(_kUserAccess);

    debugPrint('[GoldSession] 🗑️  Session cleared.');
  }
}
