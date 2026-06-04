import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/routes/app_pages.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/theme_controller.dart';
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
  // Both services must exist before the first frame renders
  Get.put(ConnectivityService());
  Get.put(ThemeController());
  runApp(const RateFlipApp());
}

class RateFlipApp extends StatelessWidget {
  const RateFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetBuilder rebuilds GetMaterialApp whenever ThemeController calls update()
    // This is the only reliable way to hot-swap theme + darkTheme + themeMode together
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) => GetMaterialApp(
        title: 'RateLink',
        debugShowCheckedModeBanner: false,
        theme: themeCtrl.light,
        darkTheme: themeCtrl.dark,
        themeMode: themeCtrl.mode,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
