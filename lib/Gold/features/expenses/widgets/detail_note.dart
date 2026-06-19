import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class DetailNote extends StatelessWidget {
  final String note;

  const DetailNote({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.appBarBackground,
              style: BorderStyle.solid,
            ),
          ),
          child: Text(
            note,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
