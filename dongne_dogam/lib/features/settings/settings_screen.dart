import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                '설정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  '준비 중입니다.',
                  style: TextStyle(fontSize: 14, color: AppColors.inkMute),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
