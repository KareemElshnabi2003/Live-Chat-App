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

  @override
  Widget build(BuildContext context) {
    // 🚨 التعديل هنا: التأكد من تسجيل الـ Controller مرة واحدة
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
            // شيلنا الـ controller.refreshData() من الـ initState عشان ميحصلش تعارض
            await controller.refreshData();
          },
          color:
              AppColors.secondaryColor, // Customize the refresh indicator color
          backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Container
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
                  //height: 30.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => controller.onPressLogin(context),
                        child: Row(
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Image.asset(
                              AppImages.iconLoginImg,
                              width: 5.w,
                              height: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            textNormal(
                              S.of(context).log_in,
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackColor,
                              4.w,
                              FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 5.w,
                            backgroundColor: pref!
                                ? AppColors.secondaryColor
                                : AppColors.primaryColor,
                            child: CircleAvatar(
                              backgroundImage: const AssetImage(
                                  "lib/Images/play_store_512.png"),
                              radius: 4.w,
                            ),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          textNormal(
                            S.of(Get.context!).mayolivechat,
                            pref!
                                ? AppColors.secondaryColor
                                : AppColors.primaryColor,
                            3.5.w,
                            FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Row(
                        textDirection:
                            isRtl ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          textNormal(
                            S.of(context).positive_chat,
                            pref! ? AppColors.whiteColor : AppColors.blackColor,
                            4.w,
                            FontWeight.w400,
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            LucideIcons.pin300,
                            size: 5.w,
                            color: pref!
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      controller.statuesRequestGetData == StatuesRequest.loading
                          ? loading(10.h)
                          : controller.pinChatModel == null
                              ? Center(
                                  child: noData(S.of(context).noChat),
                                )
                              : chatCardWidget(
                                  power: null,
                                  imageUrl: controller.pinChatModel!
                                                  .conversation!.image
                                                  .toString() ==
                                              "null" ||
                                          controller.pinChatModel!.conversation!
                                                  .image ==
                                              "" ||
                                          controller.pinChatModel!.conversation!
                                                  .image
                                                  .toString() ==
                                              "image"
                                      ? false
                                      : true,
                                  numOfMessage: 0,
                                  onPressImg: () {
                                    dialogImgWidget(
                                        title: controller
                                            .pinChatModel!.conversation!.name!,
                                        img: null,
                                        onPressChat: () {
                                          controller.onPressPinChat(
                                            chatModel: controller
                                                .pinChatModel!.conversation!,
                                            id: controller
                                                .pinChatModel!.conversation!.id,
                                            isGust: true,
                                          );
                                        },
                                        userChatModel: controller
                                            .pinChatModel!.conversation!);
                                  },
                                  private: controller.pinChatModel!
                                              .conversation!.status ==
                                          "Private"
                                      ? true
                                      : false,
                                  img:
                                      controller.pinChatModel!.conversation!
                                                      .image ==
                                                  "image" ||
                                              controller.pinChatModel!
                                                      .conversation!.image ==
                                                  null ||
                                              controller.pinChatModel!
                                                      .conversation!.image ==
                                                  "null"
                                          ? const AssetImage(
                                              AppImages.noChatImg)
                                          : CachedNetworkImageProvider(
                                              controller.pinChatModel!
                                                  .conversation!.image!),
                                  body:
                                      "${controller.pinChatModel!.conversation!.membersCount} ${S.of(context).engaged_people}",
                                  ttitle: controller
                                      .pinChatModel!.conversation!.name!,
                                  action: S.of(context).join_now,
                                  onPressJoin: () {
                                    print(
                                        '''${sharedPreferences!.getString("tokenDevice")}
          ${sharedPreferences!.getString("token")}''');
                                    controller.onPressPinChat(
                                      chatModel: controller
                                          .pinChatModel!.conversation!,
                                      id: controller
                                          .pinChatModel!.conversation!.id,
                                      isGust: true,
                                    );
                                  },
                                  ontap: () {
                                    controller.onPressPinChat(
                                      id: controller
                                          .pinChatModel!.conversation!.id,
                                      chatModel: controller
                                          .pinChatModel!.conversation!,
                                      isGust: true,
                                    );
                                  },
                                )
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                InkWell(
                  onTap: controller.navigateToUpdatedChat,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textNormal(
                          S.of(context).latest_chats,
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                          4.w,
                          FontWeight.w400,
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          isRtl
                              ? LucideIcons.moveLeft300
                              : LucideIcons.moveRight300,
                          color: AppColors.secondaryColor,
                          size: 7.w,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                controller.statuesRequestGetData == StatuesRequest.loading
                    ? loading(10.h)
                    : controller.recentChats.isEmpty
                        ? Center(
                            child: noData(S.of(context).noChat),
                          )
                        : SizedBox(
                            // height: 42.w,
                            width: 100.w,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(
                                left: isRtl ? 0 : 4.w,
                                right: isRtl ? 4.w : 0,
                              ),
                              itemBuilder: (context, index) => chatCardWidget(
                                power: null,
                                imageUrl: controller.recentChats[index].image
                                                .toString() ==
                                            "null" ||
                                        controller.recentChats[index].image ==
                                            ""
                                    ? false
                                    : true,
                                numOfMessage: 0,
                                onPressImg: () {
                                  dialogImgWidget(
                                      title:
                                          controller.recentChats[index].name!,
                                      userChatModel:
                                          controller.recentChats[index],
                                      img: null,
                                      onPressChat: () {
                                        controller.onPressGroubChat(
                                            chatModel:
                                                controller.recentChats[index],
                                            isGust: true,
                                            id: controller
                                                .recentChats[index].id);
                                      });
                                },
                                private: controller.recentChats[index].status ==
                                        "Private"
                                    ? true
                                    : false,
                                img: controller.recentChats[index].image
                                            .toString() ==
                                        "null"
                                    ? const AssetImage(AppImages.noChatImg)
                                    : CachedNetworkImageProvider(
                                        "${controller.recentChats[index].image}"),
                                body:
                                    "${controller.recentChats[index].membersCount} ${S.of(context).engaged_people}",
                                ttitle: controller.recentChats[index].name!,
                                action: S.of(context).join_now,
                                onPressJoin: () {
                                  controller.onPressGroubChat(
                                      chatModel: controller.recentChats[index],
                                      isGust: true,
                                      id: controller.recentChats[index].id);
                                },
                                ontap: () {
                                  controller.onPressGroubChat(
                                      chatModel: controller.recentChats[index],
                                      isGust: true,
                                      id: controller.recentChats[index].id);
                                },
                              ),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 2.h),
                              itemCount: controller.recentChats.length,
                            ),
                          ),

                SizedBox(height: 3.h),
                InkWell(
                  onTap: controller.navigateToAnotherChats,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textNormal(
                          S.of(context).other_chats,
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                          4.5.w,
                          FontWeight.w400,
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          isRtl
                              ? LucideIcons.moveLeft300
                              : LucideIcons.moveRight300,
                          color: AppColors.secondaryColor,
                          size: 7.w,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                controller.statuesRequestGetData == StatuesRequest.loading
                    ? loading(10.h)
                    : controller.systemChats.isEmpty
                        ? Center(
                            child: noData(S.of(context).noChat),
                          )
                        : SizedBox(
                            width: 100.w,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(
                                left: isRtl ? 0 : 4.w,
                                right: isRtl ? 4.w : 0,
                              ),
                              itemBuilder: (context, index) => chatCardWidget(
                                power: null,
                                imageUrl: controller.systemChats[index].image
                                                .toString() ==
                                            "null" ||
                                        controller.systemChats[index].image ==
                                            ""
                                    ? false
                                    : true,
                                numOfMessage: 0,
                                onPressImg: () {
                                  dialogImgWidget(
                                    title: controller.systemChats[index].name!,
                                    userChatModel:
                                        controller.systemChats[index],
                                    img: null,
                                    onPressChat: () {
                                      controller.onPressGroubChat(
                                          chatModel:
                                              controller.systemChats[index],
                                          isGust: true,
                                          id: controller.systemChats[index].id);
                                    },
                                  );
                                },
                                private: controller.systemChats[index].status ==
                                        "Private"
                                    ? true
                                    : false,
                                img: controller.systemChats[index].image
                                            .toString() ==
                                        "null"
                                    ? const AssetImage(AppImages.noChatImg)
                                    : CachedNetworkImageProvider(
                                        controller.systemChats[index].image!),
                                body:
                                    "${controller.systemChats[index].membersCount} ${S.of(context).engaged_people}",
                                ttitle: controller.systemChats[index].name!,
                                action: S.of(context).join_now,
                                onPressJoin: () {
                                  controller.onPressGroubChat(
                                      chatModel: controller.systemChats[index],
                                      isGust: true,
                                      id: controller.systemChats[index].id);
                                },
                                ontap: () {
                                  controller.onPressGroubChat(
                                      chatModel: controller.systemChats[index],
                                      isGust: true,
                                      id: controller.systemChats[index].id);
                                },
                              ),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 2.h),
                              itemCount: controller.systemChats.length,
                            ),
                          ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
