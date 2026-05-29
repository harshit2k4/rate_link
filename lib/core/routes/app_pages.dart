import 'package:get/get.dart';
import '../../modules/home/home_controller.dart';
import '../../modules/home/home_view.dart';
import '../../modules/detail/detail_controller.dart';
import '../../modules/detail/detail_view.dart';
import '../../modules/settings/settings_controller.dart';
import '../../modules/settings/settings_view.dart';

abstract class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const settings = '/settings';
}

abstract class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => HomeController())),
    ),
    GetPage(
      name: Routes.detail,
      page: () => const DetailView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DetailController())),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SettingsController())),
    ),
  ];
}
