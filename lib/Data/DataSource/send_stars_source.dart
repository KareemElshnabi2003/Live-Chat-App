import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class StarsService {
  final Api api = Get.find<Api>(); // استخدمنا الـ Singleton
  final String deviceId=sharedPreferences!.getString("deviceId")??"";

  Future<Map<String, dynamic>> sendStars(String email, String numberOfStars) async {
    var response = await api.postData("${AppApi.sendStars}?device_id=$deviceId", {
      'email': email,
      'number_of_stars': numberOfStars,
    });

    return response.fold(
            (l) => {'status': 'error', 'message': 'Failed to send stars'},
            (r) => r as Map<String, dynamic>
    );
  }
}