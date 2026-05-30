import 'package:dio/dio.dart';

class FrankfurterProvider {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.frankfurter.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, dynamic>> getLatest(String base) async {
    final res = await _dio.get('/latest', queryParameters: {'from': base});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getByDate(String date, String base) async {
    final res = await _dio.get('/$date', queryParameters: {'from': base});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getRange({
    required String from,
    required String to,
    required String base,
    String? target,
  }) async {
    final params = <String, dynamic>{'from': base};
    if (target != null) params['to'] = target;
    final res = await _dio.get('/$from..$to', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCurrencies() async {
    final res = await _dio.get('/currencies');
    return res.data as Map<String, dynamic>;
  }
}
