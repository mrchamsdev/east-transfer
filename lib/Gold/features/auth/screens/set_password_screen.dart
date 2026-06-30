import 'package:flutter/material.dart';

import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/features/auth/models/auth_models.dart';
import 'package:bank_scan/Gold/features/auth/repository/auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/screens/password_success_screen.dart';
import 'package:bank_scan/Gold/widgets/gold_back_button.dart';

/// Set Password Screen (after OTP verification in forgot-password flow)
/// POST users/resetPassword → { email, newPassword, confirmNewPassword }
class GoldSetPasswordScreen extends StatefulWidget {
  final String email;

  const GoldSetPasswordScreen({super.key, required this.email});

  @override
  State<GoldSetPasswordScreen> createState() => _GoldSetPasswordScreenState();
}

class _GoldSetPasswordScreenState extends State<GoldSetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final req = ResetPasswordRequest(
        email: widget.email,
        newPassword: _passwordCtrl.text,
        confirmNewPassword: _confirmPasswordCtrl.text,
      );
      final apiRes = await AuthRepository.instance.resetPassword(req);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (apiRes.isSuccess) {
        _showSnack(
          apiRes.extractMessage('Password reset successfully!'),
          success: true,
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GoldPasswordSuccessScreen()),
          );
        }
      } else {
        _showSnack(
          apiRes.extractMessage('Failed to reset password. Please try again.'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Network error. Please check your connection.');
      }
    }
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!v.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GoldBackButton(
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
                Text('Set Password', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  "Please set a new password for your account. We'll ask for this whenever you sign in.",
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 40),

                // New Password
                _label('Create Password'),
                const SizedBox(height: 4),
                Text(
                  'Format: Name@1234',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: _inputDeco('Enter your password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textHint,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 24),

                // Confirm Password
                _label('Re-enter Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirm,
                  decoration: _inputDeco('Re-enter your password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textHint,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 32),

                // Password tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure password tips:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _tip(
                        'Use at least 8 characters, a combination of numbers and letters is best.',
                      ),
                      const SizedBox(height: 8),
                      _tip(
                        'Do not use the same password you have used previously.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Confirm button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading
                          ? AppColors.primaryBlue.withValues(alpha: 0.7)
                          : AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleConfirm,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('CONFIRM', style: AppTextStyles.buttonText),
                  ),
                ),
                const SizedBox(height: 32),
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
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );

  Widget _tip(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
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
