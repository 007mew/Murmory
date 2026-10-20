import 'package:flutter/material.dart';
import 'package:murmory/core/design_system/tokens.dart';

class MurmoryTypography {
  MurmoryTypography._();

  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineLarge(BuildContext context) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.4,
      );

  static TextStyle labelLarge(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle mono(BuildContext context) => TextStyle(
        fontFamily: 'monospace',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle timerDisplay(BuildContext context) => TextStyle(
        fontFamily: 'monospace',
        fontSize: 56,
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.dark
            ? MurmoryColors.textSecondaryDark
            : MurmoryColors.textSecondaryLight,
      );
}
