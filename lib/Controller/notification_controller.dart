import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/notify_source.dart';
import 'package:live_chat/Data/Model/notify_mode.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';

class NotificationsController extends GetxController {
  String unReadNotify = '';
  List<NotifyModel> notifications = [];
  StatuesRequest statuesRequest = StatuesRequest.none;
  final _notifyRemoteData = NotifyRemoteData(api: Get.put(Api()));

  // 🌟 متغيرات الـ Pagination
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  late ScrollController scrollController;

  onPressGroubChat({required UserChatModel chatModel, required bool isGust, required id}) {
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

  // 🌟 دالة جلب الإشعارات (بتدعم الـ Refresh والـ Load More)
  Future<void> getNotify({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
      notifications.clear();
      statuesRequest = StatuesRequest.loading;
      update();
    } else {
      if (isLoadingMore || !hasMore) return;
      isLoadingMore = true;
      update();
    }

    var response = await _notifyRemoteData.gwetNotify(
      page: currentPage,
      perPage: 15, // خليناها 15 عشان يحمل أسرع ونجرب الـ Scroll
    );

    log("Notify response page $currentPage: $response");

    if (isRefresh) {
      statuesRequest = handlingData(response);
    }

    if (handlingData(response) == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      if (responseBody.isEmpty) {
        hasMore = false;
      } else {
        notifications.addAll(responseBody
            .map((e) => NotifyModel.fromJson(e))
            .where((element) => element.title != ""));
        currentPage++;
      }
      log("notify loaded: ${notifications.length} items");
    } else {
      if (isRefresh) showUserFriendlyError(statuesRequest);
    }

    isLoadingMore = false;
    update();
  }

  // 🌟 مراقبة السكرول عشان يحمل أول ما يوصل للآخر
  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
      getNotify();
    }
  }

  @override
  void onInit() {
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    getNotify(isRefresh: true);
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  final isClearAllActive = true.obs;

  void clearNotifications() {
    notifications.clear();
    isClearAllActive.value = false;
    update();
  }
}