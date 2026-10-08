import 'dart:convert';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/auth_source.dart';
import 'package:live_chat/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:flutter/material.dart';

class AppSettingsController extends GetxController {
  final RxString selectedLanguage = 'ar'.obs;
  final RxBool isDarkMode = false.obs;
  late SharedPreferences _prefs;

  // التعديل هنا: استخدام Get.find
  final AuthRemoteData _authRemoteData = AuthRemoteData(api: Get.find<Api>());
  StatuesRequest statuesRequest = StatuesRequest.none;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    selectedLanguage.value = _prefs.getString('selectedLanguage') ?? 'ar';
    isDarkMode.value = _prefs.getBool('isDarkMode') ?? false;
    await S.load(Locale(selectedLanguage.value));
    Get.updateLocale(Locale(selectedLanguage.value));
    update();
  }

  Future<void> changeLanguage(String languageCode) async {
    selectedLanguage.value = languageCode;
    await _prefs.setString('selectedLanguage', languageCode);

    // Load the new language
    await S.load(Locale(languageCode));

    // Update GetX locale
    Get.updateLocale(Locale(languageCode));

    // THIS IS CRUCIAL: Force rebuild of the entire app
    update();
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    await _prefs.setBool('isDarkMode', value);
    pref = value;
    changeTheme();
    update();
  }

  getDataUser() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _authRemoteData.getUserProfile(
       );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      if (response['code'] == "404") {
      } else {
        Map<String, dynamic> responseBody = response;
        sharedPreferences!.setString("name", responseBody['data']['name']);
        sharedPreferences!.setString("bio", responseBody['data']['bio'] ?? "");
        sharedPreferences!
            .setString("id", responseBody['data']['id'].toString());
        sharedPreferences!
            .setString("img", responseBody['data']['image'] ?? "");
        sharedPreferences!
            .setString("username", responseBody['data']['username']);
        sharedPreferences!.setString("email", responseBody['data']['email']);
        sharedPreferences!.setString(
            "stars", responseBody['data']['number_of_stars'].toString());
        String power = jsonEncode(responseBody['data']['user_power']);
        sharedPreferences!.setString("powermodel", power);
      }
    } else {
                showUserFriendlyError(statuesRequest);

    }update();
  }

  changeTheme() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _authRemoteData.changeTheme();

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      await getDataUser();
    }  else{          showUserFriendlyError(statuesRequest);
}
    update();
  }
}