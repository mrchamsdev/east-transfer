import 'package:bank_scan/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/bank_loader.dart';
import 'verify_code_screen.dart';
import 'sign_up_screen.dart';
import '../services/network_service.dart';
import '../utils/custom_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    CustomDialog.show(
      context: context,
      message: message,
      type: DialogType.error,
      title: 'Request Failed',
    );
  }

  void _showSuccessDialog(String message) {
    CustomDialog.show(
      context: context,
      message: message,
      type: DialogType.success,
      title: 'Success',
    );
  }

  void _handleSend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var requestPasswordURL =
          '${dotenv.env['API_URL']}users/requestForPassword';
      print('Request Password URL: $requestPasswordURL');

      var payload = {'email': _emailController.text.trim()};

      print('Request Password Payload: $payload');

      var response = await ServiceWithDataPost(
        requestPasswordURL,
        payload,
      ).data();

      print('Request Password Response: $response');

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
            // Extract success message
            String successMessage =
                'OTP has been sent to your email. Please check your inbox.';

            if (responseBody is Map) {
              if (responseBody.containsKey('message')) {
                successMessage = responseBody['message'].toString();
              }
            }

            // Show success message
            _showSuccessDialog(successMessage);

            // Navigate to verify code screen after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VerifyCodeScreen(email: _emailController.text.trim()),
                  ),
                );
              }
            });
          } else {
            // Error - extract and display user-friendly message
            String errorMessage = 'Failed to send OTP. Please try again.';

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

            // Display error in center popup dialog
            _showErrorDialog(errorMessage);
          }
        } else {
          // Unexpected response format
          _showErrorDialog(
            'Unexpected response from server. Please try again.',
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
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
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
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Enter your Email Id to get the OTP',
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                // Email Field
                const Text(
                  'Enter Email Id',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email Id',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
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
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Send Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? AppTheme.primaryBlue.withOpacity(0.7)
                        : AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isLoading ? null : _handleSend,
                      child: Center(
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
                            : const Text(
                                'SEND',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an Account? ",
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'SIGN UP',
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
}
