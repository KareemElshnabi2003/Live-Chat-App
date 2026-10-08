import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class MarketRemoteData {
  final Api api;
  MarketRemoteData({required this.api});
  final String deviceId=sharedPreferences!.getString("deviceId")??"";
  closePower({required String status, required String powerId}) async {
    var response = await api.updatePatchData("${AppApi.baseUrl}/user_powers/$powerId?device_id=$deviceId", {
      "status": status
    });
    return response.fold((l) => l, (r) => r);
  }
}