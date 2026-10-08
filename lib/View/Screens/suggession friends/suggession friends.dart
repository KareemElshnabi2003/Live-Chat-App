// ignore_for_file: file_names, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Controller/suggested_friends_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/sugessted_friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SuggessionChat extends StatelessWidget {
  SuggessionChat({super.key});

  final SuggessionChatController controller =
      Get.put(SuggessionChatController());
  final HomeNavigationController homeController =
      Get.put(HomeNavigationController());

  bool _isValidImage(String? url) {
    return url != null &&
        url.trim().isNotEmpty &&
        url.trim() != "null" &&
        url.trim() != "image";
  }

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
          builder: (controller) => _buildChatList(controller),
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
          onTap: () => Get.offAll(() => const HomeView()),
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

  Widget _buildChatList(SuggessionChatController controller) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    if (controller.statuesRequest == StatuesRequest.loading &&
        controller.friendsSuggestion.isEmpty) {
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
                ? _buildNetworkError(controller, isRtl)
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
                  children: [_buildHeader(context), SizedBox(height: 6.h)]);
            } else if (index <= controller.friendsSuggestion.length) {
              final friendIndex = index - 1;
              final friend = controller.friendsSuggestion[friendIndex];
              final hasValidImage =
                  _isValidImage(friend.image); // 🌟 فحص الصورة

              print("valid Image >> $hasValidImage");
              print("Image >> ${friend.image}");
              print("friendname >> ${friend.name}");
              print("friend >> ${friend.toJson()}");
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: SuggestedFriends(
                  power: friend.power,
                  imgUrl: hasValidImage,
                  onPressImg: () {
                    dialogImgWidget(
                      title: friend.name!,
                      img: friend.image,
                      userChatModel: null,
                      onPressChat: () => controller.createChatFriend(
                          friendID: friend.id!,
                          requestStatus: friend.requestStatus!,
                          index: friendIndex),
                    );
                  },
                  chat: () => controller.createChatFriend(
                      friendID: friend.id!,
                      requestStatus: friend.requestStatus!,
                      index: friendIndex),
                  removeRequest: () => controller.sendFriendRequest(
                      index: friendIndex, friendID: friend.id),
                  requestSend: friend.requestStatus != "none",
                  sendRequest: () => controller.sendFriendRequest(
                      index: friendIndex, friendID: friend.id),
                  img: hasValidImage
                      ? CachedNetworkImageProvider(friend.image!.trim())
                      : const AssetImage(AppImages.noChatImg),
                  body: friend.requestStatus == "none"
                      ? S.of(context).notFriend
                      : S.of(context).requestWaiting,
                  ttitle: friend.username ?? "",
                ),
              );
            } else {
              return controller.statuesRequest == StatuesRequest.loading &&
                      controller.friendsSuggestion.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: loading(10.h))
                  : const SizedBox.shrink();
            }
          },
        ),
      );
    }
  }

  Widget _buildNetworkError(SuggessionChatController controller, bool isRtl) {
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
                  shape: BoxShape.circle),
              child: Icon(LucideIcons.wifiOff,
                  size: 20.w, color: AppColors.secondaryColor),
            ),
            SizedBox(height: 3.h),
            textNormal(
                isRtl ? "لا يوجد اتصال بالإنترنت" : "No Internet Connection",
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
              onPressed: () async =>
                  await controller.getfriendesSuggestion(page: 1),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              icon: Icon(LucideIcons.refreshCw,
                  size: 5.w,
                  color: pref! ? AppColors.blackColor : AppColors.whiteColor),
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
}
