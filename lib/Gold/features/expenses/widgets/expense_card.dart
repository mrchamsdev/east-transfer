import 'package:bank_scan/Gold/core/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';
import '../models/expense_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onReturnFromDetails;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onReturnFromDetails,
  });

  String get _day {
    try {
      final dt = DateTime.parse(expense.expenseDate);
      return dt.day.toString();
    } catch (_) {
      return '';
    }
  }

  String get _month {
    try {
      final dt = DateTime.parse(expense.expenseDate);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return months[dt.month - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate a unique avatar color from the category name or fallback to a default theme color
    final int categoryHash =
        (expense.expenseCategory?.name ?? 'General').hashCode;
    final Color iconColor = AppColors.primaryBlue;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.expenseDetails,
          arguments: expense,
        );
        if (result == true && onReturnFromDetails != null) {
          onReturnFromDetails!();
        }
      },
      child: Container(
        // margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),

        child: Row(
          children: [
            // Date Card with nice background
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _month.toUpperCase(),
                    style: AppTextStyles.infoText.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _day,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Category Icon Container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                    expense.expenseCategory?.icon != null &&
                        expense.expenseCategory!.icon!.isNotEmpty
                    ? expense.expenseCategory!.icon!.toLowerCase().endsWith(
                            '.svg',
                          )
                          ? SvgPicture.network(
                              expense.expenseCategory!.icon!.replaceAll(
                                ' ',
                                '%20',
                              ),
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).primaryColor,
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder: (context) => const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),
                            )
                          : Image.network(
                              expense.expenseCategory!.icon!.replaceAll(
                                ' ',
                                '%20',
                              ),  
                              width: 18,
                              height: 18,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    _getCategoryIcon(
                                      expense.expenseCategory?.name, 
                                    ),
                                    color: iconColor,
                                    size: 16,
                                  ),
                            )
                    : Icon(
                        _getCategoryIcon(expense.expenseCategory?.name),
                        color: iconColor,
                        size: 16,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Title & Description/Comment
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,

                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                    
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                 
                  const SizedBox(height: 3),
                   Text(
                    expense.expenseCategory?.name ?? 'General',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: AppTextStyles.amount.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? name) {
    if (name == null) return Icons.shopping_bag_outlined;
    final lower = name.toLowerCase();
    if (lower.contains('food') ||
        lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('restaurant')) {
      return Icons.restaurant;
    }
    if (lower.contains('travel') ||
        lower.contains('cab') ||
        lower.contains('taxi') ||
        lower.contains('transport')) {
      return Icons.local_taxi;
    }
    if (lower.contains('rent') ||
        lower.contains('office') ||
        lower.contains('house')) {
      return Icons.home_work_outlined;
    }
    if (lower.contains('utility') ||
        lower.contains('electricity') ||
        lower.contains('water') ||
        lower.contains('bill')) {
      return Icons.electrical_services;
    }
    if (lower.contains('shopping') ||
        lower.contains('grocer') ||
        lower.contains('supermarket')) {
      return Icons.shopping_cart_outlined;
    }
    return Icons.payments_outlined;
  }
}
