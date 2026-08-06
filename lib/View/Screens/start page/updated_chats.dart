// ignore_for_file: avoid_print

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
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Widget/PublicWidget/chat_card_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class UpdatedChatsController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  List<UserChatModel> recentChats = [];
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.put(Api()));

  // Pagination variables
  int currentPage = 1;
  int perPage = 20;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    getRecentChats();
  }

  Future<void> refreshData() async {
    try {
      // Set loading state
      statuesRequest = StatuesRequest.loading;
      update();

      getRecentChats();
      // Update the UI
      statuesRequest = StatuesRequest.success;
      update();
    } catch (error) {
      // Handle error
      statuesRequest = StatuesRequest.serverException;
      update();

      // You might want to show an error message
      print('Error refreshing data: $error');
    }
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      // Check if user scrolled to the bottom
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (hasMoreData &&
            !isLoadingMore &&
            statuesRequest == StatuesRequest.success) {
          loadMoreChats();
        }
      }
    });
  }

  getRecentChats() async {
    recentChats.clear();
    currentPage = 1;
    hasMoreData = true;
    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getRecentChatGust(
      deviceToken: sharedPreferences!.getString("tokenDevice"),
      perPage: perPage,
      page: currentPage,
    );
    print("response recent ??? $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      recentChats.addAll(responseBody.map(
        (e) => UserChatModel.fromJson(e),
      ));

      // Check if there's more data
      if (responseBody.length < perPage) {
        hasMoreData = false;
      }

      log("Initial load: ${recentChats.length} recent chats");
    } else {          showUserFriendlyError(statuesRequest);
}update();
  }

  loadMoreChats() async {
    if (!hasMoreData || isLoadingMore) return;

    isLoadingMore = true;
    currentPage++;
    update();

    var response = await _chatsRemoteData.getRecentChatGust(
      deviceToken: sharedPreferences!.getString("tokenDevice"),
      perPage: perPage,
      page: currentPage,
    );
    print("Load more recent chats response page $currentPage: $response");

    var requestStatus = handlingData(response);

    if (requestStatus == StatuesRequest.success) {
      List responseBody = response['data'];

      if (responseBody.isNotEmpty) {
        recentChats.addAll(responseBody.map(
          (e) => UserChatModel.fromJson(e),
        ));

        // Check if there's more data
        if (responseBody.length < perPage) {
          hasMoreData = false;
        }

        log("Loaded more: ${responseBody.length} recent chats, Total: ${recentChats.length}");
      } else {
        hasMoreData = false;
        log("No more recent chats available");
      }
    } else {
      // If loading more fails, revert the page number
      currentPage--;
      log("Failed to load more recent chats");
    }

    isLoadingMore = false;
    update();
  }

  // Pull to refresh functionality
  Future<void> refreshChats() async {
    await getRecentChats();
  }

  onPressChat() {
    Get.to(
      () => CreateChat(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
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

class UpdatedChats extends StatelessWidget {
  UpdatedChats({super.key});

  final controller = Get.put(UpdatedChatsController());
  final homeController = Get.put(HomeNavigationController());

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(
            left: isRtl ? 2.w : 4.w,
            right: isRtl ? 4.w : 2.w,
            top: 5.h,
            bottom: 2.h),
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: 4.h),
            Expanded(
              child: GetBuilder<UpdatedChatsController>(
                builder: (controller) =>
                    controller.statuesRequest == StatuesRequest.loading
                        ? loading(80.h)
                        : controller.recentChats.isEmpty
                            ? Center(
                                child: noData(S.of(context).noChat),
                              )
                            : _buildChatListWithRefresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            isRtl
                ? IconsaxPlusLinear.arrow_right_3
                : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          ),
        ),
        SizedBox(width: 2.w),
        textNormal(
          S.of(context).updated_chats,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildChatListWithRefresh() {
    return RefreshIndicator(
      onRefresh: controller.refreshChats,
      color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
      backgroundColor: pref! ? AppColors.blackColor : AppColors.whiteColor,
      child: _buildChatList(),
    );
  }

  Widget _buildChatList() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return SizedBox(
      width: 100.w,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh

        controller: controller.scrollController,
        padding:
            EdgeInsets.only(right: isRtl ? 0.w : 2.w, left: isRtl ? 2.w : 0.w),
        itemBuilder: (context, index) {
          // Show chat item
          if (index < controller.recentChats.length) {
            return chatCardWidget(
              power: null,
                imageUrl:
                    controller.recentChats[index].image.toString() == "null" ||
                            controller.recentChats[index].image == ""
                        ? false
                        : true,
                numOfMessage: 0,
                onPressImg: () {
                  dialogImgWidget(
                      title: controller.recentChats[index].name!,
                      img: null,
                      onPressChat: () {
                        homeController.onPressGroubChat(
                            chatModel: controller.recentChats[index],
                            isGust: true,
                            id: controller.recentChats[index].id);
                      },
                      userChatModel: controller.recentChats[index]);
                },
                private: controller.recentChats[index].status == "Private"
                    ? true
                    : false,
                img: controller.recentChats[index].image == "null"
                    ? const AssetImage(AppImages.noChatImg)
                    : CachedNetworkImageProvider(
                        "${controller.recentChats[index].image}"),
                body:
                    "${controller.recentChats[index].membersCount} ${S.of(context).engaged_people}",
                ttitle: controller.recentChats[index].name!,
                onPressJoin: () {
                  homeController.onPressGroubChat(
                      chatModel: controller.recentChats[index],
                      isGust: true,
                      id: controller.recentChats[index].id);
                },
                action: S.of(context).joinNow,
                ontap: () {
                  homeController.onPressGroubChat(
                      chatModel: controller.recentChats[index],
                      isGust: true,
                      id: controller.recentChats[index].id);
                });
          }
          // Show loading indicator at the bottom when loading more
          else {
            return GetBuilder<UpdatedChatsController>(
              builder: (controller) => controller.isLoadingMore
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 6.w,
                        width: 6.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pref!
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }
        },
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemCount:
            controller.recentChats.length + (controller.isLoadingMore ? 1 : 0),
      ),
    );
  }
}
