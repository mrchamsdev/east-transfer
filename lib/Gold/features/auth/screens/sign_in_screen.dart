import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/features/auth/models/auth_models.dart';
import 'package:bank_scan/Gold/features/auth/repository/auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/repository/face_auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/screens/forgot_password_screen.dart';
import 'package:bank_scan/Gold/features/main/main_navigation_screen.dart';

/// Gold Sign-In Screen
/// POST  users/login  →  { "email": "...", "passWord": "..." }
class GoldSignInScreen extends StatefulWidget {
  const GoldSignInScreen({super.key});

  @override
  State<GoldSignInScreen> createState() => _GoldSignInScreenState();
}

class _GoldSignInScreenState extends State<GoldSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  bool _isFaceIdAvailable = false;
  bool _isFaceIdEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkFaceId();
  }

  Future<void> _checkFaceId() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (canCheckBiometrics && isDeviceSupported) {
        if (mounted) setState(() => _isFaceIdAvailable = true);
        
        final isEnabled = await _secureStorage.read(key: 'isFaceEnabled');
        if (isEnabled == 'true') {
          if (mounted) setState(() => _isFaceIdEnabled = true);
        }
      }
    } catch (e) {
      debugPrint('Biometric check failed: $e');
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios_id';
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Sign-In handler ───────────────────────────────────────────────────────

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text.trim().length < 6) {
      _showError('Please enter a valid 6-digit password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final req = LoginRequest(
        email: _emailCtrl.text.trim(),
        passWord: _passwordCtrl.text,
      );

      final apiRes = await AuthRepository.instance.login(req);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (apiRes.isSuccess) {
        final loginRes = LoginResponse.fromJson(
          apiRes.body is Map ? Map<String, dynamic>.from(apiRes.body as Map) : {},
        );
        if (loginRes.accountStatus?.toLowerCase() == 'deactivated' || loginRes.accountStatus?.toLowerCase() == 'inactive') {
          _showError('Your account is deactivated! Contact super admin for assistance');
          return;
        }

        if (loginRes.hasToken) {
          await AuthRepository.instance.saveSession(loginRes);
          await _secureStorage.write(key: 'token', value: loginRes.token);
          await _secureStorage.write(key: 'email', value: _emailCtrl.text.trim());

          if (!mounted) return;


          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (_) => false,
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _showSuccess('Sign in successful!');
          });
        } else {
          _showError('Login succeeded but no token was returned.');
        }
      } else {
        _showError(apiRes.extractMessage('Invalid email or password.'));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Network error. Please check your connection.');
      }
    }
  }

  Future<void> _handleFaceLogin() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to sign in',
      );

      if (didAuthenticate) {
        final email = await _secureStorage.read(key: 'email');
        final deviceId = await _secureStorage.read(key: 'biometricDeviceId');

        if (email != null && deviceId != null) {
          setState(() => _isLoading = true);
          final res = await FaceAuthRepository.instance.faceLogin(email, deviceId);
          setState(() => _isLoading = false);

          if (res.isSuccess && res.data != null) {
            final loginRes = LoginResponse.fromJson(res.data!);
            if (loginRes.accountStatus?.toLowerCase() == 'deactivated' || loginRes.accountStatus?.toLowerCase() == 'inactive') {
              _showError('Your account is deactivated! Contact super admin for assistance');
              return;
            }

            if (loginRes.hasToken) {
              await AuthRepository.instance.saveSession(loginRes);
              await _secureStorage.write(key: 'token', value: loginRes.token);
              
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                (_) => false,
              );
              _showSuccess('Sign in successful!');
            } else {
              _showError('Login succeeded but no token was returned.');
            }
          } else {
            _showError(res.message ?? 'Face Login Failed');
          }
        } else {
           _showError('Credentials not found. Please login with password first.');
        }
      }
    } catch (e) {
      if (mounted) _showError('Face authentication failed.');
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text('SIGN-IN', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'Welcome Back To The App',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                _label('Email Id'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('Enter your email id'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password
                _label('Password'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: true,
                    obscuringCharacter: '●',
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 48,
                      fieldWidth: 40,
                      borderWidth: 1.5,
                      activeFillColor: Colors.white,
                      inactiveFillColor: const Color(0xFFF9FAFB),
                      selectedFillColor: Colors.white,
                      activeColor: AppColors.primaryBlue,
                      inactiveColor: const Color(0xFFE5E7EB),
                      selectedColor: AppColors.primaryBlue,
                    ),
                    cursorColor: AppColors.primaryBlue,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    keyboardType: TextInputType.number,
                    onCompleted: (v) => _passwordCtrl.text = v,
                    onChanged: (v) => _passwordCtrl.text = v,
                  ),
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GoldForgotPasswordScreen(),
                      ),
                    ),
                    child: Text(
                      'Forgot Password',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign-In button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading
                          ? AppColors.primaryBlue.withOpacity(0.7)
                          : AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSignIn,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('SIGN IN', style: AppTextStyles.buttonText),
                  ),
                ),
                if (_isFaceIdEnabled) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Login with Face ID', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _isLoading ? null : _handleFaceLogin,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      );
}




