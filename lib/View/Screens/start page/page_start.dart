// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/page_start_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Widget/PublicWidget/chat_card_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class PageStart extends StatelessWidget {
  const PageStart({super.key});

  bool _isValidImage(String? url) {
    return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PageStartController>()) {
      Get.put(PageStartController());
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: GetBuilder<PageStartController>(
        builder: (controller) => RefreshIndicator(
          onRefresh: () async {
            print("refresh");
            await controller.refreshData();
          },
          color: AppColors.secondaryColor,
          backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==============================
                // 1. حاوية الهيدر وتسجيل الدخول والدردشة المثبتة
                // ==============================
                Container(
                  padding: EdgeInsets.only(
                    left: isRtl ? 0 : 4.w,
                    right: isRtl ? 4.w : 0,
                    top: 5.h,
                    bottom: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => controller.onPressLogin(context),
                        child: Row(
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Image.asset(AppImages.iconLoginImg, width: 5.w, height: 5.w),
                            SizedBox(width: 2.w),
                            textNormal(S.of(context).log_in, pref! ? AppColors.whiteColor : AppColors.blackColor, 4.w, FontWeight.w400),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 5.w,
                            backgroundColor: pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                            child: CircleAvatar(backgroundImage: const AssetImage("lib/Images/play_store_512.png"), radius: 4.w),
                          ),
                          SizedBox(width: 2.w),
                          textNormal(S.of(Get.context!).mayolivechat, pref! ? AppColors.secondaryColor : AppColors.primaryColor, 3.5.w, FontWeight.bold),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // ==============================
                      // 2. Pinned Chat Section (يظهر فقط إذا كان هناك محادثة وميعادها شغال)
                      // ==============================
                      if (controller.statuesRequestGetData == StatuesRequest.loading)
                        loading(10.h)
                      else if (controller.pinChatModel != null && controller.pinChatModel!.conversation != null) ...[
                        Row(
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            textNormal(S.of(context).positive_chat, pref! ? AppColors.whiteColor : AppColors.blackColor, 4.w, FontWeight.w400),
                            SizedBox(width: 2.w),
                            Icon(LucideIcons.pin300, size: 5.w, color: pref! ? AppColors.whiteColor : AppColors.blackColor),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Builder(
                          builder: (context) {
                            final pinChat = controller.pinChatModel!.conversation!;
                            final hasValidImage = _isValidImage(pinChat.image);

                            return chatCardWidget(
                              needsAcceptance: pinChat.accept=="1"?true:false,

                              power: null,
                              imageUrl: hasValidImage,
                              numOfMessage: 0,
                              onPressImg: () {
                                dialogImgWidget(
                                  title: pinChat.name!,
                                  img: null,
                                  userChatModel: pinChat,
                                  onPressChat: () => controller.onPressPinChat(chatModel: pinChat, id: pinChat.id, isGust: true),
                                );
                              },
                              private: pinChat.status == "Private",
                              img: hasValidImage
                                  ? CachedNetworkImageProvider(pinChat.image!.trim())
                                  : const AssetImage(AppImages.noChatImg),
                              body: "${pinChat.membersCount} ${S.of(context).engaged_people}",
                              ttitle: pinChat.name!,
                              action: S.of(context).join_now,
                              onPressJoin: () => controller.onPressPinChat(chatModel: pinChat, id: pinChat.id, isGust: true),
                              ontap: () => controller.onPressPinChat(id: pinChat.id, chatModel: pinChat, isGust: true),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 3.h),

                // ==============================
                // 3. Latest Chats Section
                // ==============================
                InkWell(
                  onTap: controller.navigateToUpdatedChat,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textNormal(S.of(context).latest_chats, pref! ? AppColors.whiteColor : AppColors.blackColor, 4.w, FontWeight.w400),
                        SizedBox(width: 2.w),
                        Icon(isRtl ? LucideIcons.moveLeft300 : LucideIcons.moveRight300, color: AppColors.secondaryColor, size: 7.w),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                controller.statuesRequestGetData == StatuesRequest.loading
                    ? loading(10.h)
                    : controller.recentChats.isEmpty
                    ? Center(child: noData(S.of(context).noChat))
                    : SizedBox(
                  width: 100.w,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0),
                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                    itemCount: controller.recentChats.length,
                    itemBuilder: (context, index) {
                      final chat = controller.recentChats[index];
                      final hasValidImage = _isValidImage(chat.image);

                      return chatCardWidget(

                        needsAcceptance: chat.accept=="1"?true:false,

                        power: null,
                        imageUrl: hasValidImage,
                        numOfMessage: 0,
                        onPressImg: () {
                          dialogImgWidget(
                            title: chat.name!,
                            userChatModel: chat,
                            img: null,
                            onPressChat: () => controller.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
                          );
                        },
                        private: chat.status == "Private",
                        img: hasValidImage
                            ? CachedNetworkImageProvider(chat.image!.trim())
                            : const AssetImage(AppImages.noChatImg),
                        body: "${chat.membersCount} ${S.of(context).engaged_people}",
                        ttitle: chat.name!,
                        action: S.of(context).join_now,
                        onPressJoin: () => controller.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
                        ontap: () => controller.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
                      );
                    },
                  ),
                ),

                SizedBox(height: 3.h),

                // ==============================
                // 4. Other Chats Section
                // ==============================
                InkWell(
                  onTap: controller.navigateToAnotherChats,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textNormal(S.of(context).other_chats, pref! ? AppColors.whiteColor : AppColors.blackColor, 4.5.w, FontWeight.w400),
                        SizedBox(width: 2.w),
                        Icon(isRtl ? LucideIcons.moveLeft300 : LucideIcons.moveRight300, color: AppColors.secondaryColor, size: 7.w),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                controller.statuesRequestGetData == StatuesRequest.loading
                    ? loading(10.h)
                    : controller.systemChats.isEmpty
                    ? Center(child: noData(S.of(context).noChat))
                    : SizedBox(
                  width: 100.w,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0),
                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                    itemCount: controller.systemChats.length,
                    itemBuilder: (context, index) {
                      final chat = controller.systemChats[index];
                      final hasValidImage = _isValidImage(chat.image);

                      return chatCardWidget(
                        needsAcceptance: chat.accept=="1"?true:false,

                        power: null,
                        imageUrl: hasValidImage,
                        numOfMessage: 0,
                        onPressImg: () {
                          dialogImgWidget(
                            title: chat.name!,
                            userChatModel: chat,
                            img: null,
                            onPressChat: () => controller.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
                          );
                        },
                        private: chat.status == "Private",
                        img: hasValidImage
                            ? CachedNetworkImageProvider(chat.image!.trim())
                            : const AssetImage(AppImages.noChatImg),
                        body: "${chat.membersCount} ${S.of(context).engaged_people}",
                        ttitle: chat.name!,
                        action: S.of(context).join_now,
                        onPressJoin: () => controller.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
                        ontap: () => controller.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}