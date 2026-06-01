import 'package:flutter/material.dart';
import 'app_theme.dart';

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get primaryText => isDark ? Colors.white : AppColors.textDark;
  Color get secondaryText =>
      isDark ? const Color(0xFF8892A4) : AppColors.textMuted;
  Color get cardBg => isDark ? AppColors.darkSurface : AppColors.cardBg;
  Color get dividerColor =>
      isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFF0EEF8);
  Color get primaryAccent => Theme.of(this).colorScheme.primary;
  // Renamed: avoids collision with GetX's own iconColor on BuildContext
  Color get surfaceIconColor => isDark ? Colors.white70 : AppColors.textDark;
  Color get purpleLightAdaptive =>
      isDark ? const Color(0xFF2D2B5E) : AppColors.purpleLight;
  Color get searchFill => isDark ? AppColors.darkBg : AppColors.background;
}
