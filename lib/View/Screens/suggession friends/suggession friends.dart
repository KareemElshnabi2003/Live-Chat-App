// ignore_for_file: file_names, avoid_print

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/friend_suggest_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/sugessted_friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  createChatFriend({required friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.createChatFriend(
        friendId: friendID, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response['data'];
      navigateToChats(userchat: UserChatModel.fromJson(responseBody));
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
        page: page, perPage: 15, token: sharedPreferences!.getString("token"));
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
    var response = await _chatsRemoteData.sendFriendRequest(
        friendId: friendID, token: sharedPreferences!.getString("token"));
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
      showUserFriendlyError(statuesRequest);
    }
    update();
  }
}

class ChatItem {
  final ImageProvider image;
  final String title;
  final String body;

  ChatItem({
    required this.image,
    required this.title,
    required this.body,
  });
}

class SuggessionChat extends StatelessWidget {
  SuggessionChat({super.key});

  final SuggessionChatController controller =
      Get.put(SuggessionChatController());
  final HomeNavigationController homeController =
      Get.put(HomeNavigationController());

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(
            left: isRtl ? 0.w : 4.w,
            right: isRtl ? 4.w : 0.w,
            top: 3.h,
            bottom: 2.h),
        child: GetBuilder<SuggessionChatController>(
            builder: (controller) => _buildChatList(controller)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () {
            Get.offAll(() => const HomeView());
          },
          child: Icon(
            isRtl
                ? IconsaxPlusLinear.arrow_right_3
                : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          ),
        ),
        SizedBox(width: 2.w),
        textNormal(
          S.of(context).suggestedFriends,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildChatList(
    SuggessionChatController controller,
  ) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    if (controller.statuesRequest == StatuesRequest.loading) {
      return Column(
        children: [
          _buildHeader(Get.context!),
          Expanded(child: loading(80.h)),
        ],
      );
    } else if (controller.friendsSuggestion.isEmpty) {
      return Column(
        children: [
          _buildHeader(Get.context!),
          SizedBox(height: 6.h),
          Expanded(
            child: controller.statuesRequest == StatuesRequest.socketException
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.wifiOff,
                              size: 20.w,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          textNormal(
                              isRtl
                                  ? "لا يوجد اتصال بالإنترنت"
                                  : "No Internet Connection",
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackColor,
                              4.5.w,
                              FontWeight.w700),
                          SizedBox(height: 2.h),
                          textNormal(
                              isRtl
                                  ? "يرجى التحقق من اتصالك بالإنترنت"
                                  : "Please check your internet connection",
                              pref!
                                  ? AppColors.inActiveColor
                                  : AppColors.blackColor.withOpacity(0.6),
                              3.5.w,
                              FontWeight.w600),
                          SizedBox(height: 4.h),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await controller.getfriendesSuggestion(page: 1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pref!
                                  ? AppColors.secondaryColor
                                  : AppColors.primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(LucideIcons.refreshCw,
                                size: 5.w,
                                color: pref!
                                    ? AppColors.blackColor
                                    : AppColors.whiteColor),
                            label: textNormal(
                                isRtl ? "إعادة المحاولة" : "Try Again",
                                pref!
                                    ? AppColors.blackColor
                                    : AppColors.whiteColor,
                                3.5.w,
                                FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(child: noData(S.of(Get.context!).noChat)),
          ),
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.secondaryColor,
        backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.friendsSuggestion.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  _buildHeader(context),
                  SizedBox(height: 6.h),
                ],
              );
            } else if (index <= controller.friendsSuggestion.length) {
              final friendIndex = index - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: GetBuilder<SuggessionChatController>(
                  builder: (controller) => SuggestedFriends(
                    power: controller.friendsSuggestion[friendIndex].power,
                    imgUrl: controller.friendsSuggestion[friendIndex].image
                                    .toString() ==
                                "null" ||
                            controller.friendsSuggestion[friendIndex].image ==
                                "" ||
                            controller.friendsSuggestion[friendIndex].image
                                    .toString() ==
                                "image"
                        ? false
                        : true,
                    onPressImg: () {
                      dialogImgWidget(
                          title:
                              controller.friendsSuggestion[friendIndex].name!,
                          img: controller.friendsSuggestion[friendIndex].image,
                          userChatModel: null,
                          onPressChat: () {
                            if (controller.friendsSuggestion[friendIndex]
                                    .requestStatus ==
                                "friends") {
                              controller.createChatFriend(
                                  friendID: controller
                                      .friendsSuggestion[friendIndex].id);
                            } else {
                              controller.createChatFriend(
                                  friendID: controller
                                      .friendsSuggestion[friendIndex].id);
                            }
                          });
                    },
                    chat: () {
                      controller.createChatFriend(
                          friendID:
                              controller.friendsSuggestion[friendIndex].id);
                    },
                    removeRequest: () {
                      controller.sendFriendRequest(
                          index: friendIndex,
                          friendID:
                              controller.friendsSuggestion[friendIndex].id);
                    },
                    requestSend: controller
                                .friendsSuggestion[friendIndex].requestStatus ==
                            "none"
                        ? false
                        : true,
                    sendRequest: () {
                      controller.sendFriendRequest(
                          index: friendIndex,
                          friendID:
                              controller.friendsSuggestion[friendIndex].id);
                    },
                    img: controller.friendsSuggestion[friendIndex].image ==
                                "image" ||
                            controller.friendsSuggestion[friendIndex].image
                                    .toString() ==
                                "null"
                        ? const AssetImage(AppImages.noChatImg)
                        : CachedNetworkImageProvider(
                            controller.friendsSuggestion[friendIndex].image!),
                    body: controller
                                .friendsSuggestion[friendIndex].requestStatus ==
                            "none"
                        ? S.of(context).notFriend
                        : S.of(context).requestWaiting,
                    ttitle:
                        controller.friendsSuggestion[friendIndex].username ??
                            "",
                  ),
                ),
              );
            } else {
              return controller.statuesRequest == StatuesRequest.loading &&
                      controller.friendsSuggestion.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: loading(10.h),
                    )
                  : const SizedBox.shrink();
            }
          },
        ),
      );
    }
  }
}
