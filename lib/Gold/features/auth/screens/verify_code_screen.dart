import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/features/auth/models/auth_models.dart';
import 'package:bank_scan/Gold/features/auth/repository/auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/screens/set_password_screen.dart';
import 'package:bank_scan/Gold/features/auth/screens/forgot_password_screen.dart';

/// Verify OTP Screen
/// POST users/confirmForgotPassword → { "email": "...", "confirmationCode": "..." }
class GoldVerifyCodeScreen extends StatefulWidget {
  final String email;

  const GoldVerifyCodeScreen({super.key, required this.email});

  @override
  State<GoldVerifyCodeScreen> createState() => _GoldVerifyCodeScreenState();
}

class _GoldVerifyCodeScreenState extends State<GoldVerifyCodeScreen> {
  String _otp = '';
  bool _isLoading = false;

  Future<void> _handleVerify() async {
    if (_otp.length != 6) {
      _showSnack('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final req = VerifyOtpRequest(
        email: widget.email,
        confirmationCode: _otp,
      );
      final apiRes = await AuthRepository.instance.verifyOtp(req);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (apiRes.isSuccess) {
        _showSnack(
          apiRes.extractMessage('OTP verified successfully!'),
          success: true,
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoldSetPasswordScreen(email: widget.email),
            ),
          );
        }
      } else {
        _showSnack(apiRes.extractMessage('Invalid OTP. Please try again.'));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text('Verify Code', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'An authentication code has been sent to ${widget.email}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              Text(
                'Enter OTP',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // 6-digit OTP
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
                  onCompleted: (v) => setState(() => _otp = v),
                  onChanged: (v) => setState(() => _otp = v),
                ),
              ),
              const SizedBox(height: 24),

              // Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive a code? ",
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GoldForgotPasswordScreen(),
                      ),
                    ),
                    child: Text(
                      'RESEND',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Help text
              Text(
                'Need Help?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you did not receive the verification code or if you have changed your email address, please check your email carefully and try again.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              // Verify button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading
                        ? AppColors.primaryBlue.withOpacity(0.7)
                        : AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleVerify,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('VERIFY', style: AppTextStyles.buttonText),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
