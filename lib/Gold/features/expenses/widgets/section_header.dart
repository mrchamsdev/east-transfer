import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingText,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.h2.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          if (trailingText != null)
            Text(
              trailingText!,
              style: AppTextStyles.amount.copyWith(
                fontSize: 14,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
