import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF0EEF8);
  static const darkCard = Color(0xFF1E2140);
  static const purple = Color(0xFF7060D8);
  // Used when color scheme toggle is off
  static const altPrimary = Color(0xFF2563EB);
  static const purpleLight = Color(0xFFEAE8F7);
  static const green = Color(0xFF2CC49E);
  static const red = Color(0xFFFF6B6B);
  static const textDark = Color(0xFF1A1D3B);
  static const textMuted = Color(0xFF9CA3AF);
  static const cardBg = Color(0xFFFFFFFF);
  static const chartLine = Color(0xFF9B8FE8);
  static const darkBg = Color(0xFF12142A);
  static const darkSurface = Color(0xFF1C1F3A);
}

class AppTheme {
  AppTheme._();

  static ThemeData light({Color primary = AppColors.purple}) => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: primary,
      surface: AppColors.cardBg,
      onSurface: AppColors.textDark,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDark),
    ),
  );

  static ThemeData dark({Color primary = AppColors.purple}) => ThemeData(
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: primary,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );
}
