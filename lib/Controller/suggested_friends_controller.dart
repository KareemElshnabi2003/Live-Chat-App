import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/friend_suggest_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';

class SuggessionChatController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.put(Api()));
  List<SuggestFreindModel> friendsSuggestion = [];
  int currentPage = 1;
  bool hasMoreData = true;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    getfriendesSuggestion();
    super.onInit();
    scrollController.addListener(_scrollListener);
  }

  void navigateToChats({UserChatModel? userchat}) {
    Get.to(
      () => ChatView(
        isGust: false,
        isPin: false,
        userChatModel: userchat,
      ),
      arguments: {"chatId": userchat!.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
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

  createChatFriend(
      {required int friendID,
      required String requestStatus,
      required int index}) async {
    print('========= DEBUG =========');
    print('friendID: $friendID');
    print('requestStatus: $requestStatus');
    print('=========================');

    statuesRequest = StatuesRequest.loading;
    update();

    if (requestStatus == "none") {
      var requestResponse =
          await _chatsRemoteData.sendFriendRequest(friendId: friendID);

      print('''
me  :: ${sharedPreferences!.getString("id")}
messsage :: ${requestResponse is Map ? requestResponse['message'] : Api.serverMessage}
idfriend >>> $friendID
''');

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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        statuesRequest != StatuesRequest.loading &&
        hasMoreData) {
      getfriendesSuggestion(page: currentPage + 1);
    }
  }

  getfriendesSuggestion({int page = 1}) async {
    if (!hasMoreData && page != 1) return friendsSuggestion;

    if (page == 1) {
      friendsSuggestion.clear();
      hasMoreData = true;
    }

    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getFriendeRecommendation(
        page: page, perPage: 15);
    print("response for page $page: $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      print(" response   >>>>  $responseBody");
      if (responseBody.isEmpty) {
        hasMoreData = false;
      } else {
        friendsSuggestion.addAll(responseBody
            .map(
              (e) => SuggestFreindModel.fromJson(e),
            )
            .where((i) => i.requestStatus != "request_received"));
        currentPage = page;

        if (response['pagination'] != null) {
          int currentPageMeta = response['pagination']['current_page'] ?? 1;
          int lastPageMeta = response['pagination']['last_page'] ?? 1;
          if (currentPageMeta >= lastPageMeta) {
            hasMoreData = false;
          }
        } else if (responseBody.length < 15) {
          hasMoreData = false;
        }
      }
    } else {
      hasMoreData = false;

      showUserFriendlyError(statuesRequest);
    }

    update();
  }

  Future<void> refreshData() async {
    currentPage = 1;
    hasMoreData = true;
    await getfriendesSuggestion(page: 1);
  }

  sendFriendRequest({required friendID, required index}) async {
    var response = await _chatsRemoteData.sendFriendRequest(friendId: friendID);
    print("response ??? $response");

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
      log("addddddddddddddd");
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
              unblockUser(friendID, index,
                  friendsSuggestion[index].requestStatus ?? "none");
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
    }
    update();
  }
}
