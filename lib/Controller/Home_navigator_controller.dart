// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/main_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/auth_source.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/friend_suggest_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Screens/settings/term_condation.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/private%20chats/private_chats.dart';
import 'package:live_chat/View/Screens/settings/capapiltes.dart';
import 'package:live_chat/View/Screens/settings/language_view.dart';
import 'package:live_chat/View/Screens/settings/my_account_view.dart';
import 'package:live_chat/View/Screens/settings/night_mode.dart';
import 'package:live_chat/View/Screens/settings/notification_view.dart';
import 'package:live_chat/View/Screens/settings/privacy.dart';
import 'package:live_chat/View/Screens/splash/splash_screen.dart';
import 'package:live_chat/View/Screens/start%20page/another_chats.dart';
import 'package:live_chat/View/Screens/start%20page/page_start.dart';
import 'package:live_chat/View/Screens/start%20page/updated_chats.dart';
import 'package:live_chat/View/Screens/suggession%20friends/suggession%20friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';

class HomeNavigationController extends GetxController {
  static HomeNavigationController get to => Get.find();
  final controller = Get.put(MainController());
  StatuesRequest statuesRequest = StatuesRequest.none;

  // التعديلات هنا: استخدام Get.find
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());
  final AuthRemoteData _authRemoteData = AuthRemoteData(api: Get.find<Api>());

  UserChatModel? userChatModel;
  UserChatModel? userMyChatModel;
  List<SuggestFreindModel> friends = [];
  List<SuggestFreindModel> friendsSuggestion = [];
  List<UserChatModel> systemChats = [];

  Future<void> updateChatUI() async {
    controller.getAds();
    update();
  }

  Future<void> updateUI() async {
    controller.getAds();
    getMyChat();
    getPinChat();
    getFriends();
    getfriendesSuggestion();
    update();
  }

  getPinChat() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getPinChatGust(
        deviceToken: sharedPreferences!.getString("deviceId") ?? "");

    statuesRequest = handlingData(response);
    log("pin chatttt :::: $response");

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response;

      log("pin chatttt :::: $responseBody");
      if (responseBody != null) {
        userChatModel = UserChatModel.fromJson(responseBody);
      }
    }  else{
                showUserFriendlyError(statuesRequest);

    }
    update();
  }

  logOut() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _authRemoteData.logOut(
      token: sharedPreferences!.getString("token"),
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      sharedPreferences!.clear();
      Get.offAll(
        const PageStart(),
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    }  else {
                showUserFriendlyError(statuesRequest);

    }
    update();
  }

  getMyChat() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getuserChats(
        page: 1, perPage: 15, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response['data'];
      log(responseBody.toString());
      if (responseBody != null &&
          responseBody is List &&
          responseBody.isNotEmpty) {
        List<UserChatModel> newChats = responseBody
            .map(
              (e) => UserChatModel.fromJson(e),
            )
            .where(
              (element) => ((element.status == "Public" ||
                      element.status == "Private") ||
                  (element.lastMessage != null &&
                      element.status != "Public" &&
                      element.status != "Private")),
            )
            .toList();
        if (newChats.isNotEmpty) {
          userMyChatModel = newChats[0];
        }
      } else {
        log("No chats found in response['data']");
        userMyChatModel = null;
      }
    } else {
                showUserFriendlyError(statuesRequest);

    }
    update();
  }

  getFriends() async {
    friends.clear();
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getFriende(
        page: 1, perPage: 15, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      friends
          .addAll(responseBody.map((e) => SuggestFreindModel.fromJson(e)).where(
                (element) => element.requestStatus == "friends",
              ));
    } else{
                showUserFriendlyError(statuesRequest);

    }update();
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
    }  else {          showUserFriendlyError(statuesRequest);
}
    update();
  }

  getfriendesSuggestion() async {
    friendsSuggestion.clear();
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getFriendeRecommendation(
        page: 1, perPage: 3, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];
      friendsSuggestion
          .addAll(responseBody.map((e) => SuggestFreindModel.fromJson(e)));
    } 
    else{
                showUserFriendlyError(statuesRequest);

    }
    // else if (statuesRequest == StatuesRequest.unauthorizedException) {
    //   messageErrorWithButton(
    //       S.of(Get.context!).error, S.of(Get.context!).errorLogin, () {
    //     sharedPreferences!.clear();

    //     Get.offAll(() => const SplashScreen());
    //   }, S.of(Get.context!).log_in);
    // }

    update();
  }

  Future<List<UserChatModel>> getSystemChats() async {
    systemChats.clear();
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getSystemChatsGust(
        perPage: 8, deviceToken: sharedPreferences!.getString("deviceId"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];
      systemChats.addAll(responseBody.map((e) => UserChatModel.fromJson(e)));
    }else{
                showUserFriendlyError(statuesRequest);

    }
    return systemChats;
  }

  sendFriendRequest({required friendID, required index}) async {
    var response = await _chatsRemoteData.sendFriendRequest(
        friendId: friendID, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      friendsSuggestion[index] = SuggestFreindModel(
          id: friendsSuggestion[index].id,
          image: friendsSuggestion[index].image,
          name: friendsSuggestion[index].name,
          username: friendsSuggestion[index].username,
          power: friendsSuggestion[index].power,
          requestStatus: friendsSuggestion[index].requestStatus == "none"
              ? "request_sent"
              : "none");
      log("Addddddddddddddddddd");
      update();
    } else{
                showUserFriendlyError(statuesRequest);

    } update();
  }

  acceptOrRejectFriend({required friendID, required status}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptOrRejectRequestFriend(
        status: status,
        friendId: friendID,
        token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
    }  else {          showUserFriendlyError(statuesRequest);
}
    update();
  }

  createChatFriend({required friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.createChatFriend(
        friendId: friendID, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response['data'];
      if (responseBody != null) {
        navigateToChats(userchat: UserChatModel.fromJson(responseBody));
      }
    }  else {
                showUserFriendlyError(statuesRequest);

    }
    update();
  }

  final RxInt _currentPageIndex = 0.obs;
  int get currentPageIndex => _currentPageIndex.value;

  void changePage(int index) {
    _currentPageIndex.value = index;
    update();
  }

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

  @override
  void onInit() {
    controller.getAds();
    log(sharedPreferences!.getString("powermodel").toString());
    getFriends();
    getMyChat();
    getPinChat();
    getfriendesSuggestion();
    super.onInit();
  }
}
