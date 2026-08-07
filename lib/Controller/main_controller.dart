import 'dart:developer';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/main_source.dart';
import 'package:live_chat/Data/Model/ads_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MainController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  // التعديل هنا: استخدام Get.find
  final MainRemoteData _mainRemoteData = MainRemoteData(api: Get.find<Api>());

  List<AdsModel> adsAdmin = [];
  getAds() async {
    var response = await _mainRemoteData.getAds();

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      adsAdmin.addAll(responseBody.map(
        (e) => AdsModel.fromJson(e),
      ));
      log("ads  >>>> ${adsAdmin.length.toString()}");
    } else {
      log(response.toString());
      log("erroooorrr ads");
      showUserFriendlyError(statuesRequest);
    }

    update();
  }

  Future<void> launchURL(String urlString) async {
    // Add https:// if no scheme is present
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    final Uri url = Uri.parse(urlString);

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
