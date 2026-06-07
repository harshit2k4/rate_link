import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
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

  Future<void> loadData() async {
    isLoading.value = true;

    // Same currency — 1:1 trivial case, no API call needed
    if (baseCurrency.value == targetCurrency.value) {
      _loadTrivialData();
      isLoading.value = false;
      return;
    }

    try {
      final today = DateTime.now();
      final start = switch (selectedPeriod.value) {
        0 => today.subtract(const Duration(days: 365)),
        2 => today.subtract(const Duration(days: 7)),
        3 => today.subtract(const Duration(days: 1)),
        _ => today.subtract(const Duration(days: 30)),
      };

      final rangeData = await _repo.getRateRange(
        fromDate: _fmt(start),
        toDate: _fmt(today),
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

      final spots = <FlSpot>[];
      for (int i = 0; i < rates.length; i++) {
        spots.add(FlSpot(i.toDouble(), rates[i]));
      }
      chartSpots.value = spots;

      final entries = <HistoryEntry>[];
      for (int i = dates.length - 1; i >= 0 && entries.length < 12; i--) {
        final change = i > 0 ? rates[i] - rates[i - 1] : 0.0;
        entries.add(
          HistoryEntry(isoDate: dates[i], rate: rates[i], change: change),
        );
      }
      history.value = entries;
    } catch (_) {
      // Keep existing data on network error
    } finally {
      isLoading.value = false;
    }
  }

  // Fills state with 1.0 values when base == target
  void _loadTrivialData() {
    rate.value = 1.0;
    rateChange.value = 0.0;
    currentDate.value = _fmt(DateTime.now());
    chartSpots.value = List.generate(30, (i) => FlSpot(i.toDouble(), 1.0));
    history.value = List.generate(
      10,
      (i) => HistoryEntry(
        isoDate: _fmt(DateTime.now().subtract(Duration(days: i + 1))),
        rate: 1.0,
        change: 0.0,
      ),
    );
  }

  void selectPeriod(int index) {
    selectedPeriod.value = index;
    loadData();
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
