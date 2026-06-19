import 'package:flutter/material.dart';
import 'package:bank_scan/myapp.dart';
import '../../../utils/app_theme.dart';
import 'animated_money_icon.dart';

class WelcomeHeader extends StatelessWidget {
  final String? userName;

  const WelcomeHeader({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF002E6E), Color(0xFF2A66B9)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // LEFT SIDE TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Welcome Back..!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((userName != null && userName!.isNotEmpty) ||
                    (MyApp.userName != null && MyApp.userName!.isNotEmpty)) ...[
                  const SizedBox(height: 4),
                  Text(
                    userName ?? MyApp.userName ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // RIGHT SIDE ANIMATED MONEY ICON - Bottom aligned
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: AnimatedMoneyIcon(size: 38, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}
