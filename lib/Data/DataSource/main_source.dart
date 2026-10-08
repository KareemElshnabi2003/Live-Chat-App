import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class MainRemoteData {
  final Api api; // إضافة final

  final String deviceId=sharedPreferences!.getString("deviceId")??"";

  MainRemoteData({
    required this.api,
  });
//new
  getAds() async {
    var response = await api.getData(
        "${AppApi.getAds}?device_id=$deviceId"
   );
    return response.fold((l) => l, (r) => r);
  }
}