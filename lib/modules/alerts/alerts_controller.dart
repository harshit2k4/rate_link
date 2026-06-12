import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../core/services/alert_check_runner.dart';
import '../../data/models/rate_alert.dart';
import '../../data/providers/frankfurter_provider.dart';
import '../../data/repositories/alert_repository.dart';
import '../../data/repositories/exchange_repository.dart';

class AlertsController extends GetxController {
  late final AlertRepository _alertRepo;
  late final ExchangeRepository _exchangeRepo;

  final alerts = <RateAlert>[].obs;
  final currencyNames = <String, String>{}.obs;
  final isLoading = true.obs;

  // Add-alert sheet state
  final addBase = 'USD'.obs;
  final addTarget = 'INR'.obs;
  final addDirection = AlertDirection.above.obs;
  final addThreshold = ''.obs;
  final previewRate = 0.0.obs;
  final isLoadingPreview = false.obs;

  List<String> get currencyCodes => currencyNames.keys.toList()..sort();

  @override
  void onInit() {
    super.onInit();
    _alertRepo = AlertRepository(Hive.box('alerts'));
    _exchangeRepo = ExchangeRepository(
      FrankfurterProvider(),
      Hive.box('rateCache'),
    );
    final prefs = Hive.box('prefs');
    addBase.value = prefs.get('baseCurrency', defaultValue: 'USD') as String;
    addTarget.value =
        prefs.get('targetCurrency', defaultValue: 'INR') as String;
    _loadAlerts();
    _loadCurrencies();
    // Also run a foreground check each time the user opens Alerts
    AlertCheckRunner.run().then((_) => _loadAlerts());
  }

  void _loadAlerts() {
    alerts.value = _alertRepo.getAll();
    isLoading.value = false;
  }

  Future<void> _loadCurrencies() async {
    final names = await _exchangeRepo.getCurrencyNames();
    currencyNames.value = names;
    await refreshPreviewRate();
  }

  Future<void> refreshPreviewRate() async {
    if (addBase.value == addTarget.value) {
      previewRate.value = 1.0;
      return;
    }
    isLoadingPreview.value = true;
    try {
      final rates = await _exchangeRepo.getLatestRates(addBase.value);
      previewRate.value = rates[addTarget.value] ?? 0.0;
    } catch (_) {
      previewRate.value = 0.0;
    } finally {
      isLoadingPreview.value = false;
    }
  }

  void setAddBase(String code) {
    if (code == addTarget.value) addTarget.value = addBase.value;
    addBase.value = code;
    refreshPreviewRate();
  }

  void setAddTarget(String code) {
    if (code == addBase.value) addBase.value = addTarget.value;
    addTarget.value = code;
    refreshPreviewRate();
  }

  void setAddDirection(AlertDirection dir) => addDirection.value = dir;

  Future<bool> saveAlert() async {
    final threshold = double.tryParse(addThreshold.value);
    if (threshold == null || threshold <= 0) return false;
    if (addBase.value == addTarget.value) return false;
    await _alertRepo.save(
      RateAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        baseCurrency: addBase.value,
        targetCurrency: addTarget.value,
        threshold: threshold,
        direction: addDirection.value,
        createdAt: DateTime.now(),
      ),
    );
    _loadAlerts();
    return true;
  }

  Future<void> deleteAlert(String id) async {
    await _alertRepo.delete(id);
    _loadAlerts();
  }

  Future<void> toggleAlert(String id, bool enabled) async {
    await _alertRepo.toggle(id, enabled);
    _loadAlerts();
  }
}
