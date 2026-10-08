import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class NotifyRemoteData {
  final Api api; // إضافة final
  NotifyRemoteData({required this.api});
  final String deviceId=sharedPreferences!.getString("deviceId")??"";

  gwetNotify({required int perPage, required int page}) async {
    var response = await api.getData("${AppApi.getNotificationUrl}?per_page=$perPage&page=$page&device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }
}