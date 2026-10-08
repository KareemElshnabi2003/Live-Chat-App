// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
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

class AnotherChatsController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  List<UserChatModel> systemChats = [];
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
    getSystemChats();
  }

  Future<void> refreshData() async {
    try {
      // Set loading state
      statuesRequest = StatuesRequest.loading;
      update();

      getSystemChats();
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
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMoreData &&
            !isLoadingMore &&
            statuesRequest == StatuesRequest.success) {
          loadMoreChats();
        }
      }
    });
  }

  getSystemChats() async {
    systemChats.clear();
    currentPage = 1;
    hasMoreData = true;
    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getSystemChatsGust(
      perPage: perPage,
      page: currentPage,
    );
    print("response recent ??? $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      systemChats.addAll(responseBody.map(
        (e) => UserChatModel.fromJson(e),
      ));

      // Check if there's more data
      if (responseBody.length < perPage) {
        hasMoreData = false;
      }

      log("Initial load: ${systemChats.length} chats");
    } else{          showUserFriendlyError(statuesRequest);
}update();
  }

  loadMoreChats() async {
    if (!hasMoreData || isLoadingMore) return;

    isLoadingMore = true;
    currentPage++;
    update();

    var response = await _chatsRemoteData.getSystemChatsGust(
      perPage: perPage,
      page: currentPage,
    );
    print("Load more response page $currentPage: $response");

    var requestStatus = handlingData(response);

    if (requestStatus == StatuesRequest.success) {
      List responseBody = response['data'];

      if (responseBody.isNotEmpty) {
        systemChats.addAll(responseBody.map(
          (e) => UserChatModel.fromJson(e),
        ));

        // Check if there's more data
        if (responseBody.length < perPage) {
          hasMoreData = false;
        }

        log("Loaded more: ${responseBody.length} chats, Total: ${systemChats.length}");
      } else {
        hasMoreData = false;
        log("No more data available");
      }
    } else {
      // If loading more fails, revert the page number
      currentPage--;
      log("Failed to load more chats");
    }

    isLoadingMore = false;
    update();
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

class AnotherChats extends StatelessWidget {
  AnotherChats({super.key});

  final controller = Get.put(AnotherChatsController());
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
            top: 4.h,
            bottom: 2.h),
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: 5.h),
            Expanded(
              child: GetBuilder<AnotherChatsController>(
                builder: (controller) =>
                    controller.statuesRequest == StatuesRequest.loading
                        ? loading(80.h)
                        : controller.systemChats.isEmpty
                            ? Center(
                                child: noData(S.of(context).noChat),
                              )
                            : _buildChatList(),
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
          S.of(context).another_chats,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildChatList() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return RefreshIndicator(
      onRefresh: () async {
        // Call your refresh method here
        await controller.refreshData();
      },
      color: AppColors.secondaryColor, // Customize the refresh indicator color
      backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
      child: SizedBox(
        width: 100.w,
        child: ListView.separated(
          physics:
              const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh

          controller: controller.scrollController,
          padding: EdgeInsets.only(
              right: isRtl ? 0.w : 2.w, left: isRtl ? 2.w : 0.w),
          itemBuilder: (context, index) {
            // Show chat item
            if (index < controller.systemChats.length) {
              return chatCardWidget(
                power: null,
                  imageUrl: controller.systemChats[index].image.toString() ==
                              "null" ||
                          controller.systemChats[index].image == ""
                      ? false
                      : true,
                  numOfMessage: 0,
                  onPressImg: () {
                    dialogImgWidget(
                      title: controller.systemChats[index].name!,
                      userChatModel: controller.systemChats[index],
                      img: null,
                      onPressChat: () {
                        homeController.onPressGroubChat(
                            chatModel: controller.systemChats[index],
                            isGust: true,
                            id: controller.systemChats[index].id);
                      },
                    );
                  },
                  private: controller.systemChats[index].status == "Private"
                      ? true
                      : false,
                  img: controller.systemChats[index].image == "null"
                      ? const AssetImage(AppImages.noChatImg)
                      : CachedNetworkImageProvider(
                          controller.systemChats[index].image!),
                  body:
                      "${controller.systemChats[index].membersCount} ${S.of(context).engaged_people}",
                  ttitle: controller.systemChats[index].name!,
                  onPressJoin: () {
                    homeController.onPressGroubChat(
                        chatModel: controller.systemChats[index],
                        isGust: true,
                        id: controller.systemChats[index].id);
                  },
                  action: S.of(context).joinNow,
                  ontap: () {
                    homeController.onPressGroubChat(
                        chatModel: controller.systemChats[index],
                        isGust: true,
                        id: controller.systemChats[index].id);
                  },
                  needsAcceptance: controller.systemChats[index].accept == '1',
              );
            }
            // Show loading indicator at the bottom when loading more
            else {
              return GetBuilder<AnotherChatsController>(
                builder: (controller) => controller.isLoadingMore
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pref!
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            }
          },
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemCount: controller.systemChats.length +
              (controller.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }
}
