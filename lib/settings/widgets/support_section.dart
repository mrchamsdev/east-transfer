import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'support_item.dart';

class SupportSection extends StatelessWidget {
  final VoidCallback? onContactUs;
  final VoidCallback? onAboutUs;

  const SupportSection({super.key, this.onContactUs, this.onAboutUs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUPPORT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SupportItem(
                iconPath: 'assets/images/user_contact.svg',
                label: 'Contact Us',
                onTap: onContactUs ?? () {},
              ),
              const Divider(height: 1),
              SupportItem(
                iconPath: 'assets/images/user_about.svg',
                label: 'About Us',
                onTap: onAboutUs ?? () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
