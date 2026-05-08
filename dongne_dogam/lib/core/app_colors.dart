import 'package:flutter/material.dart';

class AppColors {
  // cool gray 팔레트
  static const bg         = Color(0xFFF5F6F8);
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFECEEF2);
  static const ink        = Color(0xFF111318);
  static const inkSub     = Color(0xFF4A5060);
  static const inkMute    = Color(0xFF9399A8);
  static const line       = Color(0xFFE2E5EC);
  static const accent     = Color(0xFF3D6FFF);
  static const gold       = Color(0xFF3D6FFF);

  // 카테고리 색상
  static const catColors = <String, Color>{
    '역사':    Color(0xFFB33A3A),
    '건축':    Color(0xFF2F6FBF),
    '인물':    Color(0xFF6B4FBF),
    '전통문화': Color(0xFFD4542A),
    '예술문화': Color(0xFF2E9E7A),
    '자연문화': Color(0xFF3A8C3F),
  };

  static const catGlyphs = <String, String>{
    '역사':    '史',
    '건축':    '築',
    '인물':    '人',
    '전통문화': '傳',
    '예술문화': '藝',
    '자연문화': '然',
  };

  static Color forCategory(String cat) => catColors[cat] ?? accent;
  static String glyphForCategory(String cat) => catGlyphs[cat] ?? '?';
}
