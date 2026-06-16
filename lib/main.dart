import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'core/routes/app_pages.dart';
import 'core/services/alert_check_runner.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme_controller.dart';
import 'core/utils/format_utils.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, _) async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen('alerts')) await Hive.openBox('alerts');
    await NotificationService.init();
    return AlertCheckRunner.run();
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Hive.initFlutter();
  await Hive.openBox('prefs');
  await Hive.openBox('rateCache');
  await Hive.openBox('alerts');

  final prefs = Hive.box('prefs');
  FormatPrefs.apply(
    prefs.get('digitSeparator', defaultValue: FormatPrefs.options[1]) as String,
  );

  await NotificationService.init();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    'rate_alert_check',
    'checkRateAlerts',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    // Correct enum type for periodic tasks
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
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
        title: 'RateFlip',
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
