import 'package:bank_scan/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../widgets/bank_loader.dart';
import 'set_password_screen.dart';
import '../services/network_service.dart';
import '../utils/custom_dialog.dart';
import 'forgot_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _otpCode = '';
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    CustomDialog.show(
      context: context,
      message: message,
      type: DialogType.error,
      title: 'Verification Failed',
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

  void _handleVerify() async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var confirmPasswordURL =
          '${dotenv.env['API_URL']}users/confirmForgotPassword';
      print('Confirm Forgot Password URL: $confirmPasswordURL');

      var payload = {'email': widget.email, 'confirmationCode': _otpCode};

      print('Confirm Forgot Password Payload: $payload');

      var response = await ServiceWithDataPost(
        confirmPasswordURL,
        payload,
      ).data();

      print('Confirm Forgot Password Response: $response');

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
            String successMessage = 'OTP verified successfully!';

            if (responseBody is Map) {
              if (responseBody.containsKey('message')) {
                successMessage = responseBody['message'].toString();
              }
            }

            // Show success message
            _showSuccessDialog(successMessage);

            // Navigate to set password screen after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SetPasswordScreen(email: widget.email),
                  ),
                );
              }
            });
          } else {
            // Error - extract and display user-friendly message
            String errorMessage = 'Invalid OTP. Please try again.';

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

  void _handleResend() async {
    // Navigate back to forgot password screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
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
                  'Verify Code',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'An authentication code has been sent to ${widget.email}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 40),
                // OTP Field Label
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // OTP Input Field
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
                      activeColor: const Color(0xFF1E3A8A),
                      inactiveColor: const Color(0xFFE5E7EB),
                      selectedColor: const Color(0xFF1E3A8A),
                    ),
                    cursorColor: const Color(0xFF1E3A8A),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    keyboardType: TextInputType.number,
                    onCompleted: (value) {
                      _otpCode = value;
                    },
                    onChanged: (value) {
                      _otpCode = value;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Resend Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive a code? ",
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                    TextButton(
                      onPressed: _handleResend,
                      child: const Text(
                        'RESEND',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Help Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Help?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'If you did not receive the verification code or if you have changed your email address, please check your email carefully and try again ',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Verify Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? const Color(0xFF1E3A8A).withOpacity(0.7)
                        : const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isLoading ? null : _handleVerify,
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
                                'VERIFY',
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
