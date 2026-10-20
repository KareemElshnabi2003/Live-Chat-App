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
import 'package:live_chat/View/Widget/PublicWidget/unblock_friend_dialog.dart';
import 'package:live_chat/View/Screens/settings/capapiltes.dart';
import 'package:live_chat/View/Screens/settings/language_view.dart';
import 'package:live_chat/View/Screens/settings/my_account_view.dart';
import 'package:live_chat/View/Screens/settings/night_mode.dart';
import 'package:live_chat/View/Screens/settings/notification_view.dart';
import 'package:live_chat/View/Screens/settings/privacy.dart';
import 'package:live_chat/View/Screens/start%20page/page_start.dart';
import 'package:live_chat/View/Screens/suggession%20friends/suggession%20friends.dart';
import 'package:live_chat/View/Widget/shared_chats_screen.dart';
import 'package:live_chat/Controller/handel_notification.dart';
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
  Future<List<UserChatModel>>? systemChatsFuture;
  List<UserChatModel> myChats = [];
  Set<int> joinedChatIds = {};

  // 🌟 متغيرات العدادات
  int totalFriendsCount = 0;
  int totalPrivateChatsCount = 0;
  int totalReceivedRequestsCount = 0;

  Future<void> updateChatUI() async {
    controller.getAds();
    systemChatsFuture = null;
    await getSystemChats(isRefresh: true);
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
    try {
      var response = await _chatsRemoteData.joinToCgat(
        chatId: chatId,
      );

      final status = handlingData(response);
      log("response join to chhat  :: $response");

      if (status == StatuesRequest.success) {
        final int? idInt = int.tryParse(chatId.toString());
        if (idInt != null) {
          joinedChatIds.add(idInt);
        }
        getMyChat();
        update();
        return true;
      } else if (status == StatuesRequest.forbiddenException) {
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
        return false;
      } else {
        showUserFriendlyError(status);
        return false;
      }
    } catch (e) {
      log("❌ Error in joinToChat: $e");
      return false;
    }
  }

  onPressPinChat(
      {required UserChatModel chatModel,
      required bool isGust,
      required id}) async {

    // 🌟 استكمال بيانات المالك والإعلان لو ناقصة لضمان ظهور الإعدادات والإعلان بشكل صحيح
    _enrichChatModelOwner(chatModel);
    if (pinChatModel != null && (pinChatModel!.conversationId == id || pinChatModel!.conversation?.id == id)) {
      chatModel.adTitle = pinChatModel!.adTitle ?? chatModel.adTitle;
      chatModel.adLink = pinChatModel!.adLink ?? chatModel.adLink;
      chatModel.adImage = pinChatModel!.adImage ?? chatModel.adImage;
    }

    final bool effectiveIsGust =
        (sharedPreferences?.getString("id") != null) ? false : isGust;

    print("id >>$id");
    await Get.to(
      () => ChatView(
        userChatModel: chatModel,
        isPin: true,
        isGust: effectiveIsGust,
      ),
      arguments: {"chatId": id},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    statuesRequest = StatuesRequest.none;
    update();
  }

  onPressGroubChat(
      {required UserChatModel chatModel,
      required bool isGust,
      required id}) async {

    // 🌟 استكمال بيانات المالك لو ناقصة لضمان ظهور الإعدادات بشكل صحيح
    _enrichChatModelOwner(chatModel);

    final bool effectiveIsGust =
        (sharedPreferences?.getString("id") != null) ? false : isGust;

    await Get.to(
      () => ChatView(
        userChatModel: chatModel,
        isPin: false,
        isGust: effectiveIsGust,
      ),
      arguments: {"chatId": id},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    statuesRequest = StatuesRequest.none;
    update();
  }

  /// 🌟 يستكمل بيانات المالك في نموذج الشات لو ناقصة
  /// بيضمن ظهور قائمة الإعدادات للمالك بغض النظر عن مصدر الدخول
  void _enrichChatModelOwner(UserChatModel chatModel) {
    final currentUserId = sharedPreferences?.getString("id")?.trim();
    if (currentUserId == null || currentUserId.isEmpty) return;

    final isGroup = chatModel.status == "Public" || chatModel.status == "Private";
    if (isGroup) {
      // لو بيانات المالك مش موجودة، حطها من المستخدم الحالي للغرف العامة والخاصة فقط
      if ((chatModel.user == null || chatModel.user?.id == null) &&
          chatModel.userId == null) {
        chatModel.userId = int.tryParse(currentUserId);
        chatModel.user = User(id: chatModel.userId);
      }

      // لو accept فاضية، اعملها 1 كـ default للغرف الخاصة والعامة
      if ((chatModel.accept == null ||
              chatModel.accept == "null" ||
              chatModel.accept!.isEmpty)) {
        chatModel.accept = "1";
      }
    }
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
          String? dateAStr =
              a.lastMessage?.createdAt ?? a.updatedAt ?? a.createdAt;
          String? dateBStr =
              b.lastMessage?.createdAt ?? b.updatedAt ?? b.createdAt;

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
        myChats = newChats;
        joinedChatIds = newChats.where((c) => c.id != null).map((c) => c.id!).toSet();

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
          .where((element) =>
              element['request_status'] == "friends" ||
              element['request_status'] == "blocked" ||
              (element['is_blocked'] != null && element['is_blocked'] != "None"))
          .toList();
      totalFriendsCount = friendsOnly.length;

      var receivedRequests = responseBody
          .where((element) =>
              element['request_status'] == "request_received" ||
              element['request_status'] == "request_sent")
          .toList();
      totalReceivedRequestsCount = receivedRequests.length;

      friends.addAll(responseBody
          .map((e) => SuggestFreindModel.fromJson(e))
          .where((element) =>
              element.requestStatus == "friends" ||
              element.requestStatus == "blocked" ||
              (element.isBlocked != null && element.isBlocked != "None")));
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

  Future<List<UserChatModel>> getSystemChats({bool isRefresh = false}) {
    if (isRefresh || systemChatsFuture == null) {
      systemChatsFuture = _fetchSystemChats();
    }
    return systemChatsFuture!;
  }

  Future<List<UserChatModel>> _fetchSystemChats() async {
    systemChats.clear();
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
      required int index,
      SuggestFreindModel? friend}) async {
    print("====== DEBUG ======");
    print("friendID: $friendID");
    print("requestStatus: $requestStatus");
    print("===================");

    // 🌟 استرجاع كائن الصديق من القائمة لو لم يُمرر صراحة
    friend ??= (index >= 0 && index < friends.length) ? friends[index] : null;

    final bool isBlockedByMe = friend?.isBlocked == "You blocked them";
    final bool isBlockedByThem = friend?.isBlocked == "They blocked you";
    final bool isGeneralBlocked =
        friend?.requestStatus == "blocked" || isBlockedByMe || isBlockedByThem;

    final conversationId = friend?.conversationId;

    // 🌟 لو المستخدم محظور وموجود له conversationId، ندخل الشات مباشرة لعرض الرسائل السابقة وشريط الحظر
    if (isGeneralBlocked && conversationId != null && conversationId != 0) {
      final userChat = UserChatModel(
        id: conversationId,
        isBlocked: friend?.isBlocked ?? (isBlockedByThem ? "They blocked you" : "You blocked them"),
        name: friend?.name ?? friend?.username ?? '',
        image: friend?.image,
        status: "Friends",
        lastMessage: friend?.lastMessage,
        user: User(
          id: friend?.id ?? friendID,
          name: friend?.name,
          username: friend?.username,
          image: friend?.image,
        ),
      );
      navigateToChats(userchat: userChat);
      return;
    }

    var response = await _chatsRemoteData.createChatFriend(friendId: friendID);
    final status = handlingData(response);

    if (status == StatuesRequest.success) {
      final responseBody = response['data'];
      final userChat = UserChatModel.fromJson(responseBody);
      userChat.otherUserId = friendID;
      userChat.user ??= User(
        id: friendID,
        name: friend?.name,
        username: friend?.username,
        image: friend?.image,
      );
      if ((userChat.isBlocked == null || userChat.isBlocked == "None") &&
          friend?.isBlocked != null) {
        userChat.isBlocked = friend!.isBlocked;
      }
      if (userChat.lastMessage == null && friend?.lastMessage != null) {
        userChat.lastMessage = friend!.lastMessage;
      }
      statuesRequest = StatuesRequest.none;
      update();
      navigateToChats(userchat: userChat);
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
      if (Get.context != null) {
        showUnblockFriendDialog(
          context: Get.context!,
          friendId: friendID,
          onSendRequest: () async {
            await sendFriendRequest(friendID: friendID, index: index);
            Get.snackbar(
              S.of(Get.context!).success,
              S.of(Get.context!).youSendRequest,
              backgroundColor: const Color(0xFF2E7D32),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              duration: const Duration(seconds: 3),
            );
          },
        );
      }
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

  Future<void> navigateToChats({UserChatModel? userchat}) async {
    await Get.to(
      () => ChatView(
        isGust: false,
        isPin: false,
        userChatModel: userchat,
      ),
      arguments: {"chatId": userchat?.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
    statuesRequest = StatuesRequest.none;
    update();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseNotification().checkAndRequestNotificationPermission();
    });

    super.onInit();
  }
}
