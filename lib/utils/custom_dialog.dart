import 'package:flutter/material.dart';
import 'app_theme.dart';

enum DialogType { error, success, info, warning }

class CustomDialog extends StatelessWidget {
  final String message;
  final DialogType type;
  final String? title;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    required this.message,
    this.type = DialogType.error,
    this.title,
    this.buttonText,
    this.onButtonPressed,
    this.barrierDismissible = true,
  });

  static void show({
    required BuildContext context,
    required String message,
    DialogType type = DialogType.error,
    String? title,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return CustomDialog(
          message: message,
          type: type,
          title: title,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
          barrierDismissible: barrierDismissible,
        );
      },
    );
  }

  Color get _iconColor {
    switch (type) {
      case DialogType.error:
        return const Color(0xFFFF3B30);
      case DialogType.success:
        return const Color(0xFF10B981);
      case DialogType.warning:
        return const Color(0xFFF59E0B);
      case DialogType.info:
        return AppTheme.primaryBlue;
    }
  }

  IconData get _icon {
    switch (type) {
      case DialogType.error:
        return Icons.error_outline_rounded;
      case DialogType.success:
        return Icons.check_circle_rounded;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_outline_rounded;
    }
  }

  String get _defaultTitle {
    switch (type) {
      case DialogType.error:
        return 'Error!';
      case DialogType.success:
        return 'Success!';
      case DialogType.warning:
        return 'Warning!';
      case DialogType.info:
        return 'Information';
    }
  }

  String get _defaultButtonText {
    return 'Got it';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          // Clamp the value to ensure it's between 0.0 and 1.0
          final clampedValue = value.clamp(0.0, 1.0);
          return Transform.scale(
            scale: clampedValue,
            child: Opacity(
              opacity: clampedValue,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: _iconColor.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: -5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top section with animated icon
                    _buildIconSection(),
                    // Title
                    _buildTitle(context),
                    // Content section
                    _buildContent(context),
                    // Button section
                    _buildButton(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconSection() {
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated background circle with gradient
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, animValue, child) {
              final clampedAnim = animValue.clamp(0.0, 1.0);
              return Container(
                width: 80 + (clampedAnim * 20),
                height: 80 + (clampedAnim * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _iconColor.withOpacity(0.15),
                      _iconColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          // Icon container with gradient border
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _iconColor,
                  _iconColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _iconColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _icon,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - clampedValue)),
            child: Text(
              title ?? _defaultTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          final clampedValue = value.clamp(0.0, 1.0);
          return Opacity(
            opacity: clampedValue,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - clampedValue)),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  color: AppTheme.textSecondary.withOpacity(0.9),
                  height: 1.6,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          final clampedValue = value.clamp(0.0, 1.0);
          return Opacity(
            opacity: clampedValue,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - clampedValue)),
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.primaryBlue.withOpacity(0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onButtonPressed ?? () => Navigator.of(context).pop(),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: Colors.white.withOpacity(0.1),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        buttonText ?? _defaultButtonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

