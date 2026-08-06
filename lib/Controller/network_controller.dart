import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool isOffline = false;

  @override
  void onInit() {
    super.onInit();
    // مراقبة تغيرات الشبكة
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    // التحقق مما إذا كان لا يوجد اتصال
    if (connectivityResult.contains(ConnectivityResult.none)) {
      isOffline = true;
      Get.rawSnackbar(
        messageText: const Text(
          'أنت غير متصل بالإنترنت حالياً',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        isDismissible: false,
        duration: const Duration(days: 1), // مدة طويلة جداً عشان يفضل ظاهر لحد ما النت يرجع
        backgroundColor: Colors.red[800]!,
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );
    } else {
      // لو كان فاصل ورجع
      if (isOffline) {
        isOffline = false;
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.snackbar(
          "ممتاز!",
          "تم استعادة الاتصال بالإنترنت بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.wifi, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      }
    }
  }
}