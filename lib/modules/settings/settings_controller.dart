import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../core/constants/currencies.dart';
import '../../data/providers/frankfurter_provider.dart';
import '../home/home_controller.dart';

class SettingsController extends GetxController {
  late final Box _prefs;

  final baseCurrency = 'USD'.obs;
  final targetCurrency = 'IDR'.obs;
  final listFilter = 'All'.obs;
  final isDarkMode = false.obs;
  final colorScheme = true.obs;
  final availableCurrencies = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _prefs = Hive.box('prefs');
    baseCurrency.value =
        _prefs.get('baseCurrency', defaultValue: 'USD') as String;
    targetCurrency.value =
        _prefs.get('targetCurrency', defaultValue: 'IDR') as String;
    listFilter.value = _prefs.get('listFilter', defaultValue: 'All') as String;
    isDarkMode.value = _prefs.get('darkMode', defaultValue: false) as bool;
    colorScheme.value = _prefs.get('colorScheme', defaultValue: true) as bool;
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final data = await FrankfurterProvider().getCurrencies();
      availableCurrencies.value = data.keys.toList()..sort();
    } catch (_) {
      availableCurrencies.value = kCurrencyNames.keys.toList()..sort();
    }
  }

  void setBase(String code) {
    baseCurrency.value = code;
    _prefs.put('baseCurrency', code);
    _syncHome();
  }

  void setTarget(String code) {
    targetCurrency.value = code;
    _prefs.put('targetCurrency', code);
    _syncHome();
  }

  void setListFilter(String filter) {
    listFilter.value = filter;
    _prefs.put('listFilter', filter);
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _prefs.put('darkMode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleColorScheme(bool value) {
    colorScheme.value = value;
    _prefs.put('colorScheme', value);
  }

  // Tell HomeController to reload if it is still alive
  void _syncHome() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshPrefs();
    }
  }
}
