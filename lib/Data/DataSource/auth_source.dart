import 'dart:developer';
import 'dart:io';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class AuthRemoteData {
  final Api api; // إضافة final
  AuthRemoteData({required this.api});




  final String deviceId=sharedPreferences!.getString("deviceId")??"";
  String _getMobileTheme() {
    return (sharedPreferences?.getBool("isDarkMode") ?? false)
        ? "dark"
        : "light";
  }

  login({required email}) async {
    var response = await api.postData("${AppApi.loginUrl}?device_id=$deviceId", {
      "email": email,
      "remember": 1,
    });
    return response.fold((l) => l, (r) => r);
  }

  register({required name, required userName, required email}) async {
    var response = await api.postData("${AppApi.registerUrl}?device_id=$deviceId",
        {"email": email, "name": name, "username": userName});
    return response.fold((l) => l, (r) => r);
  }

  changeTheme() async {
    var response = await api.postData("${AppApi.changeThemeUrl}?device_id=$deviceId", {
      "mobile_theme": _getMobileTheme(),
    });
    return response.fold((l) => l, (r) => r);
  }

  checkOTP({required otp, required email, required fcmToken}) async {
    log(email);
    var response = await api.postData("${AppApi.checkOTPUrl}?device_id=$deviceId", {
      "email": email,
      "token": otp,
      "fcm_token": fcmToken,
      "mobile_theme": _getMobileTheme(),
    });
    return response.fold((l) => l, (r) => r);
  }

  sendOTP({required email}) async {
    var response = await api.postData("${AppApi.sendOTPUrl}?device_id=$deviceId", {"email": email});
    return response.fold((l) => l, (r) => r);
  }

  resendOTP({required email}) async {
    var response = await api.postData("${AppApi.resendOTPUrl}?device_id=$deviceId", {"email": email});
    return response.fold((l) => l, (r) => r);
  }

  verifyGust() async {
    var response =
        await api.postData(AppApi.gustUrl, {"device_id": deviceId});
    return response.fold((l) => l, (r) => r);
  }

  updateProfile({

    required String name,
    required String username,
    required String email,
    String? phone,
    String? age,
    String? gender,
    String? countryId,
    File? image,
  }) async {
    log("update");
    try {
      Map<String, dynamic> data = {
        'name': name,
        'username': username,
        'email': email,
      };

      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (age != null && age.isNotEmpty) data['age'] = age;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (countryId != null && countryId.isNotEmpty) {
        data['country_id'] = countryId;
      }

      var response = await api.postRequestwithfile(
          "${AppApi.updateProfileUrl}?device_id=$deviceId", data, image, null);
      log(response.toString());
      return response.fold(
          (l) => throw Exception('Failed to update profile: $l'), (r) => r);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  getUserProfile() async {
    var response = await api.getData("${AppApi.getProfileUrl}?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  logOut() async {
    var response = await api.postData("${AppApi.logoutUrl}?device_id=$deviceId", {});
    return response.fold((l) => l, (r) => r);
  }

  deleteAccount() async {
    var response = await api.deleteData("${AppApi.deleteAccUrl}?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  getUserPowers() async {
    var response = await api.getData("${AppApi.getUserPower}?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }
}
