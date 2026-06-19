import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onTap;

  const UserCard({super.key, required this.userData, required this.onTap});

  // --- First letter of customer name (uppercase) ---
  String get firstLetter {
    final rawName = userData['customerName'] as String? ?? '';
    if (rawName.isEmpty) return 'U';

    final name = rawName.trim();
    return name[0].toUpperCase();
  }

  // --- Format customerName (first letter uppercase, rest same) ---
  String get formattedName {
    final rawName = userData['customerName'] as String? ?? '';
    if (rawName.isEmpty) return '';

    final lower = rawName.toLowerCase().trim();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  // --- Account Number ---
  String get accountNumber {
    return userData['accountNumber'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 20 : 14,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Avatar with first letter ---
                Container(
                  width: isTablet ? 60 : 48,
                  height: isTablet ? 60 : 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlue.withOpacity(0.15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: isTablet ? 26 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),

                SizedBox(width: isTablet ? 20 : 16),

                // --- Customer info ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accountNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Icon(
                  Icons.arrow_forward_ios,
                  size: isTablet ? 20 : 16,
                  color: AppTheme.shadowColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
