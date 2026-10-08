import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyAccountController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;
  final RxString profileImagePath = ''.obs;
  final RxString selectedGender = ''.obs;

  // التعديل هنا: Get.find بدلاً من Get.put
  // ignore: unused_field
  final Api _api = Get.find<Api>();

  List<String> get genderOptions => [
        S.of(Get.context!).male,
        S.of(Get.context!).female,
        S.of(Get.context!).other,
      ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      nameController.text = prefs.getString('name') ?? '';
      usernameController.text = prefs.getString('username') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      countryController.text = prefs.getString('user_country') ?? '';
      ageController.text = prefs.getString('user_age') ?? '';
      phoneController.text = prefs.getString('user_phone') ?? '';
      selectedGender.value = prefs.getString('user_gender') ?? '';
      profileImagePath.value = prefs.getString('profile_image_path') ?? '';
    } catch (e) {
      showErrorSnackBar(S.of(Get.context!).failed_to_load_user_data);
    }
  }

  Future<void> saveUserData() async {
    if (!validateInputs()) return;

    isLoading.value = true;

    try {
      final token = sharedPreferences!.getString('token');
      if (token == null) {
        showErrorSnackBar('Authentication token not found');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppApi.updateProfileUrl),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Lang': sharedPreferences!.getString("local") == "en" ? "en" : "ar",
      });

      request.fields['name'] = nameController.text.trim();
      request.fields['bio'] = bioController.text.trim();
      request.fields['username'] = usernameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['phone'] = phoneController.text.trim();
      request.fields['age'] = ageController.text.trim();
      request.fields['country_id'] = '1';

      String genderValue = '';
      if (selectedGender.value == S.of(Get.context!).male) {
        genderValue = 'male';
      } else if (selectedGender.value == S.of(Get.context!).female) {
        genderValue = 'female';
      } else if (selectedGender.value == S.of(Get.context!).other) {
        genderValue = 'other';
      }
      if (genderValue.isNotEmpty) {
        request.fields['gender'] = genderValue;
      }

      if (profileImagePath.value.isNotEmpty &&
          File(profileImagePath.value).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', profileImagePath.value),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = json.decode(responseBody);

      log(response.toString());
      log(decodedResponse.toString());
      if (response.statusCode == 200 &&
          decodedResponse['status'] == 'success') {
        await updateLocalStorage(decodedResponse['data']);
        showSuccessSnackBar(S.of(Get.context!).profile_updated_successfully);
      } else {
        showErrorSnackBar(decodedResponse['message'] ?? 'Update failed');
      }
    } catch (e) {
      showErrorSnackBar(S.of(Get.context!).failed_to_save_profile);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLocalStorage(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', userData['name'] ?? '');
    await prefs.setString('bio', userData['bio'] ?? '');
    await prefs.setString('username', userData['username'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('user_phone', userData['phone'] ?? '');
    await prefs.setString('user_age', userData['age']?.toString() ?? '');
    await prefs.setString('user_gender', userData['gender'] ?? '');
    await prefs.setString('user_country', userData['country_name'] ?? '');
    String power = jsonEncode(userData['user_power']);
    sharedPreferences!.setString("powermodel", power);
    if (userData['image'] != null && userData['image'].toString().isNotEmpty) {
      await prefs.setString('img', userData['image']);
    }

    if (profileImagePath.isNotEmpty) {
      await prefs.setString('profile_image_path', profileImagePath.value);
    }
  }

  bool validateInputs() {
    if (nameController.text.trim().isEmpty) {
      showErrorSnackBar(S.of(Get.context!).name_cannot_be_empty);
      return false;
    }
    if (emailController.text.trim().isEmpty ||
        !isValidEmail(emailController.text)) {
      showErrorSnackBar(S.of(Get.context!).please_enter_valid_email);
      return false;
    }
    if (ageController.text.isNotEmpty &&
        int.tryParse(ageController.text) == null) {
      showErrorSnackBar(S.of(Get.context!).please_enter_valid_age);
      return false;
    }
    return true;
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void showSuccessSnackBar(String message) {
    Get.snackbar(
      S.of(Get.context!).success,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void showErrorSnackBar(String message) {
    Get.snackbar(
      S.of(Get.context!).error,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      showErrorSnackBar(S.of(Get.context!).error_picking_image);
    }
  }
}
