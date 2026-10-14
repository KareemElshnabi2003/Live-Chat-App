import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/class/status_request.dart';

StatuesRequest? _lastErrorStatus;
String? _lastErrorMessage;
DateTime? _lastErrorTime;

void showUserFriendlyError(StatuesRequest status, {String? customMessage}) {
  final now = DateTime.now();
  final targetMessage = customMessage ?? Api.serverMessage;

  if (_lastErrorStatus == status && 
      _lastErrorMessage == targetMessage &&
      _lastErrorTime != null && 
      now.difference(_lastErrorTime!).inMilliseconds < 1500) {
    return;
  }

  _lastErrorStatus = status;
  _lastErrorMessage = targetMessage;
  _lastErrorTime = now;

  String title = "تنبيه";
  String message = "";
  
  Color bgColor = Colors.redAccent.shade700;
  IconData iconData = Icons.error_outline_rounded;

  if (status == StatuesRequest.unauthorizedException) {
    return; 
  }

  switch (status) {
    case StatuesRequest.socketException:
    case StatuesRequest.timeoutException:
      bgColor = Colors.orange.shade700;
      iconData = Icons.wifi_off_rounded;
      title = "لا يوجد اتصال بالإنترنت";
      message = "تأكد من اتصالك بالشبكة وحاول مرة أخرى.";
      break;

    case StatuesRequest.serverException:
    case StatuesRequest.serverError:
    case StatuesRequest.formatException:
      final hasServerMsg = (customMessage != null && customMessage.isNotEmpty) ||
          (Api.serverMessage != null && Api.serverMessage!.isNotEmpty);
      bgColor = hasServerMsg ? Colors.redAccent.shade700 : Colors.red.shade600;
      iconData = hasServerMsg ? Icons.error_outline_rounded : Icons.dns_rounded;
      title = hasServerMsg ? "تنبيه" : "عذراً، حدث خطأ";
      message = customMessage ??
          Api.serverMessage ??
          "نواجه مشكلة في الخادم حالياً، يرجى المحاولة لاحقاً.";
      Api.serverMessage = null;
      break;

    case StatuesRequest.forbiddenException:
      bgColor = Colors.blueGrey.shade700;
      iconData = Icons.lock_outline_rounded;
      title = "صلاحيات غير كافية";
      message = customMessage ?? Api.serverMessage ?? "لا تملك الصلاحيات الكافية لتنفيذ هذا الإجراء.";
      Api.serverMessage = null;
      break;
    
    case StatuesRequest.badRequestException:
    case StatuesRequest.conflictException:
    case StatuesRequest.unprocessableException:
      bgColor = Colors.redAccent.shade700;
      iconData = Icons.error_outline_rounded;
      title = "تنبيه";
      message = customMessage ?? Api.serverMessage ?? "البيانات المدخلة غير صحيحة، يرجى مراجعتها.";
      Api.serverMessage = null; 
      break;

    default:
      final hasCustom = (customMessage != null && customMessage.isNotEmpty) ||
          (Api.serverMessage != null && Api.serverMessage!.isNotEmpty);
      bgColor = hasCustom ? Colors.redAccent.shade700 : Colors.redAccent;
      iconData = hasCustom ? Icons.error_outline_rounded : Icons.warning_amber_rounded;
      title = hasCustom ? "تنبيه" : "خطأ غير متوقع";
      message = customMessage ?? Api.serverMessage ?? "حدث خطأ غير معروف، يرجى إعادة المحاولة.";
      Api.serverMessage = null;
  }

  // عرض السناك بار
  if (message.isNotEmpty) {
    // 🌟 [اختياري بس مفيد] بيمسح أي سناك بار قديم معلق قبل ما يعرض الجديد
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.snackbar(
      title,
      message,
      icon: Icon(iconData, color: Colors.white, size: 28),
      shouldIconPulse: true, 
      backgroundColor: bgColor.withOpacity(0.95), 
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP, 
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      borderRadius: 16, 
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack, 
      duration: const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: bgColor.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 5),
        )
      ],
    );
  }
}