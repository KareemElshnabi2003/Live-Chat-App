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

class FriendsChatContoller extends GetxController {
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.put(Api()));
  final RxList<SuggestFreindModel> friends = <SuggestFreindModel>[].obs;
  final RxBool hasMoreData = true.obs;
  final ScrollController scrollController = ScrollController();
  StatuesRequest statuesRequest = StatuesRequest.none;
  int currentPage = 1;
  final RxBool isEditing = false.obs;

  // 🌟 أضفنا عداد تفاعلي لعدد طلبات الصداقة المعلقة
  final RxInt pendingRequestsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    _initialFetch();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.8 &&
        statuesRequest != StatuesRequest.loading &&
        hasMoreData.value) {
      getFriends(page: currentPage + 1);
    }
  }

  Future<void> _initialFetch() => refreshData();

  Future<void> getFriends({int page = 1}) async {
    if (!hasMoreData.value && page != 1) return;

    if (page == 1) {
      friends.clear();
      hasMoreData.value = true;
      // 🌟 نصفر العداد مع الريفرش
      pendingRequestsCount.value = 0;
    }

    statuesRequest = StatuesRequest.loading;
    update(); // Update For UI Loading state

    final response = await _chatsRemoteData.getFriende(
      page: page,
      perPage: 15,
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final List responseBody = response['data'];
      if (responseBody.isEmpty) {
        hasMoreData.value = false;
      } else {
        // 🌟 تحويل الداتا كلها عشان نفصل الأصدقاء عن الطلبات
        var allItems = responseBody.map((e) => SuggestFreindModel.fromJson(e)).toList();

        // 🌟 جلب الأصدقاء فقط لعرضهم في الشاشة دي
        var newFriends = allItems
            .where((element) => element.requestStatus == "friends")
            .toList();

        // 🌟 حساب الطلبات المعلقة عشان العداد (Badge)
        var pendingReceived = allItems
            .where((element) => element.requestStatus == "request_received")
            .toList();
        var pendingSent = allItems
            .where((element) => element.requestStatus == "request_sent")
            .toList();

        if (page == 1) {
          friends.assignAll(newFriends);
          pendingRequestsCount.value = pendingReceived.length + pendingSent.length; // تخزين عدد الطلبات
        } else {
          friends.addAll(newFriends);
          pendingRequestsCount.value += pendingReceived.length + pendingSent.length; // زيادة العداد لو نزلنا لصفحة جديدة
        }
        currentPage = page;

        if (response['pagination'] != null) {
          int currentPageMeta = response['pagination']['current_page'] ?? 1;
          int lastPageMeta = response['pagination']['last_page'] ?? 1;
          if (currentPageMeta >= lastPageMeta) {
            hasMoreData.value = false;
          }
        } else if (responseBody.length < 15) {
          hasMoreData.value = false;
        }
      }
    } else {
      showUserFriendlyError(statuesRequest);
      hasMoreData.value = false;
    }

    update();
  }

  Future<void> createChatFriend({required int friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();

    final response = await _chatsRemoteData.createChatFriend(
      friendId: friendID,
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      navigateToChats(userchat: UserChatModel.fromJson(response['data']));
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  Future<void> removeFriend({required int friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();

    final response = await _chatsRemoteData.removeFriend(
      friendId: friendID,
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      friends.removeWhere((friend) => friend.id == friendID);
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

  void navigateToChats({UserChatModel? userchat}) {
    Get.to(
          () => ChatView(isGust: false, isPin: false, userChatModel: userchat),
      arguments: {"chatId": userchat!.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void toggleEdit() => isEditing.value = !isEditing.value;
}