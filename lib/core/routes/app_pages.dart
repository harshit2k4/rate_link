import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/converter/converter_controller.dart';
import '../../modules/converter/converter_view.dart';
import '../../modules/detail/detail_controller.dart';
import '../../modules/detail/detail_view.dart';
import '../../modules/home/home_controller.dart';
import '../../modules/home/home_view.dart';
import '../../modules/onboarding/onboarding_view.dart';
import '../../modules/settings/settings_controller.dart';
import '../../modules/settings/settings_view.dart';

abstract class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const settings = '/settings';
  static const converter = '/converter';
  static const onboarding = '/onboarding';
}

abstract class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(name: Routes.onboarding, page: () => const OnboardingView()),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => HomeController())),
    ),
    GetPage(
      name: Routes.detail,
      page: () => const DetailView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DetailController())),
      // Slides up from below — feels like the card expanding into detail
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SettingsController())),
    ),
    GetPage(
      name: Routes.converter,
      page: () => const ConverterView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ConverterController())),
    ),
  ];
}
