import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Blue Theme
  static const Color primaryBlue = Color(0xFF002E6E); // Main blue
  static const Color primaryBlueDark = Color(
    0xFF002E6E,
  ); // Darker blue for headers
  static const Color lightBlue = Color(0xFF00B9F1);
  static const Color lightBlueAccent = Color(
    0xFFDBEAFE,
  ); // Light blue for cards/buttons
  static const Color backgroundColor = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF8F9FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFFA2A2A2);
  static const Color textHint = Color(0xFFA2A2A2);
  static const Color textWhite = Colors.white;

  // UI Colors
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color inputFillColor = Color(0xFFF9FAFB);
  static const Color cardBackground = Colors.white;
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color shadowColor = Color(0xFF1A1A1A);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  // Navigation Colors
  static const Color navSelected = primaryBlue;
  static const Color navUnselected = Color(0xFFA2A2A2);

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
    minimumSize: const Size(double.infinity, 56),
  );

  // Input Decoration
  static InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: textHint),
      filled: true,
      fillColor: inputFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
