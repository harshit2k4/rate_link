import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/frankfurter_provider.dart';

class ExchangeRepository {
  final FrankfurterProvider _provider;
  final Box _cache;

  ExchangeRepository(this._provider, this._cache);

  Future<Map<String, double>> getLatestRates(String base) async {
    try {
      final data = await _provider.getLatest(base);
      final rates = _parseRates(data['rates']);
      _cache.put('latest_$base', jsonEncode(rates));
      _cache.put('latest_${base}_date', data['date'] as String);
      return rates;
    } catch (_) {
      final cached = _cache.get('latest_$base');
      if (cached != null) {
        return _parseRates(jsonDecode(cached as String));
      }
      rethrow;
    }
  }

  Future<Map<String, double>> getRatesByDate(String date, String base) async {
    final data = await _provider.getByDate(date, base);
    return _parseRates(data['rates']);
  }

  // Returns date-sorted map of date -> rate for a given pair
  Future<Map<String, double>> getRateRange({
    required String fromDate,
    required String toDate,
    required String base,
    String? target,
  }) async {
    final data = await _provider.getRange(
      from: fromDate,
      to: toDate,
      base: base,
      target: target,
    );
    final rawRates = data['rates'] as Map<String, dynamic>;
    final result = <String, double>{};
    for (final entry in rawRates.entries) {
      final dayRates = entry.value as Map<String, dynamic>;
      if (target != null && dayRates.containsKey(target)) {
        result[entry.key] = (dayRates[target] as num).toDouble();
      }
    }
    final sorted = Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  String get latestDate =>
      _cache.get('latest_USD_date', defaultValue: '') as String;

  Map<String, double> _parseRates(dynamic raw) {
    return Map<String, double>.fromEntries(
      (raw as Map<String, dynamic>).entries.map(
        (e) => MapEntry(e.key, (e.value as num).toDouble()),
      ),
    );
  }
}
