import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/rate_alert.dart';
import 'notification_service.dart';

class AlertCheckRunner {
  static Future<bool> run() async {
    try {
      final box = Hive.box('alerts');
      final alerts = box.keys
          .map((k) => RateAlert.fromJsonString(box.get(k) as String))
          .where((a) => a.isEnabled && !a.hasTriggered)
          .toList();

      if (alerts.isEmpty) return true;

      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.frankfurter.app',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // Group by base to minimise API calls
      final bases = alerts.map((a) => a.baseCurrency).toSet();

      for (final base in bases) {
        try {
          final res = await dio.get('/latest', queryParameters: {'from': base});
          final rates = (res.data['rates'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          );

          for (final alert in alerts.where((a) => a.baseCurrency == base)) {
            final current = rates[alert.targetCurrency];
            if (current == null) continue;

            final fired = alert.direction == AlertDirection.above
                ? current >= alert.threshold
                : current <= alert.threshold;

            if (fired) {
              final dirWord = alert.direction == AlertDirection.above
                  ? 'above'
                  : 'below';
              await NotificationService.showRateAlert(
                id: alert.id.hashCode.abs(),
                title: '${alert.baseCurrency} → ${alert.targetCurrency} Alert',
                body:
                    'Rate is now ${current.toStringAsFixed(2)} — $dirWord your target of ${alert.threshold.toStringAsFixed(2)}',
              );
              // Disable alert after it fires so it doesn't spam
              await box.put(
                alert.id,
                alert
                    .copyWith(isEnabled: false, hasTriggered: true)
                    .toJsonString(),
              );
            }
          }
        } catch (_) {
          continue;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
