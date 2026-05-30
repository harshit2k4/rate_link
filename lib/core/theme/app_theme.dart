import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF0EEF8);
  static const darkCard = Color(0xFF1E2140);
  static const purple = Color(0xFF7060D8);
  static const purpleLight = Color(0xFFEAE8F7);
  static const green = Color(0xFF2CC49E);
  static const red = Color(0xFFFF6B6B);
  static const textDark = Color(0xFF1A1D3B);
  static const textMuted = Color(0xFF9CA3AF);
  static const cardBg = Color(0xFFFFFFFF);
  static const chartLine = Color(0xFF9B8FE8);

  static const darkBg = Color(0xFF12142A);
  static const darkSurface = Color(0xFF1A1D35);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.purple,
      surface: AppColors.cardBg,
      onSurface: AppColors.textDark,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDark),
    ),
  );

  static ThemeData get dark => ThemeData(
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );
}
