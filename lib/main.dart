import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();
  await Hive.openBox('prefs');
  await Hive.openBox('rateCache');
  runApp(const RateLinkApp());
}

class RateLinkApp extends StatelessWidget {
  const RateLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Hive.box('prefs').get('darkMode', defaultValue: false) as bool;
    return GetMaterialApp(
      title: 'RateLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
