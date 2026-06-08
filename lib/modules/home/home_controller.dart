import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
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
  Timer? _stalenessTimer;

  final isLoading = true.obs;
  final hasError = false.obs;
  final baseCurrency = 'USD'.obs;
  final targetCurrency = 'INR'.obs;
  final targetRate = 0.0.obs;
  final targetChange = 0.0.obs;
  final currentDate = ''.obs;
  final chartSpots = <FlSpot>[].obs;
  final otherCurrencies = <OtherCurrencyItem>[].obs;
  final currencyNames = <String, String>{}.obs;
  final lastUpdated = Rxn<DateTime>();
  final stalenessTick = 0.obs;
  final favorites = <String>[].obs;
  final searchQuery = ''.obs;

  String get targetCurrencyName =>
      currencyNames[targetCurrency.value] ?? targetCurrency.value;

  bool get isStale {
    final dt = lastUpdated.value;
    if (dt == null) return false;
    return DateTime.now().difference(dt).inMinutes > 15;
  }

  String get stalenessText {
    stalenessTick.value;
    final dt = lastUpdated.value;
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just updated';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    return 'Updated ${diff.inHours}h ago';
  }

  List<OtherCurrencyItem> get filteredCurrencies {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return otherCurrencies;
    return otherCurrencies
        .where(
          (item) =>
              item.code.toLowerCase().contains(q) ||
              item.name.toLowerCase().contains(q),
        )
        .toList();
  }

  List<OtherCurrencyItem> get pinnedCurrencies =>
      otherCurrencies.where((item) => favorites.contains(item.code)).toList();

  List<OtherCurrencyItem> get unpinnedCurrencies {
    final fav = favorites.toSet();
    return filteredCurrencies
        .where((item) => !fav.contains(item.code))
        .toList();
  }

  void toggleFavorite(String code) {
    final list = List<String>.from(favorites);
    if (list.contains(code)) {
      list.remove(code);
    } else {
      list.insert(0, code);
    }
    favorites.value = list;
    _prefs.put('favorites', list);
  }

  @override
  void onInit() {
    super.onInit();
    _prefs = Hive.box('prefs');
    _repo = ExchangeRepository(FrankfurterProvider(), Hive.box('rateCache'));
    baseCurrency.value =
        _prefs.get('baseCurrency', defaultValue: 'USD') as String;
    targetCurrency.value =
        _prefs.get('targetCurrency', defaultValue: 'INR') as String;
    final saved = _prefs.get('favorites', defaultValue: <dynamic>[]);
    favorites.value = List<String>.from(saved as List);
    _stalenessTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => stalenessTick.value++,
    );
    loadData();
  }

  @override
  void onClose() {
    _stalenessTimer?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final base = baseCurrency.value;
      final target = targetCurrency.value;
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));

      final namesFuture = _repo.getCurrencyNames();
      final ratesFuture = _repo.getLatestRates(base);
      final names = await namesFuture;
      final todayRates = await ratesFuture;
      currencyNames.value = names;

      // Same currency: no API for range, use trivial data
      if (base == target) {
        targetRate.value = 1.0;
        targetChange.value = 0.0;
        currentDate.value = _fmt(today);
        lastUpdated.value = DateTime.now();
        chartSpots.value = List.generate(30, (i) => FlSpot(i.toDouble(), 1.0));
        final codes = todayRates.keys.toList()..sort();
        otherCurrencies.value = codes
            .map(
              (code) => OtherCurrencyItem(
                code: code,
                name: names[code] ?? code,
                rate: todayRates[code]!,
                change: 0.0,
              ),
            )
            .toList();
        return;
      }

      Map<String, double> yesterdayRates;
      try {
        yesterdayRates = await _repo.getRatesByDate(_fmt(yesterday), base);
      } catch (_) {
        yesterdayRates = todayRates;
      }

      targetRate.value = todayRates[target] ?? 0.0;
      targetChange.value =
          (todayRates[target] ?? 0.0) - (yesterdayRates[target] ?? 0.0);
      currentDate.value = _repo.latestDateFor(base);
      lastUpdated.value = DateTime.now();

      final codes = todayRates.keys.where((c) => c != target).toList()..sort();
      otherCurrencies.value = codes
          .map(
            (code) => OtherCurrencyItem(
              code: code,
              name: names[code] ?? code,
              rate: todayRates[code]!,
              change: (todayRates[code] ?? 0.0) - (yesterdayRates[code] ?? 0.0),
            ),
          )
          .toList();

      final rangeData = await _repo.getRateRange(
        fromDate: _fmt(thirtyDaysAgo),
        toDate: _fmt(today),
        base: base,
        target: target,
      );
      int i = 0;
      chartSpots.value = rangeData.values
          .map((r) => FlSpot((i++).toDouble(), r))
          .toList();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void refreshPrefs() {
    baseCurrency.value =
        _prefs.get('baseCurrency', defaultValue: 'USD') as String;
    targetCurrency.value =
        _prefs.get('targetCurrency', defaultValue: 'INR') as String;
    loadData();
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
