import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.lightBlueAccent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
}

