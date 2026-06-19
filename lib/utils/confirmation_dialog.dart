import 'package:flutter/material.dart';
import 'app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String yesText;
  final String noText;
  final VoidCallback? onYesPressed;
  final VoidCallback? onNoPressed;
  final bool barrierDismissible;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.yesText = 'Yes',
    this.noText = 'No',
    this.onYesPressed,
    this.onNoPressed,
    this.barrierDismissible = true,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String yesText = 'Yes',
    String noText = 'No',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          yesText: yesText,
          noText: noText,
          barrierDismissible: barrierDismissible,
          onYesPressed: () => Navigator.of(context).pop(true),
          onNoPressed: () => Navigator.of(context).pop(false),
        );
      },
    );
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
          final clampedValue = value.clamp(0.0, 1.0);
          return Transform.scale(
            scale: clampedValue,
            child: Opacity(
              opacity: clampedValue,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
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
                      color: AppTheme.errorColor.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: -5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Section
                    _buildIconSection(),
                    // Title
                    _buildTitle(),
                    // Message
                    _buildMessage(),
                    // Buttons
                    _buildButtons(context),
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
          // Animated background circle
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
                      AppTheme.errorColor.withOpacity(0.15),
                      AppTheme.errorColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          // Icon container
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.errorColor,
                  AppTheme.errorColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
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
              title,
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

  Widget _buildMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
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

  Widget _buildButtons(BuildContext context) {
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
              child: Row(
                children: [
                  // No Button
                  Expanded(
                    child: _buildButton(
                      text: noText,
                      onPressed: onNoPressed ?? () => Navigator.of(context).pop(false),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Yes Button
                  Expanded(
                    child: _buildButton(
                      text: yesText,
                      onPressed: onYesPressed ?? () => Navigator.of(context).pop(true),
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.errorColor,
                  AppTheme.errorColor.withOpacity(0.9),
                ],
              )
            : null,
        color: isPrimary ? null : Colors.transparent,
        border: isPrimary
            ? null
            : Border.all(
                color: AppTheme.borderColor,
                width: 1.5,
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.errorColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          splashColor: isPrimary
              ? Colors.white.withOpacity(0.2)
              : AppTheme.primaryBlue.withOpacity(0.1),
          highlightColor: isPrimary
              ? Colors.white.withOpacity(0.1)
              : AppTheme.primaryBlue.withOpacity(0.05),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isPrimary ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

