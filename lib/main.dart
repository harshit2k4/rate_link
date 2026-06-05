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
  Get.put(ConnectivityService());
  Get.put(ThemeController());
  runApp(const RateFlipApp());
}

class RateFlipApp extends StatelessWidget {
  const RateFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Hive.box('prefs');
    final onboardingDone =
        prefs.get('onboardingDone', defaultValue: false) as bool;
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) => GetMaterialApp(
        title: 'RateLink',
        debugShowCheckedModeBanner: false,
        theme: themeCtrl.light,
        darkTheme: themeCtrl.dark,
        themeMode: themeCtrl.mode,
        initialRoute: onboardingDone ? AppPages.initial : Routes.onboarding,
        getPages: AppPages.routes,
      ),
    );
  }
}
