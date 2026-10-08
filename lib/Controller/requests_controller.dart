import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/friend_suggest_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';

class RequestsController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.put(Api()));
  final RxList<SuggestFreindModel> friends = <SuggestFreindModel>[].obs;
  final RxList<SuggestFreindModel> sentRequests = <SuggestFreindModel>[].obs;
  int currentPage = 1;
  RxBool hasMoreData = true.obs;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    _initialFetch();
  }

  void navigateToChats({UserChatModel? userchat}) {
    Get.to(
          () => ChatView(isGust: false, isPin: false, userChatModel: userchat),
      arguments: {"chatId": userchat!.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // 🌟 دالة إنشاء الشات (بعد قبول الطلب لو لسه متقبلش)
  createChatFriend({required int friendID, bool isSentRequest = false}) async {
    statuesRequest = StatuesRequest.loading;
    update();

    if (!isSentRequest) {
      // 1. بما إن ده طلب مبعوتلي (request_received)، فـ لازم أقبله الأول صامت في الخلفية قبل ما افتح الشات
      var acceptResponse = await _chatsRemoteData.acceptOrRejectRequestFriend(status: 1, friendId: friendID);

      // 2. بعد ما يتوافق عليه، بنمسحه من لستة "طلبات الصداقة" اللي في الشاشة
      if (handlingData(acceptResponse) == StatuesRequest.success) {
        friends.removeWhere((friend) => friend.id == friendID);
      }
    }

    // 3. بننادي على دالة فتح الشات وبنحول اليوزر لشاشة الشات
    var response = await _chatsRemoteData.createChatFriend(friendId: friendID);
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      navigateToChats(userchat: UserChatModel.fromJson(response['data']));
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _initialFetch() async => await refreshData();

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.8 &&
        statuesRequest != StatuesRequest.loading &&
        hasMoreData.value) {
      getFriends(page: currentPage + 1);
    }
  }

  Future<void> getFriends({int page = 1}) async {
    if (!hasMoreData.value && page != 1) return;

    if (page == 1) {
      friends.clear();
      sentRequests.clear();
      hasMoreData.value = true;
    }

    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getFriende(page: page, perPage: 15);
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      if (responseBody.isEmpty) {
        hasMoreData.value = false;
      } else {
        var received = responseBody
            .map((e) => SuggestFreindModel.fromJson(e))
            .where((element) => element.requestStatus == "request_received")
            .toList();
        var sent = responseBody
            .map((e) => SuggestFreindModel.fromJson(e))
            .where((element) => element.requestStatus == "request_sent")
            .toList();

        // 🌟 حل مشكلة الـ Pagination
        if (page == 1) {
          friends.assignAll(received);
          sentRequests.assignAll(sent);
        } else {
          friends.addAll(received);
          sentRequests.addAll(sent);
        }
        currentPage = page;
      }
    } else {
      hasMoreData.value = false;
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  Future<void> rejectFriend({required int friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptOrRejectRequestFriend(status: 0, friendId: friendID);
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      friends.removeWhere((friend) => friend.id == friendID);
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  Future<void> acceptFriend({required int friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptOrRejectRequestFriend(status: 1, friendId: friendID);
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      friends.removeWhere((friend) => friend.id == friendID);
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  Future<void> cancelRequest({required int friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptOrRejectRequestFriend(status: 0, friendId: friendID);
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      sentRequests.removeWhere((friend) => friend.id == friendID);
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  Future<void> refreshData() async {
    currentPage = 1;
    hasMoreData.value = true;
    await getFriends(page: 1);
  }

  var isEditing = false.obs;
  void toggleEdit() => isEditing.value = !isEditing.value;
}