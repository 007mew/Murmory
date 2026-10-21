import 'package:flutter/material.dart';
import 'package:murmory/core/design_system/tokens.dart';

class MurmoryTheme {
  MurmoryTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: MurmoryColors.primaryBlue,
      brightness: Brightness.light,
      surface: MurmoryColors.cardSurface,
    );
    return _buildTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: MurmoryColors.background,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: MurmoryColors.accent,
      brightness: Brightness.dark,
      surface: MurmoryColors.surfaceDark,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? MurmoryColors.textPrimaryDark : MurmoryColors.textPrimaryLight,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: isDark ? MurmoryColors.textPrimaryDark : MurmoryColors.textPrimaryLight,
        ),
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MurmoryRadius.lg),
        ),
        color: isDark ? MurmoryColors.surfaceDark : MurmoryColors.surface,
      ),
      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? MurmoryColors.backgroundDark : Colors.white,
        indicatorColor: MurmoryColors.accent.withAlpha(30),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? MurmoryColors.surfaceDark : MurmoryColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MurmoryRadius.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MurmoryRadius.full),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MurmoryRadius.full),
          borderSide: const BorderSide(color: MurmoryColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        hintStyle: TextStyle(
          color: isDark ? MurmoryColors.textSecondaryDark : MurmoryColors.textSecondaryLight,
        ),
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? MurmoryColors.dividerDark : MurmoryColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MurmoryColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MurmoryRadius.full),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MurmoryColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MurmoryRadius.full),
          ),
        ),
      ),
      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MurmoryRadius.full),
        ),
        backgroundColor: isDark ? MurmoryColors.surfaceDark : MurmoryColors.surface,
        selectedColor: MurmoryColors.accent.withAlpha(40),
        labelStyle: TextStyle(
          color: isDark ? MurmoryColors.textPrimaryDark : MurmoryColors.textPrimaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: isDark ? MurmoryColors.dividerDark : MurmoryColors.dividerLight,
        ),
      ),
      scaffoldBackgroundColor: isDark ? MurmoryColors.backgroundDark : MurmoryColors.backgroundLight,
    );
  }
}
