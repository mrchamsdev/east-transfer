import 'package:flutter/material.dart';
import 'painters.dart';

class CornerBrackets extends StatelessWidget {
  const CornerBrackets({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left corner
        const Positioned(top: 12, left: 12, child: CornerBracket()),
        // Top-right corner
        Positioned(
          top: 12,
          right: 12,
          child: Transform.rotate(
            angle: 1.5708, // 90 degrees
            child: const CornerBracket(),
          ),
        ),
        // Bottom-right corner
        Positioned(
          bottom: 12,
          right: 12,
          child: Transform.rotate(
            angle: 3.14159, // 180 degrees
            child: const CornerBracket(),
          ),
        ),
        // Bottom-left corner
        Positioned(
          bottom: 12,
          left: 12,
          child: Transform.rotate(
            angle: 4.71239, // 270 degrees
            child: const CornerBracket(),
          ),
        ),
      ],
    );
  }
}

class CornerBracket extends StatelessWidget {
  const CornerBracket({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30),
      painter: CornerBracketPainter(),
    );
  }
}

