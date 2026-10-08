import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/main.dart';

abstract class BaseChatsController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  final ChatsRemoteData chatsRemoteData = ChatsRemoteData(api: Get.put(Api()));
  List<UserChatModel> chatsList = [];

  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int perPage = 15;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isInitialLoad = true;

  @override
  void onInit() {
    super.onInit();
    getChatsData();
    _setupScrollListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 &&
          !isLoadingMore &&
          hasMoreData &&
          statuesRequest != StatuesRequest.loading) {
        loadMoreChats();
      }
    });
  }

  Future<dynamic> fetchChatsFromApi(int page, int perPage, String token);

  getChatsData({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMoreData = true;
      chatsList.clear();
      isInitialLoad = true;
    }

    statuesRequest = StatuesRequest.loading;
    update();

    var response = await fetchChatsFromApi(
        currentPage,
        perPage,
        sharedPreferences!.getString("deviceId") ?? "" // أو token لو محتاجينه
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      List<UserChatModel> newChats = responseBody.map((e) => UserChatModel.fromJson(e)).toList();

      if (isRefresh || currentPage == 1) {
        chatsList = newChats;
      } else {
        chatsList.addAll(newChats);
      }

      // Sort chatsList by last message date (descending)
      chatsList.sort((a, b) {
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

      if (response['pagination'] != null) {
        int currentPageMeta = response['pagination']['current_page'] ?? 1;
        int lastPageMeta = response['pagination']['last_page'] ?? 1;
        if (currentPageMeta >= lastPageMeta) {
          hasMoreData = false;
        }
      } else if (newChats.length < perPage) {
        hasMoreData = false;
      }
      isInitialLoad = false;
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  loadMoreChats() async {
    if (isLoadingMore || !hasMoreData) return;

    isLoadingMore = true;
    currentPage++;
    update();

    var response = await fetchChatsFromApi(
        currentPage,
        perPage,
        sharedPreferences!.getString("deviceId") ?? ""
    );

    StatuesRequest loadMoreStatus = handlingData(response);

    if (loadMoreStatus == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];
      List<UserChatModel> newChats = responseBody.map((e) => UserChatModel.fromJson(e)).toList();

      chatsList.addAll(newChats);

      if (response['pagination'] != null) {
        int currentPageMeta = response['pagination']['current_page'] ?? 1;
        int lastPageMeta = response['pagination']['last_page'] ?? 1;
        if (currentPageMeta >= lastPageMeta) {
          hasMoreData = false;
        }
      } else if (newChats.length < perPage) {
        hasMoreData = false;
      }
    } else {
      currentPage--;
    }

    isLoadingMore = false;
    update();
  }

  refreshChats() async {
    await getChatsData(isRefresh: true);
  }

  onPressChat(UserChatModel? chatModel) {
    if (chatModel == null) {
      Get.to(
            () => CreateChat(),
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 400),
      );
    } else {
      Get.to(
            () => ChatView(
          userChatModel: chatModel,
          isPin: false,
          isGust: sharedPreferences!.getString("id") == null,
        ),
        arguments: {"chatId": chatModel.id},
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 400),
      );
    }
  }
}