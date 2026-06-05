import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/format_utils.dart';
import '../../data/providers/frankfurter_provider.dart';
import '../../data/repositories/exchange_repository.dart';

class ConverterController extends GetxController {
  late final ExchangeRepository _repo;
  late final TextEditingController amountController;

  final fromCurrency = 'USD'.obs;
  final toCurrency = 'INR'.obs;
  final result = 0.0.obs;
  final isLoading = false.obs;
  final currentDate = ''.obs;
  final displayRate = ''.obs;
  final currencyNames = <String, String>{}.obs;

  Map<String, double> _rates = {};

  List<String> get currencyCodes => currencyNames.keys.toList()..sort();

  @override
  void onInit() {
    super.onInit();
    _repo = ExchangeRepository(FrankfurterProvider(), Hive.box('rateCache'));
    amountController = TextEditingController(text: '1');
    amountController.addListener(_compute);
    final prefs = Hive.box('prefs');
    fromCurrency.value =
        prefs.get('baseCurrency', defaultValue: 'USD') as String;
    toCurrency.value =
        prefs.get('targetCurrency', defaultValue: 'INR') as String;
    loadRates();
  }

  @override
  void onClose() {
    amountController
      ..removeListener(_compute)
      ..dispose();
    super.onClose();
  }

  Future<void> loadRates() async {
    isLoading.value = true;
    try {
      final names = await _repo.getCurrencyNames();
      currencyNames.value = names;
      _rates = await _repo.getLatestRates(fromCurrency.value);
      currentDate.value = _repo.latestDateFor(fromCurrency.value);
      _compute();
    } catch (_) {
      // Keep existing cached result on error
    } finally {
      isLoading.value = false;
    }
  }

  void setFrom(String code) {
    fromCurrency.value = code;
    loadRates();
  }

  void setTo(String code) {
    toCurrency.value = code;
    _compute();
  }

  void swap() {
    final tmp = fromCurrency.value;
    fromCurrency.value = toCurrency.value;
    toCurrency.value = tmp;
    loadRates();
  }

  void _compute() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final rate = _rates[toCurrency.value] ?? 0.0;
    result.value = amount * rate;
    if (rate > 0) {
      final rateStr = rate < 0.01 ? rate.toStringAsFixed(6) : formatRate(rate);
      displayRate.value =
          '1 ${fromCurrency.value} = $rateStr ${toCurrency.value}';
    } else {
      displayRate.value = '';
    }
  }
}
