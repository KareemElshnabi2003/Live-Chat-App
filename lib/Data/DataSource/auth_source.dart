import 'dart:developer';
import 'dart:io';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class AuthRemoteData {
  final Api api; // إضافة final
  AuthRemoteData({required this.api});

  String _getMobileTheme() {
    return (sharedPreferences?.getBool("isDarkMode") ?? false)
        ? "dark"
        : "light";
  }

  login({required email}) async {
    var response = await api.postData(AppApi.loginUrl, {
      "email": email,
      "remember": 1,
    });
    return response.fold((l) => l, (r) => r);
  }

  register({required name, required userName, required email}) async {
    var response = await api.postData(AppApi.registerUrl,
        {"email": email, "name": name, "username": userName});
    return response.fold((l) => l, (r) => r);
  }

  changeTheme() async {
    var response = await api.postData(AppApi.changeThemeUrl, {
      "mobile_theme": _getMobileTheme(),
    });
    return response.fold((l) => l, (r) => r);
  }

  checkOTP({required otp, required email, required fcmToken}) async {
    log(email);
    var response = await api.postData(AppApi.checkOTPUrl, {
      "email": email,
      "token": otp,
      "fcm_token": fcmToken,
      "mobile_theme": _getMobileTheme(),
    });
    return response.fold((l) => l, (r) => r);
  }

  sendOTP({required email}) async {
    var response = await api.postData(AppApi.sendOTPUrl, {"email": email});
    return response.fold((l) => l, (r) => r);
  }

  resendOTP({required email}) async {
    var response = await api.postData(AppApi.resendOTPUrl, {"email": email});
    return response.fold((l) => l, (r) => r);
  }

  verifyGust({required deviceToken}) async {
    var response =
        await api.postData(AppApi.gustUrl, {"device_id": deviceToken});
    return response.fold((l) => l, (r) => r);
  }

  updateProfile({
    required String token,
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
      if (countryId != null && countryId.isNotEmpty)
        data['country_id'] = countryId;

      var response = await api.postRequestwithfile(
          AppApi.updateProfileUrl, data, image, null);
      log(response.toString());
      return response.fold(
          (l) => throw Exception('Failed to update profile: $l'), (r) => r);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  getUserProfile({required String token}) async {
    var response = await api.getData(AppApi.getProfileUrl);
    return response.fold((l) => l, (r) => r);
  }

  logOut({required token}) async {
    var response = await api.getData(AppApi.logoutUrl);
    return response.fold((l) => l, (r) => r);
  }

  deleteAccount({required String token}) async {
    var response = await api.deleteData(AppApi.deleteAccUrl);
    return response.fold((l) => l, (r) => r);
  }

  getUserPowers({required String token}) async {
    var response = await api.getData(AppApi.getUserPower);
    return response.fold((l) => l, (r) => r);
  }
}
