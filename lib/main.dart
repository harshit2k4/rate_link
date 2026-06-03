import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/routes/app_pages.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/format_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();
  await Hive.openBox('prefs');
  await Hive.openBox('rateCache');
  final prefs = Hive.box('prefs');
  FormatPrefs.apply(
    prefs.get('digitSeparator', defaultValue: FormatPrefs.options[1]) as String,
  );
  // Register before runApp so Get.find works on the very first frame
  Get.put(ConnectivityService());
  runApp(const RateFlipApp());
}

class RateFlipApp extends StatelessWidget {
  const RateFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Hive.box('prefs');
    final isDark = prefs.get('darkMode', defaultValue: false) as bool;
    final useScheme = prefs.get('colorScheme', defaultValue: true) as bool;
    final primary = useScheme ? AppColors.purple : AppColors.altPrimary;
    return GetMaterialApp(
      title: 'RateFlip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(primary: primary),
      darkTheme: AppTheme.dark(primary: primary),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
