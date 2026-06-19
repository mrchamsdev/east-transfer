import 'package:bank_scan/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/bank_loader.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _dotsAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _imageFadeAnimation;
  late Animation<Offset> _imageSlideAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late Animation<double> _descriptionFadeAnimation;
  late Animation<Offset> _descriptionSlideAnimation;

  late Animation<double> _dotsFadeAnimation;
  late Animation<double> _dotsScaleAnimation;

  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Image animation - slides from top
    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _imageFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _imageSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _imageAnimationController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          ),
        );

    // Text animations - title and description
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textAnimationController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          ),
        );

    _descriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _descriptionSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textAnimationController,
            curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
          ),
        );

    // Dots animation - fade and scale
    _dotsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _dotsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotsAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _dotsScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotsAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Button animation - slides from bottom
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonAnimationController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          ),
        );

    // Start animations sequentially
    _imageAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _textAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _dotsAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _buttonAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    _textAnimationController.dispose();
    _dotsAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  // Responsive helper methods
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final isSmallPhone = screenWidth < 360;

    if (isTablet) {
      return baseSize * 1.3;
    } else if (isSmallPhone) {
      return baseSize * 0.9;
    }
    return baseSize;
  }

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isLargeScreen = screenHeight > 900;

    if (isSmallScreen) {
      return baseSpacing * 0.7;
    } else if (isLargeScreen) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }

  double _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isSmallPhone = screenWidth < 360;

    if (isTablet) {
      return 48.0;
    } else if (isSmallPhone) {
      return 16.0;
    }
    return 24.0;
  }

  int _getIllustrationFlex(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isLargeScreen = screenHeight > 900;

    if (isSmallScreen) {
      return 2;
    } else if (isLargeScreen) {
      return 4;
    }
    return 3;
  }

  int _getContentFlex(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isLargeScreen = screenHeight > 900;

    if (isSmallScreen) {
      return 3;
    } else if (isLargeScreen) {
      return 2;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final isLandscape = screenWidth > screenHeight;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsivePadding(context),
        ),
        child: Column(
          children: [
            // Illustration Section
            Expanded(
              flex: isSmallScreen ? 2 : (isLandscape && !isTablet ? 2 : 3),
              child: FadeTransition(
                opacity: _imageFadeAnimation,
                child: SlideTransition(
                  position: _imageSlideAnimation,
                  child: Center(child: _buildIllustration(context)),
                ),
              ),
            ),
            // Content Section
            Expanded(
              flex: isSmallScreen ? 3 : (isLandscape && !isTablet ? 3 : 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with animation
                  FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: SlideTransition(
                      position: _titleSlideAnimation,
                      child: Text(
                        'Welcome To the App',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 28),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  // Description with animation
                  FadeTransition(
                    opacity: _descriptionFadeAnimation,
                    child: SlideTransition(
                      position: _descriptionSlideAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32.0 : 8.0,
                        ),
                        child: Text(
                          "We're excited to help you pay and manage your service amount with ease.",
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 15),
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  // Navigation Dots with animation
                  FadeTransition(
                    opacity: _dotsFadeAnimation,
                    child: ScaleTransition(
                      scale: _dotsScaleAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(context, true),
                          SizedBox(width: 8),
                          _buildDot(context, false),
                          SizedBox(width: 8),
                          _buildDot(context, false),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 32),
                  // Sign In Button with animation
                  FadeTransition(
                    opacity: _buttonFadeAnimation,
                    child: SlideTransition(
                      position: _buttonSlideAnimation,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 500 : double.infinity,
                        ),
                        height: isSmallScreen ? 50 : 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(35),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(35),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(
                                'SIGN-IN',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  // Create Account Link with animation
                  FadeTransition(
                    opacity: _buttonFadeAnimation,
                    child: SlideTransition(
                      position: _buttonSlideAnimation,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                        ),
                        child: Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 14),
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final isSmallScreen = screenHeight < 700;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
      child: SvgPicture.asset(
        'assets/images/welcome.svg',
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Container(
          padding: const EdgeInsets.all(50),
          child: const RefreshLoader(color: AppTheme.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, bool isActive) {
    final dotSize = _getResponsiveSpacing(context, 8);
    final activeWidth = _getResponsiveSpacing(context, 24);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? activeWidth : dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E3A8A) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
    );
  }
}
