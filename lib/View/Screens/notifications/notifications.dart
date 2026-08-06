import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/notify_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/notify_source.dart';
import 'package:live_chat/Data/Model/notify_mode.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class NotificationsController extends GetxController {
  String unReadNotify = '';
  List<NotifyModel> notifications = [];
  StatuesRequest statuesRequest = StatuesRequest.none;
  final _notifyRemoteData = NotifyRemoteData(api: Get.put(Api()));
  List titles = [];
  List contents = [];
  List images = [];
  onPressGroubChat(
      {required UserChatModel chatModel, required bool isGust, required id}) {
    Get.to(
      () => ChatView(
        userChatModel: chatModel,
        isPin: false,
        isGust: isGust,
      ),
      arguments: {"chatId": id},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  getNotify() async {
    notifications.clear();
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _notifyRemoteData.gwetNotify(
      page: 1,
      perPage: 5,
    );

    log("System chats response: $response");
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'] ?? [];

      notifications.addAll(responseBody
          .map(
            (e) => NotifyModel.fromJson(e),
          )
          .where((element) => element.title != ""));
      log("notify loaded: ${notifications.length} items");
    } else {          showUserFriendlyError(statuesRequest);
}
    update();
  }

  @override
  void onInit() {
    getNotify();
    super.onInit();
  }

  final isClearAllActive = true.obs;

  void clearNotifications() {
    notifications.clear();
    isClearAllActive.value = false;
  }
}

class Notifications extends StatelessWidget {
  Notifications({super.key});

