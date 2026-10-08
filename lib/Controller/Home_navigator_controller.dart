// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'dart:developer';

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
import 'package:live_chat/Data/Model/friend_suggest_model.dart';
import 'package:live_chat/Data/Model/pin_chat_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Screens/settings/term_condation.dart';
import 'package:live_chat/View/Screens/settings/ads_with_us.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/settings/capapiltes.dart';
import 'package:live_chat/View/Screens/settings/language_view.dart';
import 'package:live_chat/View/Screens/settings/my_account_view.dart';
import 'package:live_chat/View/Screens/settings/night_mode.dart';
import 'package:live_chat/View/Screens/settings/notification_view.dart';
import 'package:live_chat/View/Screens/settings/privacy.dart';
import 'package:live_chat/View/Screens/start%20page/page_start.dart';
import 'package:live_chat/View/Screens/suggession%20friends/suggession%20friends.dart';
import 'package:live_chat/View/Widget/shared_chats_screen.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:uuid/uuid.dart';

class HomeNavigationController extends GetxController {
  static HomeNavigationController get to => Get.find();
  final controller = Get.put(MainController());
  StatuesRequest statuesRequest = StatuesRequest.none;

  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());
  final AuthRemoteData _authRemoteData = AuthRemoteData(api: Get.find<Api>());

  PinChatModel? pinChatModel;
  UserChatModel? generalChatModel;
  UserChatModel? userMyChatModel;
  List<SuggestFreindModel> friends = [];
  List<SuggestFreindModel> friendsSuggestion = [];
  List<UserChatModel> systemChats = [];

  // 🌟 متغيرات العدادات
  int totalFriendsCount = 0;
  int totalPrivateChatsCount = 0;
  int totalReceivedRequestsCount = 0;

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
      bool canEnter = await joinToChat(chatId: id);

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

  getPinChat() async {
    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getPinChatGust();

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
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
            }            bool isTimeValid = pinHours.any((hourObj) {
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
      showUserFriendlyError(statuesRequest);
    }

    update();
  }

