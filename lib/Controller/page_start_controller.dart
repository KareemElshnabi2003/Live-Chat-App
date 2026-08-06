import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/main_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/auth_source.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Screens/private%20chats/private_chats.dart';
import 'package:live_chat/View/Screens/settings/capapiltes.dart';
import 'package:live_chat/View/Screens/settings/language_view.dart';
import 'package:live_chat/View/Screens/settings/my_account_view.dart';
import 'package:live_chat/View/Screens/settings/night_mode.dart';
import 'package:live_chat/View/Screens/settings/notification_view.dart';
import 'package:live_chat/View/Screens/settings/privacy.dart';
import 'package:live_chat/View/Screens/settings/term_condation.dart';
import 'package:live_chat/View/Screens/start%20page/another_chats.dart';
import 'package:live_chat/View/Screens/start%20page/updated_chats.dart';
import 'package:live_chat/View/Screens/suggession%20friends/suggession%20friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/show_bottom_sheet.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:uuid/uuid.dart';

class PageStartController extends GetxController {
  final mainController = Get.put(MainController());

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  // Add this method to your PageStartController class
  void navigateToPrivateChats() {
    Get.to(
      () => PrivateChats(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToFriends() {
    Get.to(
      () => Friends(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToNotification() {
    Get.to(
      () => NotificationView(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToLangauge() {
    Get.to(
      () => LanguageView(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToNightMode() {
    Get.to(
      () => NightModeView(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToMyaccount() {
    Get.to(
      () => MyAccountView(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToCapapiltes() {
    Get.to(
      () => const Capabilities(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToChats({UserChatModel? userchat}) {
    Get.to(
      () => ChatView(
        isGust: false,
        isPin: false,
        userChatModel: userchat,
      ),
      arguments: {"chatId": userchat?.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToTerm() {
    Get.to(
      () => const TermCondation(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToprivacy() {
    Get.to(
      () => const Privacy(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToSuggestedFriends() {
    Get.to(
      () => SuggessionChat(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToUpdatedChat() {
    Get.to(
      () => UpdatedChats(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToAnotherChats() {
    Get.to(
      () => AnotherChats(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateToRequests() {
    Get.off(
      () => Requests(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateTocreatechat() {
    Get.to(
      () => CreateChat(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  onPressCreateChat() {
    Get.to(
      () => CreateChat(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  joinToChat({required chatId, required memberId}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.joinToCgat(
        chatId: chatId,
        memberId: memberId,
        token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
    }else{          showUserFriendlyError(statuesRequest);
}update();
  }

  onPressPinChat(
      {required UserChatModel chatModel, required bool isGust, required id}) {
    if (chatModel.status == "Public" || chatModel.status == "Private") {
      joinToChat(chatId: id, memberId: sharedPreferences!.getString("id"));
    }
    Get.to(
      () => ChatView(
        userChatModel: chatModel,
        isPin: true,
        isGust: isGust,
      ),
      arguments: {"chatId": id},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  onPressGroubChat(
      {required UserChatModel chatModel, required bool isGust, required id}) {
    if (chatModel.status == "Public" || chatModel.status == "Private") {
      joinToChat(chatId: id, memberId: sharedPreferences!.getString("id"));
    }
    Get.to(
      () => ChatView(
        userChatModel: chatModel,
        isPin: false,
        isGust: isGust,
      ),
      arguments: {"chatId": id},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> refreshData() async {
    try {
      // Set loading state
      statuesRequestGetData = StatuesRequest.loading;
      update();
      mainController.getAds();

      getPinChat();
      getRecentChats();
      getSystemChats();
      // Update the UI
      statuesRequestGetData = StatuesRequest.success;
      update();
    } catch (error) {
      // Handle error
      statuesRequestGetData = StatuesRequest.serverException;
      update();

      // You might want to show an error message
    }
  }

  getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? tokenDevice = await messaging.getToken();
    sharedPreferences!.setString("deviceToken", tokenDevice!);
    log("   deviceToken: ${sharedPreferences!.getString("deviceToken")}");
    try {
      // 1. بنحاول نجيب الـ deviceId لو متخزن قبل كده
      String? deviceId = sharedPreferences!.getString("deviceId");

      // 2. لو بيساوي null (يعني التطبيق لسه بيفتح لأول مرة)
      if (deviceId == null || deviceId.isEmpty) {
        // بنولد UUID جديد بصيغة v4
        const uuid = Uuid();
        deviceId = uuid.v4();

        // بنخزنه في الـ SharedPreferences
        await sharedPreferences!.setString("deviceId", deviceId);

        log("✅ تم إنشاء وحفظ UUID جديد: ${sharedPreferences!.getString("deviceId")}");
      } else {
        // لو موجود أصلاً، هنطبعه بس عشان نتأكد
        log("⚡ الـ UUID موجود بالفعل: $deviceId");
      }
    } catch (e) {
      log("❌ Error generating/saving UUID: $e");
    }
  }

  String verifyCode = '';
  GlobalKey<FormState> formKey = GlobalKey();
  Key imageKey = const ValueKey('Login');
  String sheetName = 'Login';

  void updateSheet(String newName) {
    sheetName = newName;
    imageKey = ValueKey(newName);
    update();
  }

  String? validatorName(String? val) {
    if (val == null || val.isEmpty) {
      return S.of(Get.context!).please_enter_your_name;
    }
    return null;
  }

  String? validatorUserName(String? val) {
    if (val == null || val.isEmpty) {
      return S.of(Get.context!).please_enter_your_name;
    }
    return null;
  }

  String? validatorEmail(String? val) {
    if (val == null || val.isEmpty) {
      return S.of(Get.context!).please_enter_your_email;
    } else if (!val.isEmail) {
      return S.of(Get.context!).please_enter_valid_email;
    }
    return null;
  }

  void onPressLogin(BuildContext context) {
    showBottomSheetWidget(
      context: context,
      onPressSubmit: (String val) {
        verifyCode = val;
        if (sheetName == "verifyLogin") {
          verifyLogin();
        } else {
          verifyRegister();
        }
      },
    );
  }

  snackBarError({message}) {
    Get.snackbar(
      S.of(Get.context!).error,
      message,
      backgroundColor: AppColors.redColor,
      padding: const EdgeInsets.all(10),
      borderRadius: 30,
      colorText: AppColors.blackTextColor,
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  snackBarSuccess({message}) {
    Get.snackbar(
      S.of(Get.context!).success,
      message,
      backgroundColor: Colors.greenAccent,
      padding: const EdgeInsets.all(10),
      borderRadius: 25,
      colorText: AppColors.blackTextColor,
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  StatuesRequest statuesRequest = StatuesRequest.none;
  // التعديل هنا: Get.find بدلاً من Get.put
  final AuthRemoteData _authRemoteData = AuthRemoteData(api: Get.find<Api>());

  login() async {
    if (formKey.currentState!.validate()) {
      statuesRequest = StatuesRequest.loading;
      update();
      var response = await _authRemoteData.login(
        email: emailController.text,
      );

      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        // await sendOTP();
        updateSheet('verifyLogin');
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        log("safdfce error ");

        snackBarError(message: S.of(Get.context!).emailError);
      } else {          showUserFriendlyError(statuesRequest);
}}
    update();
  }

  sendOTP() async {
    log(emailController.text);
    var response = await _authRemoteData.sendOTP(
      email: emailController.text,
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      userNameController.text != ""
          ? updateSheet('verifyRegister')
          : updateSheet('verifyLogin');
    } else{          showUserFriendlyError(statuesRequest);
}update();
  }

  reSendOTP() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _authRemoteData.resendOTP(
      email: emailController.text,
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      snackBarSuccess(message: S.of(Get.context!).successResend);
    } else{
                showUserFriendlyError(statuesRequest);

    }update();
  }

  register() async {
    if (formKey.currentState!.validate()) {
      log(emailController.text);
      log(userNameController.text);
      log(nameController.text);

      statuesRequest = StatuesRequest.loading;
      update();
      var response = await _authRemoteData.register(
          email: emailController.text,
          name: nameController.text,
          userName: userNameController.text);

      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        updateSheet('verifyRegister');
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        snackBarError(message: S.of(Get.context!).registerError);
      } else{          showUserFriendlyError(statuesRequest);
} }
    update();
  }

  verifyLogin() async {
    if (verifyCode.length == 6) {
      log("email ::${emailController.text}");
      statuesRequest = StatuesRequest.loading;
      update();
      var response = await _authRemoteData.checkOTP(
          fcmToken: sharedPreferences!.getString("deviceToken"),
          email: emailController.text,
          otp: verifyCode);

      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        if (response['code'] == "404") {
          snackBarError(message: S.of(Get.context!).otpError);
        } else {
          Map<String, dynamic> responseBody = response;
          sharedPreferences!.setString("name", responseBody['data']['name']);
          sharedPreferences!
              .setString("bio", responseBody['data']['bio'] ?? "");
          sharedPreferences!
              .setString("id", responseBody['data']['id'].toString());
          sharedPreferences!
              .setString("img", responseBody['data']['image'] ?? "");
          sharedPreferences!
              .setString("username", responseBody['data']['username']);
          sharedPreferences!.setString("email", responseBody['data']['email']);
          sharedPreferences!.setString(
              "stars", responseBody['data']['number_of_stars'].toString());
          sharedPreferences!.setString("token", responseBody['data']['token']);
          String power = jsonEncode(responseBody['data']['user_power']);
          sharedPreferences!.setString("powermodel", power);
          log("power?>>>>>>>>> ${responseBody['data']['user_power']}");
          log("power?>>>>>>>>> ${sharedPreferences!.getString("powermodel")!}");
          sharedPreferences!.setString("page", "Home");
          sheetName = "Login";

          Get.offAll(
            () => const HomeView(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
        }
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        snackBarError(message: S.of(Get.context!).otpError);
      } else {          showUserFriendlyError(statuesRequest);
}}
    update();
  }

  verifyRegister() async {
    if (verifyCode.length == 6) {
      statuesRequest = StatuesRequest.loading;
      update();
      var response = await _authRemoteData.checkOTP(
          fcmToken: sharedPreferences!.getString("deviceToken"),
          email: emailController.text,
          otp: verifyCode);

      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        if (response['code'] == 404) {
          snackBarError(message: S.of(Get.context!).otpError);
        } else {
          Map<String, dynamic> responseBody = response;
          sharedPreferences!
              .setString("bio", responseBody['data']['bio'] ?? "");
          sharedPreferences!.setString("name", responseBody['data']['name']);
          sharedPreferences!
              .setString("username", responseBody['data']['username']);
          sharedPreferences!.setString("email", responseBody['data']['email']);
          sharedPreferences!.setString("token", responseBody['data']['token']);
          sharedPreferences!.setString(
              "stars", responseBody['data']['number_of_stars'].toString());
          String power = jsonEncode(responseBody['data']['user_power']);
          sharedPreferences!.setString("powermodel", power);
          sharedPreferences!.setString("page", "Home");
          sheetName = "Login";
          log("power?>>>>>>>>> ${responseBody['data']['user_power']}");
          log("power?>>>>>>>>> ${sharedPreferences!.getString("powermodel")!}");
          Get.offAll(
            () => const HomeView(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
        }
      } else {          showUserFriendlyError(statuesRequest);
} }
    update();
  }

//get chats

  StatuesRequest statuesRequestGetData = StatuesRequest.none;
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());
  UserChatModel? userChatModel;
  List<UserChatModel> recentChats = [];
  List<UserChatModel> systemChats = [];

  getPinChat() async {
    statuesRequestGetData = StatuesRequest.loading;
    update();
    String dToken = sharedPreferences!.getString("deviceId") ?? "";

    var response = await _chatsRemoteData.getPinChatGust(deviceToken: dToken);

    statuesRequestGetData = handlingData(response);

    if (statuesRequestGetData == StatuesRequest.success) {
      try {
        final responseBody = response['data'];

        if (responseBody is List) {
          List<UserChatModel> chatsList =
              responseBody.map((e) => UserChatModel.fromJson(e)).toList();
          print("✅ الداتا اتحولت بنجاح! عدد المحادثات: ${chatsList.length}");
        } else if (responseBody != null) {
          userChatModel = UserChatModel.fromJson(responseBody);
          print("✅ الداتا اتحولت بنجاح كـ Object!");
        }
      } catch (e, stacktrace) {
        print("❌ كارثة في تحويل الداتا (Parsing Error): $e");
        print("🔍 تفاصيل الخطأ: $stacktrace");
      }
    } else if (statuesRequestGetData == StatuesRequest.unprocessableException) {
      log("Unprocessable exception in getPinChat");
    } else if (statuesRequestGetData == StatuesRequest.socketException) {
      log("Socket exception in getPinChat");
    } else if (statuesRequestGetData == StatuesRequest.serverException) {
      log("Server exception in getPinChat");
    } else if (statuesRequestGetData == StatuesRequest.unExpectedException) {
      log("Unexpected exception in getPinChat");
    } else if (statuesRequestGetData == StatuesRequest.defaultException) {
      log("Default exception in getPinChat");
    } else if (statuesRequestGetData == StatuesRequest.serverError) {
      log("Server error in getPinChat");
    } else if (statuesRequestGetData == StatuesRequest.timeoutException) {
      log("Timeout exception in getPinChat");
    } else if (statuesRequestGetData == StatuesRequest.unauthorizedException) {
      log("Unauthorized exception in getPinChat");
    }

    update();
  }

  getRecentChats() async {
    recentChats.clear();
    statuesRequestGetData = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getRecentChatGust(
        perPage: 2, deviceToken: sharedPreferences!.getString("deviceId"));

    log("Recent chats response: $response");
    statuesRequestGetData = handlingData(response);

    if (statuesRequestGetData == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      recentChats.addAll(responseBody.map(
        (e) => UserChatModel.fromJson(e),
      ));
      log("Recent chats loaded: ${recentChats.length} items");
    } else if (statuesRequestGetData == StatuesRequest.unprocessableException) {
      log("Unprocessable exception in getRecentChats");
    } else if (statuesRequestGetData == StatuesRequest.socketException) {
      log("Socket exception in getRecentChats");
    } else if (statuesRequestGetData == StatuesRequest.serverException) {
      log("Server exception in getRecentChats");
    } else if (statuesRequestGetData == StatuesRequest.unExpectedException) {
      log("Unexpected exception in getRecentChats");
    } else if (statuesRequestGetData == StatuesRequest.defaultException) {
      log("Default exception in getRecentChats");
    } else if (statuesRequestGetData == StatuesRequest.serverError) {
      log("Server error in getRecentChats");
    } else if (statuesRequestGetData == StatuesRequest.timeoutException) {
      log("Timeout exception in getRecentChats");
    } else if (statuesRequestGetData == StatuesRequest.unauthorizedException) {
      log("Unauthorized exception in getRecentChats");
    }
    update();
  }

  getSystemChats() async {
    systemChats.clear();
    statuesRequestGetData = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getSystemChatsGust(
        perPage: 5, deviceToken: sharedPreferences!.getString("deviceId"));

    log("System chats response: $response");
    statuesRequestGetData = handlingData(response);

    if (statuesRequestGetData == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      systemChats.addAll(responseBody.map(
        (e) => UserChatModel.fromJson(e),
      ));
      log("System chats loaded: ${systemChats.length} items");
    } else if (statuesRequestGetData == StatuesRequest.unprocessableException) {
      log("Unprocessable exception in getSystemChats");
    } else if (statuesRequestGetData == StatuesRequest.socketException) {
      log("Socket exception in getSystemChats");
    } else if (statuesRequestGetData == StatuesRequest.serverException) {
      log("Server exception in getSystemChats");
    } else if (statuesRequestGetData == StatuesRequest.unExpectedException) {
      log("Unexpected exception in getSystemChats");
    } else if (statuesRequestGetData == StatuesRequest.defaultException) {
      log("Default exception in getSystemChats");
    } else if (statuesRequestGetData == StatuesRequest.serverError) {
      log("Server error in getSystemChats");
    } else if (statuesRequestGetData == StatuesRequest.timeoutException) {
      log("Timeout exception in getSystemChats");
    } else if (statuesRequestGetData == StatuesRequest.unauthorizedException) {
      log("Unauthorized exception in getSystemChats");
    }
    update();
  }

  @override
  void onInit() async {
    await getToken();
    mainController.getAds();

    // getPinChat();
    getRecentChats();
    getSystemChats();
    super.onInit();
  }
}
