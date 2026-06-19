import 'package:bank_scan/services/network_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_theme.dart';
import '../utils/custom_dialog.dart';
import '../widgets/bank_loader.dart';
import 'sign_in_screen.dart';

class PasswordChangedScreen extends StatefulWidget {
  final String email;
  final String name;

  const PasswordChangedScreen({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<PasswordChangedScreen> createState() => _PasswordChangedScreenState();
}

class _PasswordChangedScreenState extends State<PasswordChangedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message) {
    CustomDialog.show(
      context: context,
      message: message,
      type: DialogType.success,
      title: 'Success!',
      buttonText: 'OK',
      barrierDismissible: false,
      onButtonPressed: () {
        Navigator.of(context).pop();
        // Navigate to sign in screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      },
    );
  }

  void _showErrorDialog(String message, {required bool showResend}) {
    CustomDialog.show(
      context: context,
      message: message,
      type: DialogType.error,
      title: 'Error!',
    );
  }

  void _handleSetPassword() async {
    if (!_agreeToTerms) {
      _showErrorDialog('Please agree to terms & conditions', showResend: false);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var setPasswordURL = '${dotenv.env['API_URL']}users/setPassword';
      print('Set Password URL: $setPasswordURL');

      var payload = {
        'email': widget.email,
        'temporaryPassword': _otpController.text,
        'newPassword': _passwordController.text,
      };

      print('Set Password Payload: $payload');

      var response = await ServiceWithDataPut(setPasswordURL, payload).data();

      print('Set Password Response: $response');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Check response format: [statusCode, responseBody]
        if (response is List && response.length >= 2) {
          int statusCode = response[0];
          dynamic responseBody = response[1];

          // Check if request was successful (200 or 201)
          if (statusCode >= 200 && statusCode < 300) {
            // Success - show success dialog
            String successMessage = 'Password updated successfully!';

            if (responseBody is Map && responseBody.containsKey('message')) {
              successMessage = responseBody['message'].toString();
            }

            _showSuccessDialog(successMessage);
          } else {
            // Error - extract and display user-friendly message in dialog
            String errorMessage = 'Something went wrong. Please try again.';

            if (responseBody is Map) {
              // Try to extract message from response
              if (responseBody.containsKey('message')) {
                errorMessage = responseBody['message'].toString();
              } else if (responseBody.containsKey('error')) {
                errorMessage = responseBody['error'].toString();
              } else if (responseBody.containsKey('errors')) {
                // Handle multiple errors
                var errors = responseBody['errors'];
                if (errors is Map) {
                  errorMessage = errors.values.first.toString();
                } else if (errors is List && errors.isNotEmpty) {
                  errorMessage = errors.first.toString();
                }
              }
            }

            // Display error in center popup dialog with resend option
            _showErrorDialog(errorMessage, showResend: true);
          }
        } else {
          // Unexpected response format
          _showErrorDialog(
            'Unexpected response from server. Please try again.',
            showResend: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showErrorDialog(
          'Network error. Please check your connection and try again.',
          showResend: true,
        );
      }
    }
  }

  String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }
    if (value.length < 10) {
      return 'OTP must be at least 10 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Create your password',
                  style: AppTheme.headingLarge,
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Enter Valid OTP from your verified mail id',
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                // OTP Field
                _buildLabel('OTP'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.text,
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(
                  //     RegExp(r'[A-Za-z0-9*!@#$%^&()]'),
                  //   ),
                  // ],
                  decoration: AppTheme.inputDecoration('X X X X X X'),
                  // validator: _validateOTP,
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 20),
                // Password Field
                _buildLabel('Password'),
                const SizedBox(height: 4),
                // Password Instructions
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Password format: Naveen@1234',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration:
                      AppTheme.inputDecoration(
                        'Enter your password here',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textHint,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                // Confirm Password Field
                _buildLabel('Confirm Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration:
                      AppTheme.inputDecoration(
                        'Enter your password here',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textHint,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),
                // Terms & Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryBlue,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToTerms = !_agreeToTerms;
                          });
                        },
                        child: const Text(
                          'I agree to all terms & conditions',
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Sign Up Button
                GestureDetector(
                  onTap: _isLoading ? null : _handleSetPassword,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? Colors.grey.shade400
                          : AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // responsive radius
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: RefreshLoader(
                              size: 22,
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'SIGN-UP NOW',
                            style: AppTheme.buttonText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an Account? ',
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightBlue,
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
