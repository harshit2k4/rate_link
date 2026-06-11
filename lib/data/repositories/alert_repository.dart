import 'package:hive_flutter/hive_flutter.dart';

import '../models/rate_alert.dart';

class AlertRepository {
  final Box _box;
  AlertRepository(this._box);

  List<RateAlert> getAll() =>
      _box.keys
          .map((k) => RateAlert.fromJsonString(_box.get(k) as String))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<RateAlert> getActive() =>
      getAll().where((a) => a.isEnabled && !a.hasTriggered).toList();

  Future<void> save(RateAlert alert) =>
      _box.put(alert.id, alert.toJsonString());

  Future<void> delete(String id) => _box.delete(id);

  Future<void> toggle(String id, bool enabled) async {
    final all = getAll();
    final idx = all.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    // Re-arming clears hasTriggered so the alert can fire again
    await save(
      all[idx].copyWith(
        isEnabled: enabled,
        hasTriggered: enabled ? false : all[idx].hasTriggered,
      ),
    );
  }
}
