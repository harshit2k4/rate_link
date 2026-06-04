import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/format_utils.dart';
import '../../data/providers/frankfurter_provider.dart';
import '../../data/repositories/exchange_repository.dart';
import '../home/home_controller.dart';

class SettingsController extends GetxController {
  late final ExchangeRepository _repo;
  late final Box _prefs;

  final baseCurrency = 'USD'.obs;
  final targetCurrency = 'INR'.obs;
  final listFilter = 'All'.obs;
  final isDarkMode = false.obs;
  final colorScheme = true.obs;
  final digitSeparator = FormatPrefs.options[1].obs;
  final isLoadingCurrencies = true.obs;
  final currencyNames = <String, String>{}.obs;

  List<String> get currencyCodes => (currencyNames.keys.toList()..sort());

  @override
  void onInit() {
    super.onInit();
    _prefs = Hive.box('prefs');
    _repo = ExchangeRepository(FrankfurterProvider(), Hive.box('rateCache'));
    baseCurrency.value =
        _prefs.get('baseCurrency', defaultValue: 'USD') as String;
    targetCurrency.value =
        _prefs.get('targetCurrency', defaultValue: 'INR') as String;
    listFilter.value = _prefs.get('listFilter', defaultValue: 'All') as String;
    // Mirror the saved state so the toggle UI shows the right position
    isDarkMode.value = _prefs.get('darkMode', defaultValue: false) as bool;
    colorScheme.value = _prefs.get('colorScheme', defaultValue: true) as bool;
    digitSeparator.value =
        _prefs.get('digitSeparator', defaultValue: FormatPrefs.options[1])
            as String;
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    isLoadingCurrencies.value = true;
    final names = await _repo.getCurrencyNames();
    currencyNames.value = names;
    isLoadingCurrencies.value = false;
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

  void setDigitSeparator(String style) {
    digitSeparator.value = style;
    _prefs.put('digitSeparator', style);
    FormatPrefs.apply(style);
    _syncHome();
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _prefs.put('darkMode', value);
    // ThemeController.update() triggers GetBuilder in main.dart → full rebuild
    Get.find<ThemeController>().setDarkMode(value);
  }

  void toggleColorScheme(bool value) {
    colorScheme.value = value;
    _prefs.put('colorScheme', value);
    Get.find<ThemeController>().setColorScheme(value);
  }

  void _syncHome() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshPrefs();
    }
  }
}
