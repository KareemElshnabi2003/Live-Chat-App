import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';

class NotifyRemoteData {
  final Api api; // إضافة final
  NotifyRemoteData({required this.api});

  gwetNotify({required int perPage, required int page}) async {
    var response = await api.getData("${AppApi.baseUrl}/get-user-notifications?per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }
}