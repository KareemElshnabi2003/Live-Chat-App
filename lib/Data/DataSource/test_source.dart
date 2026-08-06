// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';

class TestRemoteData {
  Api api;
  TestRemoteData({
    required this.api,
  });
//gust
  getThemes() async {
    var response = await api.getData(AppApi.getThemsUrl);
    return response.fold((l) => l, (r) => r);
  }

  //user
}
