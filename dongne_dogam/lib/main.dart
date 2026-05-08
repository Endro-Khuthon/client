import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'core/app_colors.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterNaverMap().init(
    clientId: 'lgdhifazr2',
  );
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
