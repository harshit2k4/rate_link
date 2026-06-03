import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final isOnline = true.obs;
  late StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  void onInit() {
    super.onInit();
    Connectivity().checkConnectivity().then((results) {
      isOnline.value = results.any((r) => r != ConnectivityResult.none);
    });
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      isOnline.value = results.any((r) => r != ConnectivityResult.none);
    });
  }

  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}
