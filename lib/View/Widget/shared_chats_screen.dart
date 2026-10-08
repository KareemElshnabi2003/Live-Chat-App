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
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
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
    return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(left: isRtl ? 2.w : 4.w, right: isRtl ? 4.w : 2.w, top: 5.h, bottom: 2.h),
        child: Column(
          children: [
            _buildHeader(context, isRtl),
            SizedBox(height: 4.h),
            Expanded(
              child: GetBuilder<T>(
                builder: (ctrl) => ctrl.statuesRequest == StatuesRequest.loading
                    ? loading(80.h)
                    : ctrl.chatsList.isEmpty
                    ? Center(child: noData(S.of(context).noChat))
                    : RefreshIndicator(
                  // 🌟 التعديل هنا 👇
                  onRefresh: () async {
                    await ctrl.refreshChats();
                  },
                  color: AppColors.secondaryColor,
                  backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
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
            isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          ),
        ),
        SizedBox(width: 2.w),
        textNormal(title, pref! ? AppColors.whiteColor : AppColors.blackTextColor, 4.5.w, FontWeight.w500),
      ],
    );
  }

  Widget _buildChatList(T ctrl, bool isRtl, BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: ctrl.scrollController,
        padding: EdgeInsets.only(right: isRtl ? 0.w : 2.w, left: isRtl ? 2.w : 0.w),
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemCount: ctrl.chatsList.length + (ctrl.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < ctrl.chatsList.length) {
            final chat = ctrl.chatsList[index];
            final hasValidImg = _isValidImage(chat.image); // 🌟 الفحص الآمن

            return chatCardWidget(
              needsAcceptance: chat.accept=="1"?true:false,
              power: null,
              imageUrl: hasValidImg,
              numOfMessage: 0,
              onPressImg: () {
                dialogImgWidget(
                  title: chat.name!,
                  img: null,
                  userChatModel: chat,
                  onPressChat: () => homeController.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
                );
              },
              private: chat.status == "Private",
              // 🌟 منع كراش الصورة هنا
              img: hasValidImg
                  ? CachedNetworkImageProvider(chat.image!.trim())
                  : const AssetImage(AppImages.noChatImg),
              body: formatLastMessage(context, chat),
              ttitle: chat.name!,
              action: S.of(context).joinNow,
              onPressJoin: () => homeController.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
              ontap: () => homeController.onPressGroubChat(chatModel: chat, isGust: true, id: chat.id),
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
        height: 6.w, width: 6.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(pref! ? AppColors.whiteColor : AppColors.blackTextColor),
        ),
      ),
    );
  }
}