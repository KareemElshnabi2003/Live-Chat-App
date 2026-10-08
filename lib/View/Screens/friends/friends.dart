import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Controller/friends_chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/friend_suggest_model.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ignore: non_constant_identifier_names
Widget FriendsChatCard({
  required ImageProvider img,
  required PowerModel? power,
  required String ttitle,
  required String body,
  required bool imgUrl,
  required VoidCallback onPressJoin,
  required VoidCallback onPressRemove,
  required VoidCallback onPressImg,
  bool isFriendsSection = false,
  bool isFriend = true,
}) {
  final controller = Get.find<FriendsChatContoller>();
  final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

  return SizedBox(
    height: 19.w,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        InkWell(
          onTap: onPressJoin,
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              _buildProfileImage(img, ttitle, imgUrl, isFriendsSection, onPressImg),
              SizedBox(width: 2.w),
              _buildChatDetails(power, ttitle, body, isFriend, onPressJoin),
            ],
          ),
        ),
        _buildActionButton(controller, isFriend, onPressRemove, isRtl),
      ],
    ),
  );
}

Widget _buildProfileImage(ImageProvider img, String ttitle, bool imgUrl, bool isFriendsSection, VoidCallback onPressImg) {
  return InkWell(
    onTap: onPressImg,
    child: Container(
      width: 19.w,
      height: 19.w,
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.black2TextColor,
        image: imgUrl ? DecorationImage(image: img, fit: BoxFit.fill) : null,
        borderRadius: BorderRadius.circular(isFriendsSection ? 80 : 20),
      ),
      child: imgUrl ? null : Center(child: textNormal(ttitle.isNotEmpty ? ttitle[0] : '', AppColors.whiteColor, 7.w, FontWeight.bold)),
    ),
  );
}

Widget _buildChatDetails(PowerModel? power, String ttitle, String body, bool isFriend, VoidCallback onPressJoin) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      power != null
          ? PowerTextWidget(powerModel: power, displyText: ttitle)
          : textNormal(ttitle, pref! ? AppColors.whiteColor : AppColors.blackTextColor, 3.5.w, FontWeight.w400),
      const Spacer(flex: 1),
      textNormal(body, isFriend ? (pref! ? AppColors.inActiveColor : AppColors.black2TextColor) : AppColors.secondaryColor, 3.w, FontWeight.w500),
      const Spacer(flex: 2),
      textClick(isFriend ? S.of(Get.context!).correspondent : S.of(Get.context!).cancel, false, onPressJoin, isFriend ? (pref! ? AppColors.secondaryColor : AppColors.primaryColor) : AppColors.redColor, 3.w),
    ],
  );
}

