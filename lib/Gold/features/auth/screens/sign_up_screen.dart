import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/features/auth/models/auth_models.dart';
import 'package:bank_scan/Gold/widgets/gold_back_button.dart';
import 'package:bank_scan/Gold/features/auth/repository/auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/screens/sign_in_screen.dart';
import 'package:bank_scan/Gold/features/auth/screens/password_changed_screen.dart';

/// Sign-Up Screen
///
/// POST http://localhost:7000/api/users
/// Payload: { email, name, phoneNumber, companyType, companyName }
class GoldSignUpScreen extends StatefulWidget {
  const GoldSignUpScreen({super.key});

  @override
  State<GoldSignUpScreen> createState() => _GoldSignUpScreenState();
}

class _GoldSignUpScreenState extends State<GoldSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();

  bool _isIndividual = true; // true = Individual, false = Company
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyNameCtrl.dispose();
    super.dispose();
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _handleSignUp() async {
    if (!_agreeToTerms) {
      _showSnack('Please agree to terms & conditions');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final req = RegisterRequest(
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        companyType: _isIndividual ? 'Individual' : 'Company',
        companyName: _companyNameCtrl.text.trim(),
      );

      final apiRes = await AuthRepository.instance.register(req);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (apiRes.isSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GoldPasswordChangedScreen(
              email: _emailCtrl.text.trim(),
              name: _nameCtrl.text.trim(),
            ),
          ),
        );
      } else {
        _showSnack(apiRes.extractMessage('Registration failed. Please try again.'));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Network error. Please check your connection.');
      }
    }
  }

  // ── Snack helper ────────────────────────────────────────────────────────────

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
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

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
                Text('Create an account', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'Fill in your details to get started',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // ── Name ─────────────────────────────────────────────────────
                _label('Name *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDeco('Enter your full name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Email ─────────────────────────────────────────────────────
                _label('Email *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('Enter your email address'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Phone Number ──────────────────────────────────────────────
                _label('Phone Number *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _inputDeco('Enter your 10-digit phone number'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (v.trim().length < 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── Company Type ──────────────────────────────────────────────
                _label('Company Type *'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _typeButton(
                        label: 'Individual',
                        icon: Icons.person_rounded,
                        selected: _isIndividual,
                        onTap: () => setState(() => _isIndividual = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typeButton(
                        label: 'Company',
                        icon: Icons.business_rounded,
                        selected: !_isIndividual,
                        onTap: () => setState(() => _isIndividual = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Company Name ──────────────────────────────────────────────
                _label('Company Name *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _companyNameCtrl,
                  decoration: _inputDeco('Enter your company name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── Terms ─────────────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (v) =>
                          setState(() => _agreeToTerms = v ?? false),
                      activeColor: AppColors.primaryBlue,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _agreeToTerms = !_agreeToTerms),
                        child: Text(
                          'I agree to all terms & conditions',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Submit button ─────────────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('CREATE ACCOUNT', style: AppTextStyles.buttonText),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign-in link ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GoldSignInScreen(),
                        ),
                      ),
                      child: Text(
                        'SIGN IN',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      );

  Widget _typeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryBlue,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.white : AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.white : AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
