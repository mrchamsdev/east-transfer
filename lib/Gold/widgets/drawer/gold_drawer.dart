import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_routes.dart';
import '../../core/network/gold_session.dart';

class GoldDrawer extends StatelessWidget {
  const GoldDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Close Button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SectionHeader(title: 'App Settings', hasBackground: true),
                  _DrawerItem(icon: Icons.favorite_border, title: 'Favourites', onTap: () {}),
                  _DrawerItem(icon: Icons.language, title: 'Language', onTap: () {}),
                  _DrawerItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
                  
                  _SectionHeader(title: 'Security'),
                  _DrawerItem(
                    icon: Icons.face_unlock_outlined,
                    title: 'Face Id',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      AppRoutes.push(context, AppRoutes.faceId);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      AppRoutes.push(context, AppRoutes.changePassword);
                    },
                  ),
                 
                  
                  if (GoldSession.instance.canRead('Users') ||
                      GoldSession.instance.canRead('Category') ||
                      GoldSession.instance.canRead('Customer')) ...[
                    _SectionHeader(title: 'Profile'),
                    if (GoldSession.instance.canRead('Users'))
                      _DrawerItem(icon: Icons.person_outline, title: 'User access', onTap: () => Navigator.pushNamed(context, AppRoutes.users)),
                    if (GoldSession.instance.canRead('Category'))
                      _DrawerItem(icon: Icons.category_outlined, title: 'Category', onTap: () => Navigator.pushNamed(context, AppRoutes.categoryManagement)),
                    if (GoldSession.instance.canRead('Customer'))
                      _DrawerItem(
                        icon: Icons.groups_outlined,
                        title: 'Customer',
                        onTap: () {
                          Navigator.pop(context); // Close Drawer
                          Navigator.pushNamed(context, AppRoutes.customers);
                        },
                      ),
                  ],
                  
                  _SectionHeader(title: 'More Info & Support'),
                   _DrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      AppRoutes.push(context, AppRoutes.privacyPolicy);
                    },
                  ),
                  _DrawerItem(icon: Icons.description_outlined, title: 'Terms & Conditions', onTap: () {}),
                  _DrawerItem(icon: Icons.help_outline, title: 'Help', onTap: () {}),
                  _DrawerItem(icon: Icons.info_outline, title: 'About', onTap: () {}),
                  _DrawerItem(icon: Icons.delete_outline, title: 'Trash', onTap: () {}),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Only clear auth session — preserve biometric keys so
                    // the user can log back in with Face ID without re-enabling.
                    await GoldSession.instance.clear();
                    // Explicitly keep 'isFaceEnabled' and 'biometricDeviceId'
                    // in FlutterSecureStorage (they are not stored in GoldSession).
                    if (context.mounted) {
                      AppRoutes.pushAndClearStack(context, AppRoutes.welcome);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool hasBackground;

  const _SectionHeader({required this.title, this.hasBackground = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: hasBackground ? const Color(0xFFEEEEEE) : AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.modalIconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 16),
          ),
          title: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          minLeadingWidth: 0,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 0, endIndent: 0),
      ],
    );
  }
}
