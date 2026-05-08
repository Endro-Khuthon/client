import 'package:flutter/material.dart';

class AppColors {
  // warm 팔레트 (기본)
  static const bg         = Color(0xFFFBF7ED);
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF4EEDD);
  static const ink        = Color(0xFF1F1B16);
  static const inkSub     = Color(0xFF65594A);
  static const inkMute    = Color(0xFFA89C88);
  static const line       = Color(0xFFEBE3CE);
  static const accent     = Color(0xFFC9402F);
  static const gold       = Color(0xFFD6B266);

  // 카테고리 색상
  static const catColors = <String, Color>{
    '역사':    Color(0xFF7E2A22),
    '건축':    Color(0xFF365E78),
    '인물':    Color(0xFF5A4A8E),
    '전통문화': Color(0xFFB5392E),
    '생활문화': Color(0xFFC4A05A),
    '산업문화': Color(0xFF3F6B4A),
  };

  static const catGlyphs = <String, String>{
    '역사':    '史',
    '건축':    '築',
    '인물':    '人',
    '전통문화': '傳',
    '생활문화': '活',
    '산업문화': '業',
  };

  static Color forCategory(String cat) => catColors[cat] ?? accent;
  static String glyphForCategory(String cat) => catGlyphs[cat] ?? '?';
}
