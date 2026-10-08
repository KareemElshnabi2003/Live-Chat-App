import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class ChatHelpers {
  // 🌟 استخراج الخلفية
  static DecorationImage? getBackgroundImage(UserChatModel model) {
    if (model.userTheme != null && model.userTheme.toString().trim() != "null" && model.userTheme.toString().trim().isNotEmpty) {
      return DecorationImage(image: CachedNetworkImageProvider("${model.userTheme}"), fit: BoxFit.cover);
    } else if (model.themeId != null && model.themeId?.theme != null && model.themeId!.theme.toString().trim() != "null" && model.themeId!.theme.toString().trim().isNotEmpty) {
      return DecorationImage(image: CachedNetworkImageProvider("${model.themeId?.theme}"), fit: BoxFit.cover);
    }
    return null;
  }

  // 🌟 فحص الإعلان
  static bool hasAd(UserChatModel model) {
    bool hasValidImage = model.adImage != null && model.adImage!.trim().isNotEmpty && model.adImage != "null" && model.adImage != "image";
    return (model.adTitle != null && model.adTitle!.trim().isNotEmpty && model.adTitle != "null") ||
        (model.adLink != null && model.adLink!.trim().isNotEmpty && model.adLink != "null") ||
        hasValidImage;
  }

  // 🌟 شريط الموسيقى
  static Widget buildMusicBar(ChatController controller, bool isRtl, BuildContext context) {
    if (!controller.isRadioPlaying) return const SizedBox.shrink();

    String title = (controller.currentRadioIndex != null && controller.currentRadioIndex! < controller.radios.length)
        ? "الآن يتم تشغيل: ${controller.radios[controller.currentRadioIndex!].name}"
        : S.of(context).nowPlaying('الراديو');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          GestureDetector(
            onTap: () {
              if (controller.isRadioPlaying) controller.stopRadio();
            },
            child: Icon(IconsaxPlusLinear.close_circle, size: 5.w, color: pref! ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(title, style: TextStyle(color: pref! ? Colors.white : AppColors.blackTextColor, fontSize: 3.5.w, fontWeight: FontWeight.w600), textAlign: isRtl ? TextAlign.right : TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 3.w),
          Icon(controller.isRadioPlaying ? Icons.radio : IconsaxPlusLinear.music, size: 5.w, color: pref! ? Colors.white : AppColors.blackTextColor),
        ],
      ),
    );
  }

  // 🌟 الـ Reactions Bottom Sheet
  static void showReactionBottomSheet(BuildContext context, int messageIndex, ChatController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12.w, height: 0.5.h, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 2.h),
            Text(S.of(context).react, style: TextStyle(color: pref! ? AppColors.whiteColor : AppColors.blackTextColor, fontSize: 4.w, fontWeight: FontWeight.w600)),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['❤️', '😂', '😢', '😮', '😡', '👍'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    controller.addReactionToMessage(messageIndex, emoji, controller.messages[messageIndex].messageId);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 12.w, height: 12.w,
                    decoration: BoxDecoration(color: pref! ? AppColors.blackColor.withOpacity(0.3) : Colors.grey[200], borderRadius: BorderRadius.circular(30)),
                    child: Center(child: Text(emoji, style: TextStyle(fontSize: 6.w))),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}