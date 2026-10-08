import 'package:flutter/material.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

void showReactionMessageBottomSheet(
    BuildContext context, ChatMessage chatMessage) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            S.of(context).react,
            style: TextStyle(
              color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              fontSize: 4.w,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: 100.w,
            child: ListView.separated(
              itemCount: chatMessage.reaction.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(2.w),
              itemBuilder: (context, index) => Row(
                children: [
                  Text(chatMessage.reaction[index].react!,
                      style: TextStyle(fontSize: 6.w)),
                  const SizedBox(width: 10),
                  textNormal(
                    chatMessage.reaction[index].user!.username ==
                        sharedPreferences!.getString("usernameGust") ||
                        chatMessage.reaction[index].user!.username ==
                            sharedPreferences!.getString("username")
                        ? S.of(context).you
                        : chatMessage.reaction[index].user!.username,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    ),
  );
}