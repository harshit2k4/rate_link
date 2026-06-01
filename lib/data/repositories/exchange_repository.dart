import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/frankfurter_provider.dart';

class ExchangeRepository {
  final FrankfurterProvider _provider;
  final Box _cache;

  ExchangeRepository(this._provider, this._cache);

  // Fetches code -> full name for every currency frankfurter supports.
  // Served from Hive for 24 hours before re-fetching.
  Future<Map<String, String>> getCurrencyNames() async {
    final cached = _cache.get('currency_names');
    final cachedAt = _cache.get('currency_names_at');
    if (cached != null && cachedAt != null) {
      final age = DateTime.now().difference(DateTime.parse(cachedAt as String));
      if (age.inHours < 24) {
        return Map<String, String>.from(jsonDecode(cached as String) as Map);
      }
    }
    try {
      final data = await _provider.getCurrencies();
      final names = Map<String, String>.from(data);
      await _cache.put('currency_names', jsonEncode(names));
      await _cache.put('currency_names_at', DateTime.now().toIso8601String());
      return names;
    } catch (_) {
      if (cached != null) {
        return Map<String, String>.from(jsonDecode(cached as String) as Map);
      }
      return {};
    }
  }

  Future<Map<String, double>> getLatestRates(String base) async {
    try {
      final data = await _provider.getLatest(base);
      final rates = _parseRates(data['rates']);
      await _cache.put('latest_$base', jsonEncode(rates));
      await _cache.put('latest_${base}_date', data['date'] as String);
      return rates;
    } catch (_) {
      final cached = _cache.get('latest_$base');
      if (cached != null) return _parseRates(jsonDecode(cached as String));
      rethrow;
    }
  }

  Future<Map<String, double>> getRatesByDate(String date, String base) async {
    final data = await _provider.getByDate(date, base);
    return _parseRates(data['rates']);
  }

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
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  String latestDateFor(String base) =>
      _cache.get('latest_${base}_date', defaultValue: '') as String;

  Map<String, double> _parseRates(dynamic raw) {
    return Map<String, double>.fromEntries(
      (raw as Map<String, dynamic>).entries.map(
        (e) => MapEntry(e.key, (e.value as num).toDouble()),
      ),
    );
  }
}
