import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const DogneDogamApp());
}

class DogneDogamApp extends StatelessWidget {
  const DogneDogamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '동네도감',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'Pretendard',
      ),
      home: const HomeScreen(),
    );
  }
}
