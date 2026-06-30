import 'package:flutter/material.dart';

import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/features/auth/models/auth_models.dart';
import 'package:bank_scan/Gold/features/auth/repository/auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/screens/verify_code_screen.dart';
import 'package:bank_scan/Gold/widgets/gold_back_button.dart';

/// Forgot Password Screen
/// POST  users/requestForPassword  →  { "email": "..." }
class GoldForgotPasswordScreen extends StatefulWidget {
  const GoldForgotPasswordScreen({super.key});

  @override
  State<GoldForgotPasswordScreen> createState() =>
      _GoldForgotPasswordScreenState();
}

class _GoldForgotPasswordScreenState extends State<GoldForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final req = ForgotPasswordRequest(email: _emailCtrl.text.trim());
      final apiRes = await AuthRepository.instance.requestPassword(req);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (apiRes.isSuccess) {
        _showSnack(
          apiRes.extractMessage(
            'OTP has been sent to your email. Please check your inbox.',
          ),
          success: true,
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  GoldVerifyCodeScreen(email: _emailCtrl.text.trim()),
            ),
          );
        }
      } else {
        _showSnack(
          apiRes.extractMessage('Failed to send OTP. Please try again.'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Network error. Please check your connection.');
      }
    }
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
                Text('Forgot Password', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'Enter your Email Id to get the OTP',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),

                // Email
                Text(
                  'Enter Email Id',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('Enter your email Id'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Send button
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
                    onPressed: _isLoading ? null : _handleSend,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('SEND', style: AppTextStyles.buttonText),
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
