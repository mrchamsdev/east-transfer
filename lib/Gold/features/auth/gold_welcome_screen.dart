import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/features/auth/screens/sign_in_screen.dart';
import 'package:bank_scan/Gold/features/auth/repository/auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/repository/face_auth_repository.dart';
import 'package:bank_scan/Gold/features/auth/models/auth_models.dart';
import 'package:bank_scan/Gold/features/main/main_navigation_screen.dart';

class GoldWelcomeScreen extends StatefulWidget {
  const GoldWelcomeScreen({super.key});

  @override
  State<GoldWelcomeScreen> createState() => _GoldWelcomeScreenState();
}

class _GoldWelcomeScreenState extends State<GoldWelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _imageCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _dotsCtrl;
  late final AnimationController _btnCtrl;

  late final Animation<double> _imageFade;
  late final Animation<Offset> _imageSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _descFade;
  late final Animation<Offset> _descSlide;
  late final Animation<double> _dotsFade;
  late final Animation<double> _dotsScale;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  // Biometric auto-login
  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  bool _isFaceIdEnabled = false;
  bool _isBioLoading = false;

  @override
  void initState() {
    super.initState();

    _imageCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _dotsCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _btnCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _imageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _imageCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _imageSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _imageCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _descFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _descSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );

    _dotsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _dotsScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _btnCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _btnCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _imageCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _textCtrl.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 400),
      () => _dotsCtrl.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 600),
      () => _btnCtrl.forward(),
    );

    // After animations settle, check if Face ID was previously enabled.
    // If so, auto-trigger biometric login so user doesn't need to type credentials.
    Future.delayed(const Duration(milliseconds: 800), _checkAndAutoLogin);
  }


  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Checks if the user previously enabled Face ID.
  /// If so, silently prompts biometric authentication and logs in.
  Future<void> _checkAndAutoLogin() async {
    try {
      final isEnabled = await _secureStorage.read(key: 'isFaceEnabled');
      if (isEnabled == 'false') return;

      final email = await _secureStorage.read(key: 'email');
      final deviceId = await _secureStorage.read(key: 'biometricDeviceId');
      if (email == null || deviceId == null) return;

      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return;

      if (mounted) setState(() => _isFaceIdEnabled = true);
    } catch (_) {}
  }

  Future<void> _handleBiometricLogin() async {
    if (_isBioLoading) return;
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to sign in',
      );
      if (!didAuth) return;

      final email = await _secureStorage.read(key: 'email');
      final deviceId = await _secureStorage.read(key: 'biometricDeviceId');

      if (email == null || deviceId == null) {
        _showError('Credentials not found. Please sign in with password first.');
        return;
      }

      if (mounted) setState(() => _isBioLoading = true);
      final res = await FaceAuthRepository.instance.faceLogin(email, deviceId);
      if (mounted) setState(() => _isBioLoading = false);

      if (res.isSuccess && res.data != null) {
        final loginRes = LoginResponse.fromJson(res.data!);
        if (loginRes.accountStatus?.toLowerCase() == 'deactivated' ||
            loginRes.accountStatus?.toLowerCase() == 'inactive') {
          _showError('Your account is deactivated. Contact admin.');
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
          return;
        }
      }
      _showError(res.message ?? 'Biometric login failed. Please sign in manually.');
    } catch (e) {
      if (mounted) setState(() => _isBioLoading = false);
      _showError('Biometric authentication failed.');
    }
  }

  @override
  void dispose() {
    _imageCtrl.dispose();
    _textCtrl.dispose();
    _dotsCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final hPad = isTablet ? 48.0 : (size.width < 360 ? 16.0 : 24.0);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            // Proportional spacing — never overflows
            final imgFlex = h < 600 ? 2 : 3;
            final contentFlex = h < 600 ? 3 : 2;
            final gap1 = h * 0.012; // title → desc
            final gap2 = h * 0.020; // desc → dots
            final gap3 = h * 0.025; // dots → button
            final btnH = h < 600 ? 48.0 : 56.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                children: [
                  // ── Illustration ───────────────────────────────────
                  Expanded(
                    flex: imgFlex,
                    child: FadeTransition(
                      opacity: _imageFade,
                      child: SlideTransition(
                        position: _imageSlide,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/welcome.svg',
                            fit: BoxFit.contain,
                            placeholderBuilder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Content ────────────────────────────────────────
                  Expanded(
                    flex: contentFlex,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        FadeTransition(
                          opacity: _titleFade,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: Text(
                              'Welcome To the App',
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: isTablet ? 34 : (h < 600 ? 22 : 26),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: gap1),

                        // Description
                        FadeTransition(
                          opacity: _descFade,
                          child: SlideTransition(
                            position: _descSlide,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 32.0 : 8.0,
                              ),
                              child: Text(
                                "We're excited to help you pay and manage "
                                'your service amount with ease.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                  fontSize: h < 600 ? 13 : 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: gap2),

                        // Page dots
                        FadeTransition(
                          opacity: _dotsFade,
                          child: ScaleTransition(
                            scale: _dotsScale,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _dot(active: true),
                                const SizedBox(width: 8),
                                _dot(active: false),
                                const SizedBox(width: 8),
                                _dot(active: false),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: gap3),

                        // Sign-In button
                        FadeTransition(
                          opacity: _btnFade,
                          child: SlideTransition(
                            position: _btnSlide,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: btnH,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      elevation: 4,
                                      shadowColor:
                                          AppColors.primaryBlue.withValues(alpha: 0.3),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const GoldSignInScreen(),
                                      ),
                                    ),
                                    child: Text(
                                      'SIGN IN',
                                      style: AppTextStyles.buttonText,
                                    ),
                                  ),
                                ),
                                // Biometric login button (visible only if Face ID is enabled)
                                /*if (_isFaceIdEnabled) ...[
                                  SizedBox(height: h * 0.015),
                                  SizedBox(
                                    width: double.infinity,
                                    height: btnH,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryBlue,
                                        side: const BorderSide(
                                          color: AppColors.primaryBlue,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(35),
                                        ),
                                      ),
                                      icon: _isBioLoading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primaryBlue,
                                              ),
                                            )
                                          : const Icon(Icons.fingerprint, size: 22),
                                      label: Text(
                                        'Login with Face ID',
                                        style: AppTextStyles.buttonText.copyWith(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: _isBioLoading ? null : _handleBiometricLogin,
                                    ),
                                  ),
                                ],*/
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _dot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