  final controller = Get.put(NotificationsController());
  final notifyController = Get.put(NotifyController());
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    bool langAr = Get.locale == const Locale("ar") ? true : false;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(
            left: isRtl ? 4.w : 4.w, right: isRtl ? 4.w : 4.w, top: 5.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Row(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        isRtl
                            ? IconsaxPlusLinear.arrow_right_3
                            : IconsaxPlusLinear.arrow_left_1,
                        color:
                            pref! ? AppColors.whiteColor : AppColors.blackColor,
                        size: 5.5.w,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    textNormal(
                      S.of(context).notifications,
                      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                      4.5.w,
                      FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: GetBuilder<NotificationsController>(builder: (controller) {
                return controller.notifications.isNotEmpty
                    ? ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                            color: pref!
                                ? AppColors.black2TextColor
                                : AppColors.whiteColor),
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = controller.notifications[index];
                          String title = '';
                          String body = '';
                          if (notification.additionalData!['type'] ==
                                  "friend_request" &&
                              notification.additionalData!['status'] ==
                                  "pending") {
                            if (Get.locale == const Locale('ar')) {
                              title = 'طلب صداقة';
                              body =
                                  'أرسل إليك ${notification.additionalData!['username']} طلب صداقة';
                            } else {
                              title = 'Friend Request';
                              body =
                                  '${notification.additionalData!['username']} send you a friend request';
                            }
                          } else if (notification.additionalData!['type'] ==
                                  "friend_request" &&
                              notification.additionalData!['status'] ==
                                  "accepted") {
                            if (Get.locale == const Locale('ar')) {
                              title = 'طلب صداقة';
                              body =
                                  'تم قبول طلب الصداقة الذي أرسلته إلي  ${notification.additionalData!['username']}';
                            } else {
                              title = 'Friend Request';
                              body =
                                  'The friend request you sent to ${notification.additionalData!['username']} has been accepted.';
                            }
                          } else if (notification.additionalData!['status'] ==
                              "want_to_join_chat") {
                            if (Get.locale == const Locale('ar')) {
                              title = notification
                                  .additionalData!['conversation_name'];
                              body =
                                  'انضم ${notification.additionalData!['username']} إلي المحادثه : ${notification.additionalData!['conversation_name']}';
                            } else {
                              title = notification
                                  .additionalData!['conversation_name'];
                              body =
                                  '${notification.additionalData!['username']} join to chat : ${notification.additionalData!['conversation_name']}';
                            }
                          } else {
                            title = '';
                            body = "";
                            //no do thing
                          }
                          return InkWell(
                            onTap: () {
                              if (notification.additionalData!['type'] ==
                                      "friend_request" &&
                                  notification.additionalData!['status'] ==
                                      "pending") {
//go to page friend requesst
//type: friend_request, status: pending
                                Get.to(
                                  () => Requests(),
                                  transition: Transition.leftToRight,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOut,
                                );
                              } else if (notification.additionalData!['type'] ==
                                      "friend_request" &&
                                  notification.additionalData!['status'] ==
                                      "accepted") {
                                //go to page friends
// {image: , friend_id: 13, user_id: 11, status_number: 1, type: friend_request, status: accepted, username: كريم السيد}

                                Get.to(
                                  () => Friends(),
                                  transition: Transition.leftToRight,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOut,
                                );
                              } else if (notification
                                      .additionalData!['status'] ==
                                  "want_to_join_chat") {
                                //go to page chat who join

                                controller.onPressGroubChat(
                                    chatModel: UserChatModel.fromJson(
                                        notification
                                            .additionalData!['conversation']),
                                    isGust: false,
                                    id: notification
                                        .additionalData!['conversation']['id']);
//{image: , conversation_name: Kareem groub, user_id: 11, type: 3, status: want_to_join_chat, username: كريم السيد}
                              } else {}
                            },
                            child: Column(
                              children: [
                                Row(
                                  textDirection: isRtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  children: [
                                    Container(
                                      width: 18.w,
                                      height: 8.h,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        image: notification
                                                    .additionalData!['image'] ==
                                                null
                                            ? null
                                            : DecorationImage(
                                                image: CachedNetworkImageProvider(
                                                    "${notification.additionalData!['image']}")),
                                        color: pref!
                                            ? AppColors.darkcolor
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(45),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    SizedBox(
                                      width: 60.w,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        textDirection: isRtl
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              textNormal(
                                                title == ''
                                                    ? notification.title
                                                    : title,
                                                pref!
                                                    ? AppColors.whiteColor
                                                    : AppColors.blackColor,
                                                3.5.w,
                                                FontWeight.w500,
                                              ),
                                              SizedBox(height: 0.5.h),
                                              SizedBox(
                                                width: 50.w,
                                                child: textNormal(
                                                  multi: true,
                                                  numOfRow: 2,
                                                  body == ""
                                                      ? notification.content
                                                      : body,
                                                  pref!
                                                      ? AppColors.inActiveColor
                                                      : AppColors
                                                          .black2TextColor,
                                                  3.5.w,
                                                  FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              textNormal(
                                                langAr
                                                    ? notifyController
                                                        .formatToReadableDateTimeArabic(
                                                            notification.date!)
                                                    : notifyController
                                                        .formatToReadableDateTime(
                                                            notification.date!),
                                                pref!
                                                    ? AppColors.inActiveColor
                                                    : AppColors.black2TextColor,
                                                3.5.w,
                                                FontWeight.w500,
                                              ),
                                              SizedBox(height: 0.5.h),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      size: 5.w,
                                      isRtl
                                          ? LucideIcons.moveLeft300
                                          : LucideIcons.moveRight300,
                                      color: pref!
                                          ? AppColors.whiteColor
                                          : AppColors.blackColor,
                                    )
                                  ],
                                ),
                                SizedBox(height: 2.h),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.bell100,
                              size: 17.w,
                              color: pref!
                                  ? AppColors.inActiveColor
                                  : AppColors.black2TextColor,
                            ),
                            SizedBox(height: 2.h),
                            textNormal(
                              S.of(context).noNotifications,
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.black2TextColor,
                              4.w,
                              FontWeight.w500,
                            ),
                            SizedBox(height: 2.h),
                            textNormal(
                              center: true,
                              S.of(context).noNotificationsDescription,
                              pref!
                                  ? AppColors.inActiveColor
                                  : AppColors.black2TextColor,
                              3.5.w,
                              FontWeight.w400,
                            ),
                          ],
                        ),
                      );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
