import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

/// Custom painter for corner brackets
class CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bracketLength = 12.0;
    final bracketWidth = 12.0;

    // Draw L-shaped bracket (top-left orientation)
    // Horizontal line
    canvas.drawLine(Offset(0, 0), Offset(bracketLength, 0), paint);
    // Vertical line
    canvas.drawLine(Offset(0, 0), Offset(0, bracketWidth), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom painter for scanner icon
class ScannerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final boxSize = 24.0;
    final lineLength = 8.0;
    final cornerLength = 6.0;

    // Draw two parallel horizontal lines in center
    canvas.drawLine(
      Offset(centerX - lineLength / 2, centerY - 3),
      Offset(centerX + lineLength / 2, centerY - 3),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - lineLength / 2, centerY + 3),
      Offset(centerX + lineLength / 2, centerY + 3),
      paint,
    );

    // Draw four L-shaped corner brackets forming a square
    final halfBox = boxSize / 2;

    // Top-left corner
    canvas.drawLine(
      Offset(centerX - halfBox, centerY - halfBox),
      Offset(centerX - halfBox + cornerLength, centerY - halfBox),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - halfBox, centerY - halfBox),
      Offset(centerX - halfBox, centerY - halfBox + cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(centerX + halfBox, centerY - halfBox),
      Offset(centerX + halfBox - cornerLength, centerY - halfBox),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + halfBox, centerY - halfBox),
      Offset(centerX + halfBox, centerY - halfBox + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(centerX - halfBox, centerY + halfBox),
      Offset(centerX - halfBox + cornerLength, centerY + halfBox),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - halfBox, centerY + halfBox),
      Offset(centerX - halfBox, centerY + halfBox - cornerLength),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(centerX + halfBox, centerY + halfBox),
      Offset(centerX + halfBox - cornerLength, centerY + halfBox),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + halfBox, centerY + halfBox),
      Offset(centerX + halfBox, centerY + halfBox - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

