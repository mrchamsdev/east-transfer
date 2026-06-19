import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/bank_loader.dart';
import 'corner_brackets.dart';
import 'scanner_icon.dart';

class ScanDocumentSection extends StatelessWidget {
  final XFile? selectedImage;
  final bool isProcessing;
  final VoidCallback onTap;

  const ScanDocumentSection({
    super.key,
    this.selectedImage,
    this.isProcessing = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan the Document',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // Corner brackets overlay
                        const CornerBrackets(),
                      ],
                    ),
                  )
                : isProcessing
                ? const Center(
                    child: RefreshLoader(
                      color: AppTheme.primaryBlue,
                    ),
                  )
                : Stack(
                    children: [
                      // Corner brackets in the four corners
                      const CornerBrackets(),
                      // Center scanner icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF002E6E), Color(0xFF2A66B9)],
                            ),
                          ),
                          child: const ScannerIcon(),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
