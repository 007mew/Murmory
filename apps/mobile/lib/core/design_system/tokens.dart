import 'package:flutter/material.dart';

class MurmoryColors {
  MurmoryColors._();

  // Primary Aesthetic Colors (from UI Reference)
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF60A5FA);

  // Background & Surfaces
  static const Color background = Color(0xFFF6F8FB);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEEF2F6);
  static const Color softGrey = Color(0xFFF1F5F9);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Dark Floating Capsule Dock
  static const Color dockBackground = Color(0xFF111827);

  // Pastel & Accent Badges for AI Assist & Tags
  static const Color pastelGreen = Color(0xFFECFDF5);
  static const Color iconGreen = Color(0xFF10B981);

  static const Color pastelPurple = Color(0xFFF5F3FF);
  static const Color iconPurple = Color(0xFF8B5CF6);

  static const Color pastelCoral = Color(0xFFFEF2F2);
  static const Color iconCoral = Color(0xFFEF4444);

  static const Color pastelPink = Color(0xFFFDF2F8);
  static const Color iconPink = Color(0xFFEC4899);

  static const Color pastelBlue = Color(0xFFEFF6FF);

  // Backward compatibility aliases
  static const Color accent = primaryBlue;
  static const Color accentLight = primaryBlueLight;
  static const Color accentDark = primaryBlueDark;
  static const Color surface = cardSurface;
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundLight = background;
  static const Color error = iconCoral;
  static const Color success = iconGreen;
  static const Color warning = Color(0xFFF59E0B);
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color recordRed = iconCoral;
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> cardShadow = softShadow;

  static const List<BoxShadow> dockShadow = [
    BoxShadow(
      color: Color(0x2E000000),
      blurRadius: 24,
      spreadRadius: -2,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> blueGlow = [
    BoxShadow(
      color: Color(0x403B82F6),
      blurRadius: 18,
      spreadRadius: 2,
      offset: Offset(0, 6),
    ),
  ];
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
  static const double lg = 18.0;
  static const double xl = 22.0;
  static const double full = 999.0;
}

class MurmoryDuration {
  MurmoryDuration._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
}
