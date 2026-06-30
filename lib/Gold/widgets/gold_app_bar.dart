import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';

class GoldAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showSearch;
  final bool showNotification;
  final bool showBackButton;
  final bool centerTitle;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final Function(String)? onSearchChanged;
  final VoidCallback? onBackPressed;
  final double? titleFontSize;
  final FontWeight? titleFontWeight; 

  const GoldAppBar({
    super.key,
    this.title,
  
    this.showSearch = true,
    this.showNotification = true,
    this.showBackButton = false,
    this.centerTitle = false,
    this.actions,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onSearchChanged,
    this.onBackPressed,
    this.titleFontSize,
    this.titleFontWeight,

  });



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.appBarBackground,
      ),
      child: Row(
        children: [
          // Circular Leading Button (Menu or Back)
          /*_buildCircularButton(
            icon: showBackButton ? Icons.arrow_back_ios_new : Icons.menu,
            
            onPressed: showBackButton 
              ? (onBackPressed ?? () => AppRoutes.pop(context))
              : (onMenuPressed ?? () => Scaffold.of(context).openDrawer()),
          ),
          */
          _buildCircularButton(
  icon: showBackButton ? Icons.arrow_back_ios_new : Icons.menu,
  size: showBackButton ? 16 : 20,
  onPressed: showBackButton 
    ? (onBackPressed ?? () => AppRoutes.pop(context))
    : (onMenuPressed ?? () => Scaffold.of(context).openDrawer()),
),
          
          const SizedBox(width: 12),
          // Search Bar or Title
          Expanded(
            child: showSearch 
              ? Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F5),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF727271), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: onSearchChanged,
                          autofocus: false,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            hintText: 'Search...',
                            hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                
                  alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
                  child: Text(
                    title ?? '', 
                    style:  TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500, 
                      color: AppColors.textPrimary
                    )
                  ),
                ),
          ),
          const SizedBox(width: 12),
          // Actions or Notification Button
          /*if (actions != null)
            Row(children: actions!)
          else if (showNotification)
            _buildCircularButton(
              icon: Icons.notifications_none_outlined,
              onPressed: onNotificationPressed,
            ),
            */
        ],
      ),
    );
  }

  /*Widget _buildCircularButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFF1F2F5)),
       
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
*/
Widget _buildCircularButton({
  required IconData icon,
  VoidCallback? onPressed,
  double size = 20,
}) {
  return Container(
    width: 35,
    height: 35,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.white,
      border: Border.all(color: const Color(0xFFF1F2F5)),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Icon(icon, color: AppColors.textPrimary, size: size),
      ),
    ),
  );
}

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
