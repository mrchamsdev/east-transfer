import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GoldBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const GoldBackButton({
    super.key,
    this.onPressed,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
            onTap: onPressed ?? () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(18),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}
