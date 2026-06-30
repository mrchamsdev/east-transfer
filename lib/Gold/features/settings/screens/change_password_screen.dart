import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/gold_session.dart';
import '../../auth/repository/auth_repository.dart';
import '../../../widgets/gold_back_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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

  Future<void> _handleChangePassword() async {
    final oldPassword = _currentCtrl.text.trim();
    final newPassword = _newCtrl.text.trim();
    final confirmPassword = _confirmCtrl.text.trim();

    if (oldPassword.length != 6) {
      _showSnack('Please enter your 6-digit current password');
      return;
    }
    if (newPassword.length != 6) {
      _showSnack('Please enter a new 6-digit password');
      return;
    }
    if (confirmPassword.length != 6) {
      _showSnack('Please confirm your new 6-digit password');
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnack('New passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthRepository.instance.changeOldPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        reEnterNewPassword: confirmPassword,
      );

      setState(() => _isLoading = false);

      if (response.isSuccess) {
        _showSnack(
          response.extractMessage('Password changed successfully!'),
          success: true,
        );
        _currentCtrl.clear();
        _newCtrl.clear();
        _confirmCtrl.clear();
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnack(response.extractMessage('Failed to change password.'));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('An unexpected error occurred. Please try again.');
    }
  }

  /// Formats ISO-8601 string → "15 Jun 2026 • 11:24 PM"
  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day   = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year  = dt.year;
      final hour  = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min   = dt.minute.toString().padLeft(2, '0');
      final ampm  = dt.hour < 12 ? 'AM' : 'PM';
      return '$day $month $year  •  $hour:$min $ampm';
    } catch (_) {
      return iso;
    }
  }

  Widget _buildLastChangedCard() {
    final raw = GoldSession.instance.passwordChangedDate;
    final formatted = _formatDate(raw);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Password Changed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E3B),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: GoldBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Last Changed Date Card
              _buildLastChangedCard(),
              const SizedBox(height: 16),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose a secure 6-digit PIN to protect your account.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pin Sections
              _buildPinSection(
                title: 'Current PIN',
                controller: _currentCtrl,
                isObscured: _obscureCurrent,
                onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 20),

              _buildPinSection(
                title: 'New PIN',
                controller: _newCtrl,
                isObscured: _obscureNew,
                onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 20),

              _buildPinSection(
                title: 'Confirm New PIN',
                controller: _confirmCtrl,
                isObscured: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 40),

              // Action Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading
                        ? AppColors.primaryBlue.withOpacity(0.7)
                        : AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleChangePassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update PIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinSection({
    required String title,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PinCodeTextField(
          appContext: context,
          length: 6,
          obscureText: isObscured,
          obscuringCharacter: '●',
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 48,
            fieldWidth: 44,
            borderWidth: 1.5,
            activeFillColor: Colors.white,
            inactiveFillColor: const Color(0xFFF9FAFB),
            selectedFillColor: Colors.white,
            activeColor: AppColors.primaryBlue,
            inactiveColor: const Color(0xFFE5E7EB),
            selectedColor: AppColors.primaryBlue,
          ),
          cursorColor: AppColors.primaryBlue,
          animationDuration: const Duration(milliseconds: 200),
          enableActiveFill: true,
          keyboardType: TextInputType.number,
          controller: controller,
          autoDisposeControllers: false,
          onChanged: (v) {},
        ),
      ],
    );
  }
}
