import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/notification_controller.dart';
import 'package:live_chat/Controller/notify_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

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
            // 🌟 الـ AppBar الثابت
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
                        color: pref! ? AppColors.whiteColor : AppColors.blackColor,
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
            SizedBox(height: 2.h),

            // 🌟 المحتوى (الإشعارات)
            Expanded(
              child: GetBuilder<NotificationsController>(builder: (controller) {
                if (controller.statuesRequest == StatuesRequest.loading && controller.currentPage == 1) {
                  return loading(10.h);
                }

                if (controller.notifications.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  color: AppColors.secondaryColor,
                  backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
                  onRefresh: () => controller.getNotify(isRefresh: true),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.notifications.length + (controller.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.notifications.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: loading(5.h), // 🌟 شكل التحميل من تحت
                        );
                      }

                      final notification = controller.notifications[index];
                      return _buildNotificationCard(notification, isRtl, langAr, controller);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 تصميم كارت الإشعار
  Widget _buildNotificationCard(notification, bool isRtl, bool langAr, NotificationsController controller) {
    String title = '';
    String body = '';

    // معالجة النصوص حسب النوع
    if (notification.additionalData!['type'] == "friend_request" && notification.additionalData!['status'] == "pending") {
      title = langAr ? 'طلب صداقة' : 'Friend Request';
      body = langAr ? 'أرسل إليك ${notification.additionalData!['username']} طلب صداقة'
          : '${notification.additionalData!['username']} send you a friend request';
    } else if (notification.additionalData!['type'] == "friend_request" && notification.additionalData!['status'] == "accepted") {
      title = langAr ? 'طلب صداقة' : 'Friend Request';
      body = langAr ? 'تم قبول طلب الصداقة الذي أرسلته إلي ${notification.additionalData!['username']}'
          : 'The friend request you sent to ${notification.additionalData!['username']} has been accepted.';
    } else if (notification.additionalData!['status'] == "want_to_join_chat") {
      title = notification.additionalData!['conversation_name'];
      body = langAr ? 'انضم ${notification.additionalData!['username']} إلي المحادثه : ${notification.additionalData!['conversation_name']}'
          : '${notification.additionalData!['username']} join to chat : ${notification.additionalData!['conversation_name']}';
    } else {
      title = notification.title ?? '';
      body = notification.content ?? '';
    }

    // 🌟 معالجة رابط الصورة بأمان
    String imageUrl = (notification.additionalData?['image']?.toString().contains("https") ?? false)
        ? notification.additionalData!['image'].toString()
        : "https://api.mayo.live/storage/${notification.additionalData?['image'] ?? ''}";

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: pref! ? [] : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (notification.additionalData!['type'] == "friend_request" && notification.additionalData!['status'] == "pending") {
            Get.to(() => Requests(), transition: Transition.leftToRight, duration: const Duration(milliseconds: 800));
          } else if (notification.additionalData!['type'] == "friend_request" && notification.additionalData!['status'] == "accepted") {
            Get.to(() => Friends(), transition: Transition.leftToRight, duration: const Duration(milliseconds: 800));
          } else if (notification.additionalData!['status'] == "want_to_join_chat") {
            controller.onPressGroubChat(
                chatModel: UserChatModel.fromJson(notification.additionalData!['conversation']),
                isGust: false,
                id: notification.additionalData!['conversation']['id']
            );
          }
        },
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // 🌟 صورة الإشعار
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pref! ? AppColors.black2TextColor : Colors.grey.shade200,
                image: notification.additionalData!['image'] != null
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: notification.additionalData!['image'] == null
                  ? Icon(LucideIcons.bellRing, color: AppColors.secondaryColor, size: 6.w)
                  : null,
            ),
            SizedBox(width: 3.w),

            // 🌟 نصوص الإشعار
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textNormal(
                    title,
                    pref! ? AppColors.whiteColor : AppColors.blackColor,
                    3.8.w,
                    FontWeight.bold,
                  ),
                  SizedBox(height: 0.5.h),
                  textNormal(
                    multi: true,
                    numOfRow: 2,
                    body,
                    pref! ? AppColors.inActiveColor : AppColors.black2TextColor,
                    3.3.w,
                    FontWeight.w500,
                  ),
                  SizedBox(height: 1.h),
                  textNormal(
                    langAr
                        ? notifyController.formatToReadableDateTimeArabic(notification.date!)
                        : notifyController.formatToReadableDateTime(notification.date!),
                    pref! ? AppColors.secondaryColor : AppColors.primaryColor, // 🌟 لون الوقت ميزناه شوية
                    3.w,
                    FontWeight.w500,
                  ),
                ],
              ),
            ),

            // 🌟 سهم أخر الكارت
            Icon(
              isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
              color: pref! ? AppColors.inActiveColor : Colors.grey.shade400,
              size: 5.w,
            )
          ],
        ),
      ),
    );
  }

  // 🌟 شكل لو مفيش إشعارات
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bellOff,
            size: 20.w,
            color: pref! ? AppColors.inActiveColor : AppColors.black2TextColor,
          ),
          SizedBox(height: 3.h),
          textNormal(
            S.of(context).noNotifications,
            pref! ? AppColors.whiteColor : AppColors.blackTextColor,
            4.5.w,
            FontWeight.bold,
          ),
          SizedBox(height: 1.5.h),
          textNormal(
            center: true,
            S.of(context).noNotificationsDescription,
            pref! ? AppColors.inActiveColor : AppColors.black2TextColor,
            3.5.w,
            FontWeight.w400,
          ),
        ],
      ),
    );
  }
}