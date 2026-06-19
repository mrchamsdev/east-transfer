import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'profile_detail_item.dart';
import '../edit_profile_screen.dart';

class ProfileDetailsSection extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onProfileUpdated;

  const ProfileDetailsSection({
    super.key,
    required this.userData,
    this.onProfileUpdated,
  });

  String _getValue(String key) {
    final value = userData[key];
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'PROFILE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userData: userData),
                  ),
                ).then((result) {
                  // Refresh profile if update was successful
                  if (result == true && onProfileUpdated != null) {
                    onProfileUpdated!();
                  }
                });
              },

              label: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                backgroundColor: AppTheme.lightBlue.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  // side: BorderSide(
                  //   color: AppTheme.lightBlue.withOpacity(0.3),
                  //   width: 1,
                  // ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.cardBackground),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileDetailItem(
                iconPath: 'assets/images/user_name.svg',
                label: 'Full Name',
                value: _getValue('name'),
              ),
              Divider(
                height: 32,
                color: AppTheme.dividerColor.withOpacity(0.5),
              ),
              ProfileDetailItem(
                iconPath: 'assets/images/user_email.svg',
                label: 'Email Address',
                value: _getValue('email'),
              ),
              Divider(
                height: 32,
                color: AppTheme.dividerColor.withOpacity(0.5),
              ),
              ProfileDetailItem(
                iconPath: 'assets/images/user_phone.svg',
                label: 'Phone Number',
                value: _getValue('phoneNumber'),
              ),
              Divider(
                height: 32,
                color: AppTheme.dividerColor.withOpacity(0.5),
              ),
              ProfileDetailItem(
                iconPath: 'assets/images/user_company.svg',
                label: 'Company Name',
                value: _getValue('companyName'),
              ),
              Divider(
                height: 32,
                color: AppTheme.dividerColor.withOpacity(0.5),
              ),

              ProfileDetailItem(
                iconPath: 'assets/images/user_pan_card.svg',
                label: 'PAN Number',
                value: _getValue('pan'),
              ),
              Divider(
                height: 32,
                color: AppTheme.dividerColor.withOpacity(0.5),
              ),
              ProfileDetailItem(
                iconPath: 'assets/images/user_gst_num.svg',
                label: 'GST Number',
                value: _getValue('gstNo'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
