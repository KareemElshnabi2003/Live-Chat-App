import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';

class StarsService {
  final Api api = Get.find<Api>(); // استخدمنا الـ Singleton

  Future<Map<String, dynamic>> sendStars(String email, String numberOfStars) async {
    var response = await api.postData(AppApi.sendStars, {
      'email': email,
      'number_of_stars': numberOfStars,
    });

    return response.fold(
            (l) => {'status': 'error', 'message': 'Failed to send stars'},
            (r) => r as Map<String, dynamic>
    );
  }
}