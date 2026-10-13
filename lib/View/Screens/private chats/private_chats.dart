// ignore_for_file: avoid_print

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
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Widget/PublicWidget/chat_card_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/shimmer_widgets.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrivateChatsController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.put(Api()));
  List<UserChatModel> myChats = [];

  // Pagination variables
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int perPage = 15;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isInitialLoad = true;

  @override
  void onInit() {
    super.onInit();
    getMyChats();
    _setupScrollListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent -
                  300 && // Load when 300px from bottom
          !isLoadingMore &&
          hasMoreData &&
          statuesRequest != StatuesRequest.loading) {
        loadMoreChats();
      }
    });
  }

  getMyChats({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMoreData = true;
      myChats.clear();
      isInitialLoad = true;
    }

    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getuserChats(
        page: currentPage,
        perPage: perPage,
    );
    print("Response page $currentPage: $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      List<UserChatModel> newChats = responseBody
          .map(
            (e) => UserChatModel.fromJson(e),
          )
          .where(
            (element) =>
                (element.status == "Public" || element.status == "Private") ||
                (element.lastMessage != null &&
                    element.status != "Public" &&
                    element.status != "Private"),
          )
          .toList();

      if (isRefresh || currentPage == 1) {
        // Replace data on first load or refresh
        myChats = newChats;
      } else {
        // Append data for pagination
        myChats.addAll(newChats);
      }

      // Check if we have more data
      if (newChats.length < perPage) {
        hasMoreData = false;
      }

      isInitialLoad = false;
    }else{
                showUserFriendlyError(statuesRequest);

    }

    update();
  }

  loadMoreChats() async {
    if (isLoadingMore || !hasMoreData) return;

    isLoadingMore = true;
    currentPage++;
    update();

    var response = await _chatsRemoteData.getuserChats(
        page: currentPage,
        perPage: perPage,
    );
    print("Load more - page $currentPage: $response");

    StatuesRequest loadMoreStatus = handlingData(response);

    if (loadMoreStatus == StatuesRequest.success) {
      List responseBody = response['data'];
      List<UserChatModel> newChats = responseBody
          .map(
            (e) => UserChatModel.fromJson(e),
          )
          .toList();

      // Append new chats to existing list
      myChats.addAll(newChats);

      // Check if we have more data
      if (newChats.length < perPage) {
        hasMoreData = false;
      }
    } else {
      // Revert page increment on error
      currentPage--;
    }

    isLoadingMore = false;
    update();
  }

  Future<void> updateUI() async {
    // Update the UI
    update();
  }

  refreshChats() async {
    await getMyChats(isRefresh: true);
  }

  onPressChat() {
    Get.to(
      () => CreateChat(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
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

class PrivateChats extends StatelessWidget {
  PrivateChats({super.key});

  final controller = Get.put(PrivateChatsController());
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
            SizedBox(height: 5.h),
            Expanded(child: _buildChatList(controller)),
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
          onTap: () {
            Get.offAll(() => const HomeView());
          },
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
          S.of(context).yourPrivateChats,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildChatList(PrivateChatsController controller) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    return GetBuilder<PrivateChatsController>(
      builder: (controller) {
        // Initial loading
        if (controller.isInitialLoad && controller.myChats.isEmpty) {
          return const ChatListShimmer(itemCount: 8);
        }

        // Error handling for initial load
        if (controller.statuesRequest == StatuesRequest.socketException &&
            controller.myChats.isEmpty) {
          return Center(
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
                      pref! ? AppColors.whiteColor : AppColors.blackColor,
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
                      await controller.getMyChats(isRefresh: true);
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
                        pref! ? AppColors.blackColor : AppColors.whiteColor,
                        3.5.w,
                        FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (controller.myChats.isEmpty &&
            controller.statuesRequest == StatuesRequest.success) {
          return Center(child: noData(S.of(Get.context!).noChat));
        }

        // Main chat list
        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshChats();
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.scrollController,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              // Create new chat card at index 0
              if (index == 0) {
                return chatCardWidget(
                    power: null,
                    imageUrl: true,
                    numOfMessage: 0,
                    onPressImg: () {},
                    private: false,
                    img: const AssetImage(AppImages.noChatImg),
                    body: S.of(context).startCreatingNewWorld,
                    ttitle: S.of(context).newChat,
                    onPressJoin: controller.onPressChat,
                    isFriendsSection: false,
                    action: S.of(context).createNow,
                    ontap: controller.onPressChat,
                    needsAcceptance: false,
                );
              }

              // Actual chat index (subtract 1 for the create chat card)
              int chatIndex = index - 1;

              // Show loading at bottom when loading more
              if (chatIndex == controller.myChats.length &&
                  controller.isLoadingMore) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Center(child: loading(5.h)),
                );
              }

              // Return empty widget if index is beyond data
              if (chatIndex >= controller.myChats.length) {
                return const SizedBox.shrink();
              }

              // Regular chat item
              final chat = controller.myChats[chatIndex];
              return chatCardWidget(
                  power: null,
                  imageUrl: chat.image.toString() == "null" ||
                          chat.image == "" ||
                          chat.image == "image"
                      ? false
                      : true,
                  numOfMessage: chat.unreadCount!,
                  onPressImg: () {
                    dialogImgWidget(
                        title: chat.name!,
                        img: chat.image,
                        onPressChat: () {
                          homeController.onPressGroubChat(
                              chatModel: chat, isGust: false, id: chat.id);
                        },
                        userChatModel: null);
                  },
                  private: chat.status == "Private" ? true : false,
                  isFriend: true,
                  img: chat.image == "image" || chat.image.toString() == "null"
                      ? const AssetImage(AppImages.noChatImg)
                      : CachedNetworkImageProvider(chat.image!),
                  body: controller.myChats[chatIndex].lastMessage.toString() !=
                          "null"
                      ? controller.myChats[chatIndex].lastMessage!.senderId
                                  .toString() ==
                              sharedPreferences!.getString("id")
                          ? "${S.of(context).you}: ${controller.myChats[chatIndex].lastMessage!.messageType == "voice" ? S.of(context).voiceMessage : controller.myChats[chatIndex].lastMessage!.messageType == "image" ? S.of(context).image : controller.myChats[chatIndex].lastMessage!.message}"
                          : "${controller.myChats[chatIndex].lastMessage!.messageType == "voice" ? S.of(context).voiceMessage : controller.myChats[chatIndex].lastMessage!.messageType == "image" ? S.of(context).image : controller.myChats[chatIndex].lastMessage!.message}"
                      : "${controller.myChats[chatIndex].membersCount} ${S.of(context).engaged_people}",
                  ttitle: chat.name!,
                  onPressJoin: () {
                    homeController.onPressGroubChat(
                        chatModel: chat, isGust: false, id: chat.id);
                  },
                  action: S.of(context).joinNow,
                  ontap: () {
                    homeController.onPressGroubChat(
                        chatModel: chat, isGust: false, id: chat.id);
                  },
                  needsAcceptance: chat.accept == '1',
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemCount: controller.myChats.length +
                1 + // +1 for create chat card
                (controller.isLoadingMore ? 1 : 0) + // +1 for loading indicator
                (!controller.hasMoreData && controller.myChats.isNotEmpty
                    ? 1
                    : 0), // +1 for "no more" message
          ),
        );
      },
    );
  }
}
