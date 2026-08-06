import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class MainRemoteData {
  final Api api; // إضافة final
  MainRemoteData({
    required this.api,
  });
//new
  getAds() async {
    var response = await api.getData(
        "${AppApi.getAds}?${sharedPreferences!.getString("deviceId")}"
   );
    return response.fold((l) => l, (r) => r);
  }
}