Widget _buildActionButton(FriendsChatContoller controller, bool isFriend, VoidCallback onPressRemove, bool isRtl) {
  return Obx(
        () => InkWell(
      onTap: onPressRemove,
      child: Container(
        padding: EdgeInsets.only(right: isRtl ? 2.w : 6.w, left: isRtl ? 6.w : 2.w),
        height: 14.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: controller.isEditing.value ? (pref! ? AppColors.darkcolor : AppColors.bgColor) : (pref! ? AppColors.blackColor : AppColors.whiteColor),
          borderRadius: BorderRadius.only(
            topLeft: isRtl ? Radius.zero : const Radius.circular(20),
            bottomLeft: isRtl ? Radius.zero : const Radius.circular(20),
            topRight: isRtl ? const Radius.circular(20) : Radius.zero,
            bottomRight: isRtl ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        child: Container(
          height: 12.w,
          width: 12.w,
          decoration: ShapeDecoration(color: pref! ? AppColors.blackColor : AppColors.bgColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: Center(
            child: Icon(
              controller.isEditing.value ? (isFriend ? IconsaxPlusLinear.profile_delete : Icons.close) : (isFriend ? (isRtl ? IconsaxPlusLinear.arrow_left : IconsaxPlusLinear.arrow_right) : Icons.close),
              color: controller.isEditing.value ? Colors.red : (pref! ? AppColors.whiteColor : AppColors.blackColor),
              size: 6.w,
            ),
          ),
        ),
      ),
    ),
  );
}

class Friends extends StatelessWidget {
  Friends({super.key});

  final FriendsChatContoller controller = Get.put(FriendsChatContoller());
  final HomeNavigationController homeController = Get.put(HomeNavigationController());

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0, top: 5.h, bottom: 2.h),
        child: GetBuilder<FriendsChatContoller>(
          builder: (controller) => RefreshIndicator(
            onRefresh: controller.refreshData,
            color: AppColors.secondaryColor,
            backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
            child: ListView(
              controller: controller.scrollController,
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(context, isRtl),
                SizedBox(height: 5.h),
                _buildChatList(),
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
              onTap: () => Get.offAll(() => const HomeView()),
              child: Icon(isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1, size: 5.5.w, color: pref! ? AppColors.whiteColor : AppColors.blackColor),
            ),
            SizedBox(width: 2.w),
            textNormal(S.of(context).yourFriends, pref! ? AppColors.whiteColor : AppColors.blackTextColor, 4.5.w, FontWeight.w500),
          ],
        ),
        Row(
          children: [
            // 🌟 تعديل زرار طلبات الصداقة والعداد
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Obx(() => Row( // 🌟 استخدمنا Row عشان العداد يبقى جنب الكلمة بشكل شيك
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  textClick(S.of(context).requests, true, homeController.navigateToRequests, pref! ? AppColors.whiteColor : AppColors.blackTextColor, 3.5.w),
                  SizedBox(width: 1.5.w),

                  // 🌟 العداد (يظهر دايماً ويتغير لونه حسب القيمة)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      // 🌟 ذكاء الألوان: أحمر لو في طلبات، لونك الأساسي لو مفيش
                      color: controller.pendingRequestsCount.value > 0
                          ? AppColors.redColor
                          : (pref! ? AppColors.secondaryColor : AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${controller.pendingRequestsCount.value}",
                      style: TextStyle(
                          color: controller.pendingRequestsCount.value > 0
                              ? Colors.white
                              : (pref! ? AppColors.blackColor : Colors.white),
                          fontSize: 3.w,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              )),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Obx(() => textClick(controller.isEditing.value ? S.of(context).cancel : S.of(context).edit, true, controller.toggleEdit, pref! ? AppColors.whiteColor : AppColors.blackTextColor, 3.5.w))
            ),
            SizedBox(width: 2.w)
          ],
        ),
      ],
    );
  }
  Widget _buildChatList() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    return Obx(() {
      if (controller.statuesRequest == StatuesRequest.loading && controller.friends.isEmpty) return loading(80.h);
      if (controller.friends.isEmpty) {
        return controller.statuesRequest == StatuesRequest.socketException
            ? Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 17.h),
                Container(padding: EdgeInsets.all(6.w), decoration: BoxDecoration(color: AppColors.secondaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(LucideIcons.wifiOff, size: 20.w, color: AppColors.secondaryColor)),
                SizedBox(height: 3.h),
                textNormal(isRtl ? "لا يوجد اتصال بالإنترنت" : "No Internet Connection", pref! ? AppColors.whiteColor : AppColors.blackColor, 4.5.w, FontWeight.w700),
                SizedBox(height: 2.h),
                textNormal(isRtl ? "يرجى التحقق من اتصالك بالإنترنت" : "Please check your internet connection", pref! ? AppColors.inActiveColor : AppColors.blackColor.withOpacity(0.6), 3.5.w, FontWeight.w600),
                SizedBox(height: 4.h),
                ElevatedButton.icon(
                  onPressed: () async => await controller.getFriends(page: 1),
                  style: ElevatedButton.styleFrom(backgroundColor: pref! ? AppColors.secondaryColor : AppColors.primaryColor, padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 2),
                  icon: Icon(LucideIcons.refreshCw, size: 5.w, color: pref! ? AppColors.blackColor : AppColors.whiteColor),
                  label: textNormal(isRtl ? "إعادة المحاولة" : "Try Again", pref! ? AppColors.blackColor : AppColors.whiteColor, 3.5.w, FontWeight.w600),
                ),
              ],
            ),
          ),
        )
            : Center(child: noData(S.of(Get.context!).noChat));
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: controller.friends.length + 1,
        itemBuilder: (context, index) => index == controller.friends.length ? _buildLoadingIndicator() : _buildFriendItem(controller.friends[index]),
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
      );
    });
  }

  Widget _buildLoadingIndicator() {
    return controller.statuesRequest == StatuesRequest.loading && controller.friends.isNotEmpty
        ? Padding(padding: EdgeInsets.symmetric(vertical: 2.h), child: loading(10.h))
        : const SizedBox.shrink();
  }

  Widget _buildFriendItem(SuggestFreindModel friend) {
    // 🌟 الفحص الذكي للصور
    bool isValidImage(String? url) {
      return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
    }

    final hasValidImg = isValidImage(friend.image);

    return FriendsChatCard(
      onPressImg: () => dialogImgWidget(
        title: friend.username!,
        img: friend.image,
        onPressChat: () { if (friend.requestStatus == "friends") controller.createChatFriend(friendID: friend.id!); },
        userChatModel: null,
      ),
      imgUrl: hasValidImg,
      power: friend.power,
      isFriend: friend.requestStatus == "friends",
      isFriendsSection: true,
      onPressRemove: () {
        if (controller.isEditing.value) {
          if (friend.requestStatus == "friends") controller.removeFriend(friendID: friend.id!);
        } else {
          if (friend.requestStatus == "friends") controller.createChatFriend(friendID: friend.id!);
        }
      },
      img: hasValidImg ? CachedNetworkImageProvider(friend.image!.trim()) : const AssetImage(AppImages.noChatImg),
      body: friend.requestStatus == "friends" ? S.of(Get.context!).friend : S.of(Get.context!).requestWaiting,
      ttitle: friend.username!,
      onPressJoin: () { if (friend.requestStatus == "friends") controller.createChatFriend(friendID: friend.id!); },
    );
  }
}