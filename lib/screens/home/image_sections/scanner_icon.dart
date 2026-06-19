import 'package:flutter/material.dart';
import 'painters.dart';

class ScannerIcon extends StatelessWidget {
  const ScannerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: ScannerIconPainter(),
    );
  }
}

