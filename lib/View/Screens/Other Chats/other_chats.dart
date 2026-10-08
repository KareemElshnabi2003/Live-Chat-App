// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Widget/PublicWidget/chat_card_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OtherChatsController extends GetxController {
  final HomeNavigationController homeController = Get.find();
  StatuesRequest statuesRequest = StatuesRequest.none;
  Future<List<UserChatModel>>? _systemChatsFuture;

  @override
  void onInit() {
    super.onInit();
    _systemChatsFuture = homeController.getSystemChats();
  }

  Future<List<UserChatModel>> getSystemChats() async {
    return _systemChatsFuture ??= homeController.getSystemChats();
  }

  void onPressChat() {
    Get.to(
      () => CreateChat(),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

class OtherChats extends StatelessWidget {
  OtherChats({super.key});

  final OtherChatsController controller = Get.put(OtherChatsController());

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(
            left: isRtl ? 2.w : 4.w,
            right: isRtl ? 4.w : 2.w,
            top: 2.h,
            bottom: 2.h),
        child: ListView(
          children: [
            _buildHeader(context),
            SizedBox(height: 6.h),
            _buildChatList(),
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
          S.of(context).other_chats,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildChatList() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return FutureBuilder<List<UserChatModel>>(
      future: controller.getSystemChats(),
      initialData: controller.homeController.systemChats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading(10.h);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return controller.homeController.statuesRequest ==
                  StatuesRequest.socketException
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
                            await controller.getSystemChats();
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
              : Center(child: noData(S.of(context).noChat));
        } else {
          return SizedBox(
            width: 100.w,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                  right: isRtl ? 0.w : 2.w, left: isRtl ? 2.w : 0.w),
              itemBuilder: (context, index) {
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
                final chat = snapshot.data![index - 1];
                return chatCardWidget(
                  power: null,
                  imageUrl: chat.image.toString() == "null" || chat.image == ""
                      ? false
                      : true,
                  numOfMessage: 0,
                  onPressImg: () {
                    dialogImgWidget(
                        title: chat.name!,
                        img: chat.image,
                        onPressChat: () {
                          controller.homeController.onPressGroubChat(
                            chatModel: chat,
                            isGust: false,
                            id: chat.id,
                          );
                        },
                        userChatModel: null);
                  },
                  private: chat.status == "Private" ? true : false,
                  img: chat.image == null || chat.image == "null"
                      ? const AssetImage(AppImages.noChatImg)
                      : CachedNetworkImageProvider(chat.image!),
                  body: "${chat.membersCount} ${S.of(context).engaged_people}",
                  ttitle: chat.name!,
                  onPressJoin: () {
                    controller.homeController.onPressGroubChat(
                      chatModel: chat,
                      isGust: false,
                      id: chat.id,
                    );
                  },
                  action: S.of(context).joinNow,
                  ontap: () {
                    controller.homeController.onPressGroubChat(
                      chatModel: chat,
                      isGust: false,
                      id: chat.id,
                    );
                  },
                  needsAcceptance: chat.accept == '1',
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemCount: snapshot.data!.length + 1,
            ),
          );
        }
      },
    );
  }
}
