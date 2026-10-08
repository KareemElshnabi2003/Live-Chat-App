// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Controller/requests_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

// 🌟 دالة مساعدة مركزية للصور
bool _isValidImage(String? url) {
  return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
}

// ignore: non_constant_identifier_names
Widget FriendsRequestCard({
  required ImageProvider img,
  required PowerModel? power,
  required VoidCallback onPressImg,
  required VoidCallback onPressChat,
  required bool imgUrl,
  required String ttitle,
  required String body,
  VoidCallback? onPressAccept,
  VoidCallback? onPressReject,
  VoidCallback? onPressCancel,
  bool isSentRequest = false,
}) {
  final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
  return Padding(
    padding: EdgeInsets.only(left: isRtl ? 0.w : 4.w, right: isRtl ? 4.w : 0.w),
    child: SizedBox(
      height: 19.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              imgUrl
                  ? InkWell(
                onTap: onPressImg,
                child: Container(width: 19.w, height: 19.w, decoration: BoxDecoration(color: pref! ? AppColors.darkcolor : null, image: DecorationImage(image: img, fit: BoxFit.fill), borderRadius: BorderRadius.circular(80))),
              )
                  : InkWell(
                onTap: onPressImg,
                child: Container(alignment: Alignment.center, width: 19.w, height: 19.w, decoration: BoxDecoration(color: pref! ? AppColors.darkcolor : AppColors.black2TextColor, borderRadius: BorderRadius.circular(80)), child: textNormal(ttitle.isNotEmpty ? ttitle[0] : '', AppColors.whiteColor, 7.w, FontWeight.bold)),
              ),
              SizedBox(width: 2.w),
              InkWell(
                onTap: onPressChat,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    power != null ? PowerTextWidget(powerModel: power, displyText: ttitle) : textNormal(ttitle, pref! ? AppColors.whiteColor : AppColors.blackTextColor, 3.5.w, FontWeight.w400),
                    const Spacer(flex: 1),
                    textNormal(body, pref! ? AppColors.inActiveColor : AppColors.black2TextColor, 3.w, FontWeight.w500),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (!isRtl) SizedBox(width: 4.w),
              if (isSentRequest)
                 InkWell(
                   onTap: onPressCancel, 
                   child: Container(
                     height: 10.w, // ارتفاع محدد عشان ميمطش
                     padding: EdgeInsets.symmetric(horizontal: 4.w),
                     decoration: ShapeDecoration(
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.redColor))
                     ), 
                     child: Center(child: Text(S.of(Get.context!).cancel, style: TextStyle(color: AppColors.redColor, fontSize: 3.w, fontWeight: FontWeight.bold)))
                   )
                 )
              else ...[
                InkWell(onTap: onPressAccept, child: Container(height: 12.w, width: 12.w, decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: pref! ? AppColors.whiteColor : AppColors.blackColor), borderRadius: BorderRadius.circular(16))), child: Center(child: Icon(Icons.check, color: pref! ? AppColors.whiteColor : AppColors.blackColor, size: 6.w)))),
                const SizedBox(width: 15),
                InkWell(onTap: onPressReject, child: Container(height: 12.w, width: 12.w, decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.redColor))), child: Center(child: Icon(Icons.close, color: AppColors.redColor, size: 6.w)))),
              ],
              if (isRtl) SizedBox(width: 4.w),
            ],
          ),
        ],
      ),
    ),
  );
}

class Requests extends StatelessWidget {
  Requests({super.key});

  final controller = Get.put(RequestsController());
  final homeController = Get.put(HomeNavigationController());

  Widget _buildTabBadge(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        if (count > 0) ...[
          SizedBox(width: 2.w),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.redColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                color: Colors.white,
                fontSize: 2.8.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
        body: Padding(
          padding: EdgeInsets.only(left: isRtl ? 0.w : 4.w, right: isRtl ? 4.w : 0.w, top: 5.h, bottom: 2.h),
          child: GetBuilder<RequestsController>(
            builder: (controller) => Column(
              children: [
                _buildHeader(context, isRtl),
                SizedBox(height: 2.h),
                TabBar(
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  indicatorColor: AppColors.primaryColor,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(child: _buildTabBadge(isRtl ? 'مستلمة' : 'Received', controller.friends.length)),
                    Tab(child: _buildTabBadge(isRtl ? 'مرسلة' : 'Sent', controller.sentRequests.length)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      RefreshIndicator(
                        onRefresh: controller.refreshData,
                        color: AppColors.secondaryColor,
                        backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
                        child: _buildChatList(controller, false),
                      ),
                      RefreshIndicator(
                        onRefresh: controller.refreshData,
                        color: AppColors.secondaryColor,
                        backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
                        child: _buildChatList(controller, true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            GestureDetector(
                onTap: () => Get.off(() => Friends(), transition: Transition.leftToRight, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                child: Icon(isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1, size: 5.5.w, color: pref! ? AppColors.whiteColor : AppColors.blackColor)
            ),
            SizedBox(width: 2.w),
            textNormal(S.of(context).requests, pref! ? AppColors.whiteColor : AppColors.blackTextColor, 4.5.w, FontWeight.w500),
          ],
        ),
      ],
    );
  }

  Widget _buildChatList(RequestsController controller, bool isSent) {
    return Obx(() {
      final list = isSent ? controller.sentRequests : controller.friends;
      if (controller.statuesRequest == StatuesRequest.loading && list.isEmpty) return loading(80.h);
      if (list.isEmpty) {
        return controller.statuesRequest == StatuesRequest.socketException
            ? messageErrorWithButton(S.of(Get.context!).error, S.of(Get.context!).noInternet, () => controller.getFriends(page: 1), S.of(Get.context!).retry)
            : Center(child: SizedBox(width: 80.w, child: noData(S.of(Get.context!).notFriendRequest)));
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 2.h),
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          if (index == list.length) return controller.statuesRequest == StatuesRequest.loading && list.isNotEmpty ? Padding(padding: EdgeInsets.symmetric(vertical: 2.h), child: loading(10.h)) : const SizedBox.shrink();

          final friend = list[index];
          final hasValidImg = _isValidImage(friend.image);

          return FriendsRequestCard(
            isSentRequest: isSent,
            onPressCancel: isSent ? () => controller.cancelRequest(friendID: friend.id!) : null,
            onPressChat: () => controller.createChatFriend(friendID: friend.id!, isSentRequest: isSent),
            power: friend.power,
            imgUrl: hasValidImg,
            onPressImg: () => dialogImgWidget(
                title: friend.username!,
                img: friend.image,
                onPressChat: () => controller.createChatFriend(friendID: friend.id!, isSentRequest: isSent),
                userChatModel: null
            ),
            onPressAccept: isSent ? null : () => controller.acceptFriend(friendID: friend.id!),
            onPressReject: isSent ? null : () => controller.rejectFriend(friendID: friend.id!),
            img: hasValidImg ? CachedNetworkImageProvider(friend.image!.trim()) : const AssetImage(AppImages.noChatImg),
            body: isSent ? S.of(context).youSendRequest : S.of(context).sendToYouRequest,
            ttitle: friend.username!,
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
      );
    });
  }
}