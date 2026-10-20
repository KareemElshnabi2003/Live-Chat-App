import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Controller/base_chats_controller.dart'; // مسار الـ Base
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Widget/PublicWidget/chat_card_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/shimmer_widgets.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/Core/function/format_last_message.dart';

// شاشة ذكية تستقبل أي كونترولر يورث من BaseChatsController
class SharedChatsScreen<T extends BaseChatsController> extends StatelessWidget {
  final String title;

  SharedChatsScreen({super.key, required this.title});

  final homeController = Get.put(HomeNavigationController());

  // 🌟 دالة مساعدة لمنع كراش الصور نهائياً
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
            left: isRtl ? 2.w : 4.w,
            right: isRtl ? 4.w : 2.w,
            top: 5.h,
            bottom: 2.h),
        child: Column(
          children: [
            _buildHeader(context, isRtl),
            SizedBox(height: 4.h),
            Expanded(
              child: GetBuilder<T>(
                builder: (ctrl) => ctrl.statuesRequest == StatuesRequest.loading
                    ? const ChatListShimmer(itemCount: 8)
                    : ctrl.chatsList.isEmpty
                        ? Center(child: noData(S.of(context).noChat))
                        : RefreshIndicator(
                            // 🌟 التعديل هنا 👇
                            onRefresh: () async {
                              await ctrl.refreshChats();
                            },
                            color: AppColors.secondaryColor,
                            backgroundColor: pref!
                                ? AppColors.darkcolor
                                : AppColors.whiteColor,
                            child: _buildChatList(ctrl, isRtl, context),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
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
            title,
            pref! ? AppColors.whiteColor : AppColors.blackTextColor,
            4.5.w,
            FontWeight.w500),
      ],
    );
  }

  Widget _buildChatList(T ctrl, bool isRtl, BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: ctrl.scrollController,
        padding:
            EdgeInsets.only(right: isRtl ? 0.w : 2.w, left: isRtl ? 2.w : 0.w),
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemCount: ctrl.chatsList.length + (ctrl.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < ctrl.chatsList.length) {
            final chat = ctrl.chatsList[index];
            final hasValidImg = _isValidImage(chat.image); // 🌟 الفحص الآمن
            final currentUserId = sharedPreferences?.getString("id")?.trim() ?? "";

            final bool isOwner = (chat.user != null && chat.user!.id.toString() == currentUserId) ||
                (chat.userId != null && chat.userId.toString() == currentUserId) ||
                homeController.myChats.any((myChat) => myChat.id == chat.id &&
                    ((myChat.user != null && myChat.user!.id.toString() == currentUserId) ||
                     (myChat.userId != null && myChat.userId.toString() == currentUserId)));

            final bool isAdmin = (chat.chatAdmins?.any((admin) => admin.chatAdminId?.toString() == currentUserId) ?? false) ||
                homeController.myChats.any((myChat) => myChat.id == chat.id &&
                    (myChat.chatAdmins?.any((admin) => admin.chatAdminId?.toString() == currentUserId) ?? false));

            final bool isJoined = isOwner || isAdmin ||
                (chat.id != null && homeController.joinedChatIds.contains(chat.id)) ||
                homeController.myChats.any((myChat) => myChat.id == chat.id);

            Widget? titleBadge;
            String actionText;
            Color actionColor;

            if (isOwner) {
              actionText = isRtl ? "دخول الغرفة 💬" : "Enter Room 💬";
              actionColor = Colors.amber.shade700;
              titleBadge = Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade700, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.amber.shade700, size: 3.5.w),
                    SizedBox(width: 1.w),
                    Text(
                      isRtl ? "أنت المالك" : "Owner",
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 2.7.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else if (isAdmin) {
              actionText = isRtl ? "دخول الغرفة 💬" : "Enter Room 💬";
              actionColor = Colors.blue.shade700;
              titleBadge = Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade700, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, color: Colors.blue.shade700, size: 3.5.w),
                    SizedBox(width: 1.w),
                    Text(
                      isRtl ? "مشرف" : "Admin",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 2.7.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else if (isJoined) {
              actionText = isRtl ? "دخول الدردشة 💬" : "Open Chat 💬";
              actionColor = const Color(0xFF2E7D32);
              titleBadge = Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF2E7D32), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: const Color(0xFF2E7D32), size: 3.5.w),
                    SizedBox(width: 1.w),
                    Text(
                      isRtl ? "عضو منضم" : "Joined",
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontSize: 2.7.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              actionText = S.of(context).joinNow;
              actionColor = pref! ? AppColors.secondaryColor : AppColors.primaryColor;
              titleBadge = null;
            }

            return chatCardWidget(
              needsAcceptance: chat.accept == "1" ? true : false,
              power: null,
              imageUrl: hasValidImg,
              numOfMessage: 0,
              onPressImg: () {
                dialogImgWidget(
                  title: chat.name!,
                  img: null,
                  userChatModel: chat,
                  onPressChat: () => homeController.onPressGroubChat(
                      chatModel: chat,
                      isGust: sharedPreferences?.getString("id") == null,
                      id: chat.id),
                );
              },
              private: chat.status == "Private",
              // 🌟 منع كراش الصورة هنا
              img: hasValidImg
                  ? CachedNetworkImageProvider(chat.image!.trim(),
                      maxWidth: 150, maxHeight: 150)
                  : const AssetImage(AppImages.noChatImg),
              body: formatLastMessage(context, chat),
              ttitle: chat.name!,
              titleBadge: titleBadge,
              actionColor: actionColor,
              action: actionText,
              onPressJoin: () => homeController.onPressGroubChat(
                  chatModel: chat,
                  isGust: sharedPreferences?.getString("id") == null,
                  id: chat.id),
              ontap: () => homeController.onPressGroubChat(
                  chatModel: chat,
                  isGust: sharedPreferences?.getString("id") == null,
                  id: chat.id),
            );
          } else {
            return _buildLoadingMoreIndicator();
          }
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      alignment: Alignment.center,
      child: SizedBox(
        height: 6.w,
        width: 6.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
              pref! ? AppColors.whiteColor : AppColors.blackTextColor),
        ),
      ),
    );
  }
}
