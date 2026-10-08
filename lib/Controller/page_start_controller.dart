// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/chats_controllers.dart';
import 'package:live_chat/Controller/main_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/auth_source.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/pin_chat_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/settings/capapiltes.dart';
import 'package:live_chat/View/Screens/settings/language_view.dart';
import 'package:live_chat/View/Screens/settings/my_account_view.dart';
import 'package:live_chat/View/Screens/settings/night_mode.dart';
import 'package:live_chat/View/Screens/settings/notification_view.dart';
import 'package:live_chat/View/Screens/settings/privacy.dart';
import 'package:live_chat/View/Screens/settings/term_condation.dart';

import 'package:live_chat/View/Screens/suggession%20friends/suggession%20friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/show_bottom_sheet.dart';
import 'package:live_chat/View/Widget/shared_chats_screen.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:uuid/uuid.dart';

class PageStartController extends GetxController {
  final mainController = Get.put(MainController());

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  void navigateToPrivateChats() {
    Get.put(PrivateChatsController());
    Get.to(
      () => SharedChatsScreen<PrivateChatsController>(
          title: S.of(Get.context!).yourPrivateChats),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
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
    Get.put(UpdatedChatsController());
    Get.to(
      () => SharedChatsScreen<UpdatedChatsController>(
        title: S.of(Get.context!).updated_chats,
      ),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
    );
  }

  void navigateToAnotherChats() {
    Get.put(AnotherChatsController());
    Get.to(
      () => SharedChatsScreen<AnotherChatsController>(
        title: S.of(Get.context!).another_chats,
      ),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
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

  Future<bool> joinToChat({required chatId}) async {
    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.joinToCgat(
      chatId: chatId,
    );

    statuesRequest = handlingData(response);
    log("response join to chhat  :: $response");

    if (statuesRequest == StatuesRequest.success) {
      update();
      return true;
    } else if (statuesRequest == StatuesRequest.forbiddenException) {
      Get.snackbar(
        S.of(Get.context!).underReview,
        S.of(Get.context!).waitForAccept,
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        icon: const Icon(
          Icons.access_time_rounded,
          color: Colors.white,
          size: 28,
        ),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
      update();
      return false;
    } else {
      showUserFriendlyError(statuesRequest);
      update();
      return false;
    }
  }

  onPressPinChat(
      {required UserChatModel chatModel,
      required bool isGust,
      required id}) async {
    if (chatModel.status == "Public" || chatModel.status == "Private") {
      bool canEnter = await joinToChat(
        chatId: id,
      );

      if (!canEnter) return;
    }

    print("id >>$id");
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
      {required UserChatModel chatModel,
      required bool isGust,
      required id}) async {
    if (chatModel.status == "Public" || chatModel.status == "Private") {
      bool canEnter = await joinToChat(
        chatId: id,
      );

      if (!canEnter) return;
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
      statuesRequestGetData = StatuesRequest.loading;
      update();
      mainController.getAds();

      await getPinChat();
      await getRecentChats();
      await getSystemChats();
      statuesRequestGetData = StatuesRequest.success;
      update();
    } catch (error) {
      statuesRequestGetData = StatuesRequest.serverException;
      update();
    }
  }

  getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? tokenDevice = await messaging.getToken();
    sharedPreferences!.setString("deviceToken", tokenDevice!);
    log("   👌👌👌deviceToken: ${sharedPreferences!.getString("deviceToken")}");
    try {
      String? deviceId = sharedPreferences!.getString("deviceId");

      if (deviceId == null || deviceId.isEmpty) {
        const uuid = Uuid();
        deviceId = uuid.v4();

        await sharedPreferences!.setString("deviceId", deviceId);

        log("✅ تم إنشاء وحفظ UUID جديد: ${sharedPreferences!.getString("deviceId")}");
      } else {
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
        updateSheet('verifyLogin');
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        log("safdfce error ");
        snackBarError(message: S.of(Get.context!).emailError);
      } else {
        showUserFriendlyError(statuesRequest);
      }
    }
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
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
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
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
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
      } else {
        showUserFriendlyError(statuesRequest);
      }
    }
    update();
  }

  verifyLogin() async {
    if (verifyCode.length == 6) {
      print("email >>>>>>>>>  ::${emailController.text}");
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
          sharedPreferences!.remove("deviceId");
           try {
      String? deviceId = sharedPreferences!.getString("deviceId");

      if (deviceId == null || deviceId.isEmpty) {
        const uuid = Uuid();
        deviceId = uuid.v4();

        await sharedPreferences!.setString("deviceId", deviceId);

        log("✅ تم إنشاء وحفظ UUID جديد: ${sharedPreferences!.getString("deviceId")}");
      } else {
        log("⚡ الـ UUID موجود بالفعل: $deviceId");
      }
    } catch (e) {
      log("❌ Error generating/saving UUID: $e");
    }
          Map<String, dynamic> responseBody = response;
          log("loginnn >> $responseBody");

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
          
          // Clear Guest Session Data upon successful login
          sharedPreferences!.remove("idGust");
          sharedPreferences!.remove("usernameGust");
          
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
      } else {
        showUserFriendlyError(statuesRequest);
      }
    }
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
          sharedPreferences!
              .setString("id", responseBody['data']['id'].toString());
          sharedPreferences!.setString("name", responseBody['data']['name']);
          sharedPreferences!
              .setString("img", responseBody['data']['image'] ?? "");
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
      } else {
        showUserFriendlyError(statuesRequest);
      }
    }
    update();
  }

  StatuesRequest statuesRequestGetData = StatuesRequest.none;
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());

  PinChatModel? pinChatModel;
  List<UserChatModel> recentChats = [];
  List<UserChatModel> systemChats = [];

