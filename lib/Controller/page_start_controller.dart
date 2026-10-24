import 'package:google_sign_in/google_sign_in.dart';
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
import 'package:live_chat/Controller/handel_notification.dart';
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

    if (pinChatModel != null && (pinChatModel!.conversationId == id || pinChatModel!.conversation?.id == id)) {
      chatModel.adTitle = pinChatModel!.adTitle ?? chatModel.adTitle;
      chatModel.adLink = pinChatModel!.adLink ?? chatModel.adLink;
      chatModel.adImage = pinChatModel!.adImage ?? chatModel.adImage;
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
  bool isGoogleLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "273991677038-u7opovl31m7lph9uqs3blrg3namnen5a.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  void _saveUserDataAndNavigate(Map<String, dynamic> responseBody) {
    try {
      sharedPreferences!.remove("deviceId");
      String? deviceId = sharedPreferences!.getString("deviceId");

      if (deviceId == null || deviceId.isEmpty) {
        const uuid = Uuid();
        deviceId = uuid.v4();
        sharedPreferences!.setString("deviceId", deviceId);
        log("✅ تم إنشاء وحفظ UUID جديد: ${sharedPreferences!.getString("deviceId")}");
      } else {
        log("⚡ الـ UUID موجود بالفعل: $deviceId");
      }
    } catch (e) {
      log("❌ Error generating/saving UUID: $e");
    }

    final data = (responseBody['data'] is Map)
        ? responseBody['data']
        : responseBody;

    sharedPreferences!.setString("name", data['name']?.toString() ?? "");
    sharedPreferences!.setString("bio", data['bio']?.toString() ?? "");
    sharedPreferences!.setString("id", data['id']?.toString() ?? "");
    sharedPreferences!.setString("img", data['image']?.toString() ?? "");
    sharedPreferences!.setString("username", data['username']?.toString() ?? "");
    sharedPreferences!.setString("email", data['email']?.toString() ?? "");
    sharedPreferences!.setString(
        "stars", (data['number_of_stars'] ?? 0).toString());
    sharedPreferences!.setString("token", data['token']?.toString() ?? "");
    if (data['user_power'] != null) {
      String power = jsonEncode(data['user_power']);
      sharedPreferences!.setString("powermodel", power);
    }
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

  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading = true;
      update();

      // Sign out first to ensure the Google account chooser appears
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        // User closed or cancelled the Google prompt
        log("Google Sign-In cancelled by user");
        isGoogleLoading = false;
        update();
        return;
      }

      final GoogleSignInAuthentication googleAuthData =
          await googleAccount.authentication;

      final String? idToken = googleAuthData.idToken;
      if (idToken == null || idToken.isEmpty) {
        log("Google Sign-In failed: idToken is null or empty");
        showUserFriendlyError(
          StatuesRequest.badRequestException,
          customMessage: Get.locale?.languageCode == 'ar'
              ? "تعذر الحصول على رمز التحقق من Google، يرجى المحاولة مرة أخرى."
              : "Could not retrieve Google ID token, please try again.",
        );
        return;
      }

      log("Google user retrieved: email=${googleAccount.email}, hasIdToken=true");

      // Ensure device token exists
      String fcmToken = sharedPreferences?.getString("deviceToken") ?? "";
      if (fcmToken.isEmpty) {
        try {
          fcmToken = (await FirebaseMessaging.instance.getToken()) ?? "";
          if (fcmToken.isNotEmpty) {
            sharedPreferences?.setString("deviceToken", fcmToken);
          }
        } catch (e) {
          log("Error fetching FCM token: $e");
        }
      }

      var response = await _authRemoteData.googleAuth(
        credential: idToken,
        fcmToken: fcmToken,
      );

      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        if (response['code'] == 404 ||
            response['code'] == "404" ||
            response['status'] == 'error') {
          showUserFriendlyError(
            StatuesRequest.badRequestException,
            customMessage: response['message']?.toString() ??
                (Get.locale?.languageCode == 'ar'
                    ? "فشل تسجيل الدخول باستخدام حساب Google"
                    : "Google authentication failed"),
          );
        } else {
          final data = response['data'] is Map ? response['data'] : response;
          final String status = data['status']?.toString().toLowerCase() ?? '';

          if (status == 'authenticated') {
            log("Google Login Successful (authenticated): $response");
            _saveUserDataAndNavigate(response);
          } else if (status == 'otp_required') {
            log("Google Sign-Up OTP Required: $response");
            final email = data['email']?.toString() ?? googleAccount.email;
            emailController.text = email;
            verifyCode = '';
            updateSheet('verifyLogin');
            Get.snackbar(
              Get.locale?.languageCode == 'ar'
                  ? "تم إرسال كود التحقق"
                  : "Verification Code Sent",
              Get.locale?.languageCode == 'ar'
                  ? "تم إرسال رمز التحقق إلى بريدك الإلكتروني ($email)"
                  : "A verification code has been sent to $email",
              backgroundColor: AppColors.secondaryColor,
              colorText: Colors.white,
              borderRadius: 16,
              margin: const EdgeInsets.all(12),
              duration: const Duration(seconds: 4),
              snackPosition: SnackPosition.TOP,
              icon: const Icon(Icons.mark_email_read_rounded,
                  color: Colors.white),
            );
          } else if (data['token'] != null &&
              data['token'].toString().isNotEmpty) {
            // Direct token fallback
            log("Google Login Successful (direct token): $response");
            _saveUserDataAndNavigate(response);
          } else {
            showUserFriendlyError(
              StatuesRequest.badRequestException,
              customMessage: response['message']?.toString() ??
                  (Get.locale?.languageCode == 'ar'
                      ? "استجابة غير متوقعة من الخادم"
                      : "Unexpected response from server"),
            );
          }
        }
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ??
              (Get.locale?.languageCode == 'ar'
                  ? "البيانات المدخلة غير صالحة"
                  : "Unprocessable entity"),
        );
      } else {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ??
              (Get.locale?.languageCode == 'ar'
                  ? "فشل الاتصال بالخادم، يرجى المحاولة لاحقاً"
                  : "Server connection failed"),
        );
      }
    } catch (e, stack) {
      log("Exception in signInWithGoogle: $e\n$stack");
      Get.snackbar(
        Get.locale?.languageCode == 'ar' ? "تنبيه" : "Notice",
        Get.locale?.languageCode == 'ar'
            ? "تعذر إتمام تسجيل الدخول باستخدام Google، يرجى المحاولة مرة أخرى."
            : "Could not complete Google Sign-In, please try again.",
        backgroundColor: AppColors.redColor,
        colorText: AppColors.blackTextColor,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGoogleLoading = false;
      update();
    }
  }
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
        if (response['status'] == 'error' || response['code'] == 404 || response['code'] == "404") {
          showUserFriendlyError(
            StatuesRequest.badRequestException,
            customMessage: response['message']?.toString() ?? S.of(Get.context!).emailError,
          );
        } else {
          updateSheet('verifyLogin');
        }
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ?? S.of(Get.context!).emailError,
        );
      } else {
        showUserFriendlyError(statuesRequest, customMessage: Api.serverMessage);
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
      if (response['status'] == 'error' || response['code'] == 404 || response['code'] == "404") {
        showUserFriendlyError(
          StatuesRequest.badRequestException,
          customMessage: response['message']?.toString(),
        );
      } else {
        userNameController.text != ""
            ? updateSheet('verifyRegister')
            : updateSheet('verifyLogin');
      }
    } else {
      showUserFriendlyError(statuesRequest, customMessage: Api.serverMessage);
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
      if (response['status'] == 'error' || response['code'] == 404 || response['code'] == "404") {
        showUserFriendlyError(
          StatuesRequest.badRequestException,
          customMessage: response['message']?.toString(),
        );
      } else {
        snackBarSuccess(message: S.of(Get.context!).successResend);
      }
    } else {
      showUserFriendlyError(statuesRequest, customMessage: Api.serverMessage);
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
        if (response['status'] == 'error' || response['code'] == 404 || response['code'] == "404") {
          showUserFriendlyError(
            StatuesRequest.badRequestException,
            customMessage: response['message']?.toString() ?? S.of(Get.context!).registerError,
          );
        } else {
          updateSheet('verifyRegister');
        }
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ?? S.of(Get.context!).registerError,
        );
      } else {
        showUserFriendlyError(statuesRequest, customMessage: Api.serverMessage);
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
        if (response['code'] == 404 || response['code'] == "404" || response['status'] == 'error') {
          showUserFriendlyError(
            StatuesRequest.badRequestException,
            customMessage: response['message']?.toString() ?? S.of(Get.context!).otpError,
          );
        } else {
          _saveUserDataAndNavigate(response);
        }
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ?? S.of(Get.context!).otpError,
        );
      } else {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ?? S.of(Get.context!).otpError,
        );
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
        if (response['code'] == 404 || response['code'] == "404" || response['status'] == 'error') {
          showUserFriendlyError(
            StatuesRequest.badRequestException,
            customMessage: response['message']?.toString() ?? S.of(Get.context!).otpError,
          );
        } else {
          _saveUserDataAndNavigate(response);
        }
      } else if (statuesRequest == StatuesRequest.unprocessableException) {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ?? S.of(Get.context!).otpError,
        );
      } else {
        showUserFriendlyError(
          statuesRequest,
          customMessage: Api.serverMessage ?? S.of(Get.context!).otpError,
        );
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseNotification().checkAndRequestNotificationPermission();
    });

    super.onInit();
  }
}
