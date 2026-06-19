import 'package:bank_scan/Gold/core/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/gold_purchase_model.dart';

class GoldRecordCard extends StatelessWidget {
  final GoldPurchase purchase;
  final VoidCallback? onSell;

  const GoldRecordCard({
    super.key,
    required this.purchase,
    this.onSell,
  });

  String _formatIndianCurrency(double amount) {
    String str = amount.toStringAsFixed(0);
    if (str.length <= 3) return str;
    String lastThree = str.substring(str.length - 3);
    String other = str.substring(0, str.length - 3);
    String result = '';
    int count = 0;
    for (int i = other.length - 1; i >= 0; i--) {
      result = other[i] + result;
      count++;
      if (count == 2 && i != 0) {
        result = ',$result';
        count = 0;
      }
    }
    return '$result,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    final status = (purchase.status ?? 'PURCHASE').toUpperCase();
    final isPurchase = status == 'PURCHASE';
    final isSale = status == 'SALE';

    final name = '${purchase.partyName} (${purchase.dlNumber})';
    final details = 'GW - ${purchase.totalGrossWeight?.toStringAsFixed(2) ?? '0.00'}, PW - ${purchase.totalPureWeight?.toStringAsFixed(2) ?? '0.00'}';

    // Amount to display on the right: if sale, show saleAmount; otherwise show grandTotal
    final displayAmount = isSale
        ? '₹ ${_formatIndianCurrency(purchase.saleAmount ?? 0.0)}'
        : '₹ ${_formatIndianCurrency(purchase.grandTotal ?? 0.0)}';

    // Determine profit/loss label and color
    String plLabel = 'Pending';
    Color plColor = AppColors.textSecondary.withValues(alpha: 0.6);
    if (isSale) {
      final plStatus = purchase.profitLossStatus?.toUpperCase() ?? 'PENDING';
      if (plStatus == 'PROFIT') {
        plLabel = 'Profit: ₹${_formatIndianCurrency(purchase.profitLossAmount ?? 0.0)}';
        plColor = const Color(0xFF10B981); // Green
      } else if (plStatus == 'LOSS') {
        plLabel = 'Loss: ₹${_formatIndianCurrency(purchase.profitLossAmount ?? 0.0)}';
        plColor = Colors.red;
      } else {
        plLabel = 'Pending';
      }
    } else {
      plLabel = 'Purchase';
      plColor = AppColors.textSecondary.withValues(alpha: 0.6);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // ── Status Badge (P / S) ─────────────────────────────────────────
          _StatusBadge(status: status),
          const SizedBox(width: 16),

          // ── Middle Info ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // ── Right Section ────────────────────────────────────────────────
          if (isPurchase)
            SizedBox(
              width: 70,
              height: 30,
              child: ElevatedButton(
                onPressed: onSell,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Sale',
                  style: AppTextStyles.label.copyWith(color: AppColors.white),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayAmount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: plColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Status Badge Widget ───────────────────────────────────────────────────────

/// Displays "P" for PURCHASE (navy) and "S" for SALE (amber).
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSale = status.toUpperCase() == 'SALE';

    final bgColor   = isSale ? const Color(0xFFFFF3E0) : const Color(0xFFE8EEF7);
    final textColor = isSale ? const Color(0xFFE65100) : AppColors.primaryBlue;
    final label     = isSale ? 'S' : 'P';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
