import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  ThemeMode _mode = ThemeMode.light;
  ThemeData _light = AppTheme.light();
  ThemeData _dark = AppTheme.dark();

  ThemeMode get mode => _mode;
  ThemeData get light => _light;
  ThemeData get dark => _dark;

  @override
  void onInit() {
    super.onInit();
    final prefs = Hive.box('prefs');
    final isDark = prefs.get('darkMode', defaultValue: false) as bool;
    final useScheme = prefs.get('colorScheme', defaultValue: true) as bool;
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    _applyScheme(useScheme);
    // No update() here — nobody is listening yet at onInit time
  }

  void setDarkMode(bool value) {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    update();
  }

  void setColorScheme(bool value) {
    _applyScheme(value);
    update();
  }

  void _applyScheme(bool useScheme) {
    final primary = useScheme ? AppColors.purple : AppColors.altPrimary;
    _light = AppTheme.light(primary: primary);
    _dark = AppTheme.dark(primary: primary);
  }
}