logOut() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _authRemoteData.logOut();

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      sharedPreferences!.clear();
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
      Get.offAll(
        const PageStart(),
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  getMyChat() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getuserChats(
      page: 1,
      perPage: 15,
    );
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

        // 🌟 ترتيب الدردشات بحيث تظهر الأحدث (التي بها آخر رسالة) في المقدمة
        newChats.sort((a, b) {
          String? dateAStr = a.lastMessage?.createdAt ?? a.updatedAt ?? a.createdAt;
          String? dateBStr = b.lastMessage?.createdAt ?? b.updatedAt ?? b.createdAt;
          
          if (dateAStr == null && dateBStr == null) return 0;
          if (dateAStr == null) return 1;
          if (dateBStr == null) return -1;
          
          try {
            DateTime dateA = DateTime.parse(dateAStr);
            DateTime dateB = DateTime.parse(dateBStr);
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });

        totalPrivateChatsCount = newChats.length;

        if (newChats.isNotEmpty) {
          userMyChatModel = newChats[0];
        }
      } else {
        log("No chats found in response['data']");
        totalPrivateChatsCount = 0;
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
      page: 1,
      perPage: 15,
    );
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      var friendsOnly = responseBody
          .where((element) => element['request_status'] == "friends")
          .toList();
      totalFriendsCount = friendsOnly.length;

      var receivedRequests = responseBody
          .where((element) => element['request_status'] == "request_received" || element['request_status'] == "request_sent")
          .toList();
      totalReceivedRequestsCount = receivedRequests.length;

      friends
          .addAll(responseBody.map((e) => SuggestFreindModel.fromJson(e)).where(
                (element) => element.requestStatus == "friends",
              ));
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  deleteAcc() async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _authRemoteData.deleteAccount();

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      sharedPreferences!.clear();
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
      Get.offAll(
        const PageStart(),
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  getfriendesSuggestion() async {
    friendsSuggestion.clear();
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getFriendeRecommendation(
      page: 1,
      perPage: 3,
    );
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];
      friendsSuggestion
          .addAll(responseBody.map((e) => SuggestFreindModel.fromJson(e)));
    } else {
      showUserFriendlyError(statuesRequest);
    }

    update();
  }

  Future<List<UserChatModel>> getSystemChats() async {
    systemChats.clear();
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.getSystemChatsGust(
      perPage: 8,
    );
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];
      systemChats.addAll(responseBody.map((e) => UserChatModel.fromJson(e)));
    } else {
      showUserFriendlyError(statuesRequest);
    }
    return systemChats;
  }

  sendFriendRequest({required friendID, required index}) async {
    var response = await _chatsRemoteData.sendFriendRequest(
      friendId: friendID,
    );
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
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  acceptOrRejectFriend({required friendID, required status}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptOrRejectRequestFriend(
      status: status,
      friendId: friendID,
    );
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  createChatFriend(
      {required int friendID,
      required String requestStatus,
      required int index}) async {
    print("====== DEBUG ======");
    print("friendID: $friendID");
    print("requestStatus: $requestStatus");
    print("===================");

    statuesRequest = StatuesRequest.loading;
    update();

    if (requestStatus == "none") {
      var requestResponse =
          await _chatsRemoteData.sendFriendRequest(friendId: friendID);

      bool isForbidden = false;
      String msg = "";

      if (requestResponse == StatuesRequest.forbiddenException) {
        isForbidden = true;
        msg = Api.serverMessage?.toLowerCase() ?? "";
      } else if (requestResponse is Map &&
          (requestResponse['code'] == 403 ||
              requestResponse['code'] == "403")) {
        isForbidden = true;
        msg = requestResponse['message']?.toString().toLowerCase() ?? "";
      }

      if (isForbidden) {
        if (msg.contains("blocked by") ||
            msg.contains("have been blocked") ||
            msg.contains("حظرت بواسطه") ||
            msg.contains("بحظرك")) {
          Get.defaultDialog(
            title: S.of(Get.context!).warning,
            middleText: S.of(Get.context!).msgIBlocked,
            titleStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.redColor),
            textConfirm: S.of(Get.context!).cancelBloc,
            textCancel: S.of(Get.context!).back,
            confirmTextColor: Colors.white,
            cancelTextColor: AppColors.primaryColor,
            buttonColor: AppColors.primaryColor,
            onConfirm: () {
              unblockUser(friendID, index, requestStatus);
            },
          );
          statuesRequest = StatuesRequest.none;
          update();
          return;
        } else if (msg.contains("you blocked") ||
            msg.contains("blocked by you") ||
            msg.contains("محظور") ||
            msg.contains("blocked")) {
          Get.snackbar(
            S.of(Get.context!).warning,
            msg,
            backgroundColor: Colors.orange.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          );
          statuesRequest = StatuesRequest.none;
          update();
          return;
        }
      }

      if (handlingData(requestResponse) == StatuesRequest.success) {
        friendsSuggestion[index].requestStatus = "request_sent";
      }
    } else if (requestStatus == "request_received") {
      var acceptResponse = await _chatsRemoteData.acceptOrRejectRequestFriend(
          status: 1, friendId: friendID);
      if (handlingData(acceptResponse) == StatuesRequest.success) {
        friendsSuggestion[index].requestStatus = "friends";
      }
    }

    var response = await _chatsRemoteData.createChatFriend(friendId: friendID);
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response['data'];
      navigateToChats(userchat: UserChatModel.fromJson(responseBody));
    } else {
      bool isForbidden = false;
      String msg = "";

      if (statuesRequest == StatuesRequest.forbiddenException) {
        isForbidden = true;
        msg = Api.serverMessage?.toLowerCase() ?? "";
      } else if (response is Map &&
          (response['code'] == 403 || response['code'] == "403")) {
        isForbidden = true;
        msg = response['message']?.toString().toLowerCase() ?? "";
      }

      if (isForbidden) {
        if (msg.contains("blocked by") ||
            msg.contains("have been blocked") ||
            msg.contains("حظرت بواسطه") ||
            msg.contains("بحظرك")) {
          Get.defaultDialog(
            title: S.of(Get.context!).warning,
            middleText: S.of(Get.context!).msgIBlocked,
            titleStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.redColor),
            textConfirm: S.of(Get.context!).cancelBloc,
            textCancel: S.of(Get.context!).back,
            confirmTextColor: Colors.white,
            cancelTextColor: AppColors.primaryColor,
            buttonColor: AppColors.primaryColor,
            onConfirm: () {
              unblockUser(friendID, index, requestStatus);
            },
          );
        } else if (msg.contains("you blocked") ||
            msg.contains("blocked by you") ||
            msg.contains("محظور") ||
            msg.contains("blocked")) {
          Get.snackbar(
            S.of(Get.context!).warning,
            msg,
            backgroundColor: Colors.orange.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          );
        } else {
          Get.snackbar(
            S.of(Get.context!).warning,
            S.of(Get.context!).msgNotHasPermission,
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          );
        }
      } else {
        showUserFriendlyError(statuesRequest);
      }
      update();
    }
  }

  Future<void> unblockUser(
      int friendID, int index, String requestStatus) async {
    statuesRequest = StatuesRequest.loading;
    update();

    var response =
        await _chatsRemoteData.blockOrUnBlock(status: 0, id: friendID);

    if (handlingData(response) == StatuesRequest.success) {
      Get.back();
      Get.snackbar(
        S.of(Get.context!).success,
        S.of(Get.context!).msgUnblockedSuccessfully,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      statuesRequest = handlingData(response);
      showUserFriendlyError(statuesRequest);
      update();
    }
  }

  final RxInt _currentPageIndex = 0.obs;
  int get currentPageIndex => _currentPageIndex.value;

  void changePage(int index) {
    _currentPageIndex.value = index;
    update();
  }

  void navigateToPrivateChats() {
    Get.put(PrivateChatsController());
    Get.to(
      () => SharedChatsScreen<PrivateChatsController>(
          title: S.of(Get.context!).yourPrivateChats),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
    );
  }

  void navigateToUpdatedChat() {
    Get.put(UpdatedChatsController());
    Get.to(
      () => SharedChatsScreen<UpdatedChatsController>(
          title: S.of(Get.context!).updated_chats),
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

  void navigateToAdsWithUs() {
    Get.to(
      () => const AdsWithUs(),
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

  @override
  void onInit() {
    if (sharedPreferences!.getString("token") != null &&
        sharedPreferences!.getString("token") != "null") {
      controller.getAds();
      getFriends();
      getMyChat();
      getPinChat();
      getfriendesSuggestion();
    }

    super.onInit();
  }
}