// 🌟 الدالة المعدلة للـ Pin Chat للفلترة بالوقت والتاريخ (ساعة كاملة لكل فترة)
  getPinChat() async {
    statuesRequestGetData = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getPinChatGust();

    statuesRequestGetData = handlingData(response);

    if (statuesRequestGetData == StatuesRequest.success) {
      try {
        final List responseBody = response['data'];

        DateTime now = DateTime.now();
        String todayString =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

        int currentHour12 =
            now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        String currentPeriod = now.hour >= 12 ? "PM" : "AM";

        var validPin = responseBody.firstWhere(
          (element) {
            if (element['conversation'] == null) return false;

            DateTime parsedDate =
                DateTime.parse(element['pin_date'].toString()).toLocal();
            String pinDate =
                "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
            List pinHours = [];
            if (element['pin_hours'] != null) {
              if (element['pin_hours'] is String) {
                try {
                  pinHours = jsonDecode(element['pin_hours']);
                } catch (e) {
                  log("❌ Error decoding pin_hours string: $e");
                }
              } else if (element['pin_hours'] is List) {
                pinHours = element['pin_hours'];
              }
            }
            bool isTimeValid = pinHours.any((hourObj) {
              int h = int.parse(hourObj['hour'].toString());
              String p = hourObj['period'].toString().toUpperCase();

              return h == currentHour12 && p == currentPeriod;
            });

            return pinDate == todayString && isTimeValid;
          },
          orElse: () => null,
        );

        if (validPin != null) {
          pinChatModel = PinChatModel.fromJson(validPin);
          log("✅ Pinned Chat is active NOW (Hour: $currentHour12 $currentPeriod). Parsed successfully.");
        } else {
          pinChatModel = null;
          log("⚠️ No pinned chats active at this specific hour ($currentHour12 $currentPeriod).");
        }
      } catch (e, stacktrace) {
        log("❌ Pinned Chat Parsing Error: $e");
        log("🔍 $stacktrace");
      }
    } else {
      showUserFriendlyError(statuesRequestGetData);
    }

    update();
  }

  getRecentChats() async {
    recentChats.clear();
    statuesRequestGetData = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getRecentChatGust(perPage: 2);

    log("Recent chats response: $response");
    statuesRequestGetData = handlingData(response);

    if (statuesRequestGetData == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      recentChats.addAll(responseBody.map(
        (e) => UserChatModel.fromJson(e),
      ));
      log("Recent chats loaded: ${recentChats.length} items");
    } else {
      showUserFriendlyError(statuesRequestGetData);
    }
    update();
  }

  getSystemChats() async {
    systemChats.clear();
    statuesRequestGetData = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getSystemChatsGust(perPage: 5);

    log("System chats response: $response");
    statuesRequestGetData = handlingData(response);

    if (statuesRequestGetData == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      systemChats.addAll(responseBody.map(
        (e) => UserChatModel.fromJson(e),
      ));
      log("System chats loaded: ${systemChats.length} items");
    } else {
      showUserFriendlyError(statuesRequestGetData);
    }
    update();
  }

  @override
  void onInit() async {
    await getToken();
    mainController.getAds();

    getPinChat();
    getRecentChats();
    getSystemChats();
    super.onInit();
  }
}
