import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/handel_notification.dart';
import 'package:live_chat/Core/Class/api.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Api(), permanent: true);

    // 🌟 تشغيل مستمعات الإشعارات هنا "بعد" ما التطبيق يشتغل فعلياً ويكون في الـ Foreground
    if (!kIsWeb) {
      final firebaseNotification = Get.put(FirebaseNotification(), permanent: true);
      firebaseNotification.intilizeNotification();
    }
  }

  
}