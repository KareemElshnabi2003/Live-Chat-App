import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/class/status_request.dart';

StatuesRequest? _lastErrorStatus;
DateTime? _lastErrorTime;

void showUserFriendlyError(StatuesRequest status, {String? customMessage}) {
  
  final now = DateTime.now();
  if (_lastErrorStatus == status && 
      _lastErrorTime != null && 
      now.difference(_lastErrorTime!).inSeconds < 4) {
    return; // اخرج من الدالة وماتعرضش حاجة
  }

  // تحديث وقت ونوع آخر خطأ
  _lastErrorStatus = status;
  _lastErrorTime = now;

  // -----------------------------------------
  // باقي الكود بتاعك زي ما هو بالظبط من غير تغيير
  // -----------------------------------------

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
      bgColor = Colors.red.shade600;
      iconData = Icons.dns_rounded;
      title = "عذراً، حدث خطأ";
      message = "نواجه مشكلة في الخادم حالياً، يرجى المحاولة لاحقاً.";
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
      bgColor = Colors.orange.shade800;
      iconData = Icons.rule_rounded;
      title = "تنبيه";
      message = customMessage ?? Api.serverMessage ?? "البيانات المدخلة غير صحيحة، يرجى مراجعتها.";
      Api.serverMessage = null; 
      break;

    default:
      bgColor = Colors.redAccent;
      iconData = Icons.warning_amber_rounded;
      title = "خطأ غير متوقع";
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