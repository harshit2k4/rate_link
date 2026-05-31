import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../core/constants/currencies.dart';
import '../../data/providers/frankfurter_provider.dart';
import '../../data/repositories/exchange_repository.dart';

class OtherCurrencyItem {
  final String code;
  final String name;
  final double rate;
  final double change;
  OtherCurrencyItem({
    required this.code,
    required this.name,
    required this.rate,
    required this.change,
  });
}

class HomeController extends GetxController {
  late final ExchangeRepository _repo;
  late final Box _prefs;

  final isLoading = true.obs;
  final hasError = false.obs;
  final baseCurrency = 'USD'.obs;
  final targetCurrency = 'IDR'.obs;
  final targetRate = 0.0.obs;
  final targetChange = 0.0.obs;
  final currentDate = ''.obs;
  final chartSpots = <FlSpot>[].obs;
  final otherCurrencies = <OtherCurrencyItem>[].obs;

  static const _priorityCurrencies = [
    'EUR',
    'SGD',
    'JPY',
    'GBP',
    'AUD',
    'CNY',
    'CHF',
    'CAD',
    'INR',
    'KRW',
  ];

  @override
  void onInit() {
    super.onInit();
    _prefs = Hive.box('prefs');
    _repo = ExchangeRepository(FrankfurterProvider(), Hive.box('rateCache'));
    baseCurrency.value =
        _prefs.get('baseCurrency', defaultValue: 'USD') as String;
    targetCurrency.value =
        _prefs.get('targetCurrency', defaultValue: 'IDR') as String;
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      final base = baseCurrency.value;
      final target = targetCurrency.value;

      final todayRates = await _repo.getLatestRates(base);
      Map<String, double> yesterdayRates = {};
      try {
        yesterdayRates = await _repo.getRatesByDate(_fmt(yesterday), base);
      } catch (_) {
        yesterdayRates = todayRates;
      }

      targetRate.value = todayRates[target] ?? 0.0;
      targetChange.value =
          (todayRates[target] ?? 0.0) - (yesterdayRates[target] ?? 0.0);
      currentDate.value = _repo.latestDate;

      final items = <OtherCurrencyItem>[];
      for (final code in _priorityCurrencies) {
        if (code == target || !todayRates.containsKey(code)) continue;
        items.add(
          OtherCurrencyItem(
            code: code,
            name: kCurrencyNames[code] ?? code,
            rate: todayRates[code]!,
            change: (todayRates[code] ?? 0.0) - (yesterdayRates[code] ?? 0.0),
          ),
        );
      }
      otherCurrencies.value = items;

      final rangeData = await _repo.getRateRange(
        fromDate: _fmt(thirtyDaysAgo),
        toDate: _fmt(today),
        base: base,
        target: target,
      );
      final spots = <FlSpot>[];
      int i = 0;
      for (final rate in rangeData.values) {
        spots.add(FlSpot(i.toDouble(), rate));
        i++;
      }
      chartSpots.value = spots;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Called from SettingsController after saving prefs
  void refreshPrefs() {
    baseCurrency.value =
        _prefs.get('baseCurrency', defaultValue: 'USD') as String;
    targetCurrency.value =
        _prefs.get('targetCurrency', defaultValue: 'IDR') as String;
    loadData();
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
