import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/bank_loader.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';
import '../screens/main_navigation.dart';
import 'package:bank_scan/myapp.dart';
import '../services/network_service.dart';
import '../utils/app_theme.dart';
import '../utils/custom_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    CustomDialog.show(
      context: context,
      message: message,
      type: DialogType.error,
      title: 'Sign In Failed',
    );
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var loginURL = '${dotenv.env['API_URL']}users/login';
      print('Login URL: $loginURL');

      var payload = {
        'email': _emailController.text.trim(),
        'passWord': _passwordController.text,
      };

      print('Login Payload: $payload');

      var response = await ServiceWithDataPost(loginURL, payload).data();

      print('Login Response: $response');

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
            // Extract and store auth token and user ID if available
            String? authToken;
            int? userId;
            String? userName;
            String? userEmail;

            if (responseBody is Map) {
              // Extract token
              if (responseBody.containsKey('token')) {
                authToken = responseBody['token'].toString();
              } else if (responseBody.containsKey('accessToken')) {
                authToken = responseBody['accessToken'].toString();
              } else if (responseBody.containsKey('authToken')) {
                authToken = responseBody['authToken'].toString();
              } else if (responseBody.containsKey('data')) {
                var data = responseBody['data'];
                if (data is Map) {
                  if (data.containsKey('token')) {
                    authToken = data['token'].toString();
                  } else if (data.containsKey('accessToken')) {
                    authToken = data['accessToken'].toString();
                  }
                }
              }

              // Extract user data - check if user object exists or if data is directly in response
              Map<String, dynamic>? userData;
              if (responseBody.containsKey('user')) {
                userData = responseBody['user'] as Map<String, dynamic>?;
              } else if (responseBody.containsKey('id') ||
                  responseBody.containsKey('name')) {
                // User data is directly in responseBody
                userData = responseBody as Map<String, dynamic>;
              }

              if (userData != null) {
                // Extract user ID
                if (userData.containsKey('id')) {
                  userId = userData['id'] is int
                      ? userData['id'] as int
                      : int.tryParse(userData['id'].toString());
                }
                // Extract user name
                if (userData.containsKey('name')) {
                  userName = userData['name'].toString();
                }
                // Extract user email
                if (userData.containsKey('email')) {
                  userEmail = userData['email'].toString();
                }
              }
            }

            // Store the auth token and user data
            if (authToken != null && authToken.isNotEmpty) {
              await MyApp.setAuthToken(
                authToken,
                userId: userId,
                userName: userName,
                userEmail: userEmail,
              );
              print('Auth token stored: $authToken');
              if (userId != null) {
                print('User ID stored: $userId');
              }
              if (userName != null) {
                print('User name stored: $userName');
              }
              if (userEmail != null) {
                print('User email stored: $userEmail');
              }

              // Clear entire navigation stack - AuthWrapper StreamBuilder will show MainNavigation
              // Navigate to MainNavigation directly and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) =>
                    false, // Remove all previous routes including WelcomeScreen
              );

              // Show success message after a brief delay to ensure navigation completes
              if (mounted) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  // Use root navigator to show snackbar on MainNavigation
                  final rootContext = Navigator.of(
                    context,
                    rootNavigator: true,
                  ).context;
                  if (rootContext.mounted) {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sign in successful!',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(16),
                        duration: Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    );
                  }
                });
              }
            }
          } else {
            // Error - extract and display user-friendly message
            String errorMessage =
                'Invalid email or password. Please try again.';

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
                  'SIGN-IN',
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
                  'Welcome Back To The App',
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                // Email Field
                const Text(
                  'Email Id',
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
                    hintText: 'Enter your mail id',
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
                const SizedBox(height: 24),
                // Password Field
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your Password here',
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
                        color: Color(0xFF1E3A8A),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Remember Me and Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Row(
                    //   children: [
                    //     Checkbox(
                    //       value: _rememberMe,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _rememberMe = value ?? false;
                    //         });
                    //       },
                    //       activeColor: const Color(0xFF1E3A8A),
                    //     ),
                    //     const Text(
                    //       'remember me',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         color: Color(0xFF666666),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Sign In Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? AppTheme.primaryBlue.withOpacity(0.7)
                        : AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(35),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(35),
                      onTap: _isLoading ? null : _handleSignIn,
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
                                'SIGN IN',
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

              ],
            ),
          ),
        ),
      ),
    );
  }
}
