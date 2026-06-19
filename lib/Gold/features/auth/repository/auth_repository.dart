import 'package:bank_scan/Gold/core/network/gold_api_constants.dart';
import 'package:bank_scan/Gold/core/network/gold_network_service.dart';
import 'package:bank_scan/Gold/core/network/gold_session.dart';
import 'package:bank_scan/Gold/features/auth/models/auth_models.dart';

/// Centralised auth API layer for the Gold module.
///
/// All public endpoints (no token required) use [GoldPostService] /
/// [GoldPutService] which explicitly strip the Authorization header.
///
/// Endpoint map (from [GoldApiConstants]):
///   POST  /users                         → register
///   POST  /users/login                   → login
///   POST  /users/requestForPassword      → forgot password (send OTP)
///   POST  /users/confirmForgotPassword   → verify OTP
///   POST  /users/resetPassword           → reset password (forgot flow)
///   PUT   /users/setPassword             → set password (after sign-up OTP)
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  // ── Register ───────────────────────────────────────────────────────────────

  /// POST /users
  Future<ApiResponse> register(RegisterRequest req) async {
    final res = await GoldPostService(
      GoldApiConstants.register,
      req.toJson(),
    ).data();
    return ApiResponse(statusCode: res[0] as int, body: res[1]);
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  /// POST /users/login
  Future<ApiResponse> login(LoginRequest req) async {
    final res = await GoldPostService(
      GoldApiConstants.login,
      req.toJson(),
    ).data();
    return ApiResponse(statusCode: res[0] as int, body: res[1]);
  }

  // ── Forgot Password ────────────────────────────────────────────────────────

  /// POST /users/requestForPassword
  Future<ApiResponse> requestPassword(ForgotPasswordRequest req) async {
    final res = await GoldPostService(
      GoldApiConstants.requestPassword,
      req.toJson(),
    ).data();
    return ApiResponse(statusCode: res[0] as int, body: res[1]);
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────

  /// POST /users/confirmForgotPassword
  Future<ApiResponse> verifyOtp(VerifyOtpRequest req) async {
    final res = await GoldPostService(
      GoldApiConstants.confirmForgotPassword,
      req.toJson(),
    ).data();
    return ApiResponse(statusCode: res[0] as int, body: res[1]);
  }

  // ── Reset Password (forgot flow) ───────────────────────────────────────────

  /// POST /users/resetPassword
  Future<ApiResponse> resetPassword(ResetPasswordRequest req) async {
    final res = await GoldPostService(
      GoldApiConstants.resetPassword,
      req.toJson(),
    ).data();
    return ApiResponse(statusCode: res[0] as int, body: res[1]);
  }

  // ── Set Password (sign-up OTP flow) ───────────────────────────────────────

  /// PUT /users/setPassword
  Future<ApiResponse> setPassword(SetPasswordRequest req) async {
    final res = await GoldPutService(
      GoldApiConstants.setPassword,
      req.toJson(),
    ).data();
    return ApiResponse(statusCode: res[0] as int, body: res[1]);
  }

  // ── Change Password ────────────────────────────────────────────────────────

  /// POST /users/changeOldPassword
  Future<ApiResponse> changeOldPassword({
    required String oldPassword,
    required String newPassword,
    required String reEnterNewPassword,
  }) async {
    final res = await GoldPostAuthService(
      GoldApiConstants.changeOldPassword,
      {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'reEnterNewPassword': reEnterNewPassword,
      },
    ).data();
    return ApiResponse(statusCode: res[0] as int, body: res[1]);
  }

  // ── Session helpers ────────────────────────────────────────────────────────

  /// Save full session after successful login.
  /// Stores token + all user fields via [GoldSession].
  Future<void> saveSession(LoginResponse res) async {
    if (!res.hasToken) return;
    await GoldSession.instance.save(
      token:               res.token!,
      userId:              res.userId ?? 0,
      userName:            res.userName ?? '',
      userEmail:           res.userEmail ?? '',
      userPhone:           res.userPhone,
      companyType:         res.companyType,
      companyName:         res.companyName,
      passwordChangedDate: res.passwordChangedDate,
      userAccess:          res.userAccess,
    );
  }

  /// Wipe session on logout.
  Future<void> clearSession() => GoldSession.instance.clear();

  /// Quick check: is the user currently authenticated?
  Future<bool> isAuthenticated() => GoldSession.instance.load();
}
