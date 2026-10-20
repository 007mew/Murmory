import 'package:flutter/material.dart';

class MurmoryColors {
  MurmoryColors._();
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF9C94FF);
  static const Color accentDark = Color(0xFF4A42DD);
  static const Color surface = Color(0xFFF8F8FC);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color backgroundLight = Color(0xFFF2F2FA);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B6B8D);
  static const Color textPrimaryDark = Color(0xFFF0F0FF);
  static const Color textSecondaryDark = Color(0xFFA0A0C0);
  static const Color recordRed = Color(0xFFE53935);
  static const Color dividerLight = Color(0xFFE0E0F0);
  static const Color dividerDark = Color(0xFF2A2A3E);
}

class MurmorySpacing {
  MurmorySpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class MurmoryRadius {
  MurmoryRadius._();
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}

class MurmoryDuration {
  MurmoryDuration._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
}
