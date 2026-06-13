import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/providers/frankfurter_provider.dart';
import '../../data/repositories/exchange_repository.dart';

class HistoryEntry {
  final String isoDate;
  final double rate;
  final double change;
  HistoryEntry({
    required this.isoDate,
    required this.rate,
    required this.change,
  });
}

class DetailController extends GetxController {
  late final ExchangeRepository _repo;

  final isLoading = true.obs;
  final baseCurrency = 'USD'.obs;
  final targetCurrency = 'INR'.obs;
  final rate = 0.0.obs;
  final rateChange = 0.0.obs;
  final currentDate = ''.obs;
  final chartSpots = <FlSpot>[].obs;
  final history = <HistoryEntry>[].obs;
  final selectedPeriod = 1.obs;

  // Historical date picker
  final historicalDate = Rxn<DateTime>();
  bool get isHistoricalMode => historicalDate.value != null;

  final periods = ['Annually', 'Monthly', 'Weekly', 'Daily'];

  @override
  void onInit() {
    super.onInit();
    _repo = ExchangeRepository(FrankfurterProvider(), Hive.box('rateCache'));
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    baseCurrency.value = args['base'] as String? ?? 'USD';
    targetCurrency.value = args['target'] as String? ?? 'INR';
    loadData();
  }

  // overrideEnd allows historical mode to pass a past date as the end
  Future<void> loadData({DateTime? overrideEnd}) async {
    isLoading.value = true;
    final endDate = overrideEnd ?? historicalDate.value ?? DateTime.now();

    if (baseCurrency.value == targetCurrency.value) {
      _loadTrivialData(endDate);
      isLoading.value = false;
      return;
    }

    try {
      final periodDays = switch (selectedPeriod.value) {
        0 => 365,
        2 => 7,
        3 => 1,
        _ => 30,
      };
      final startDate = endDate.subtract(Duration(days: periodDays));

      final rangeData = await _repo.getRateRange(
        fromDate: _fmt(startDate),
        toDate: _fmt(endDate),
        base: baseCurrency.value,
        target: targetCurrency.value,
      );

      if (rangeData.isEmpty) return;

      final dates = rangeData.keys.toList();
      final rates = rangeData.values.toList();

      rate.value = rates.last;
      rateChange.value = rates.length > 1
          ? rates.last - rates[rates.length - 2]
          : 0.0;
      currentDate.value = dates.last;

      int i = 0;
      chartSpots.value = rangeData.values
          .map((r) => FlSpot((i++).toDouble(), r))
          .toList();

      final entries = <HistoryEntry>[];
      for (int j = dates.length - 1; j >= 0 && entries.length < 12; j--) {
        entries.add(
          HistoryEntry(
            isoDate: dates[j],
            rate: rates[j],
            change: j > 0 ? rates[j] - rates[j - 1] : 0.0,
          ),
        );
      }
      history.value = entries;
    } catch (_) {
      // Keep existing data on error
    } finally {
      isLoading.value = false;
    }
  }

  void pickHistoricalDate(DateTime date) {
    historicalDate.value = date;
    loadData(overrideEnd: date);
  }

  void clearHistoricalMode() {
    historicalDate.value = null;
    loadData();
  }

  void selectPeriod(int index) {
    selectedPeriod.value = index;
    // Respect historical mode when re-loading for period change
    loadData(overrideEnd: historicalDate.value);
  }

  void _loadTrivialData(DateTime end) {
    rate.value = 1.0;
    rateChange.value = 0.0;
    currentDate.value = _fmt(end);
    chartSpots.value = List.generate(30, (i) => FlSpot(i.toDouble(), 1.0));
    history.value = List.generate(
      10,
      (i) => HistoryEntry(
        isoDate: _fmt(end.subtract(Duration(days: i + 1))),
        rate: 1.0,
        change: 0.0,
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
