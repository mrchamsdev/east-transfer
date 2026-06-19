import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HistoryItem extends StatelessWidget {
  final String status;
  final String subtext;

  const HistoryItem({
    super.key,
    required this.status,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history, color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: AppTextStyles.historyStatus,
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: AppTextStyles.historySubtext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
