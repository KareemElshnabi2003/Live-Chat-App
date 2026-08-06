import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

dialogImgWidget(
    {required UserChatModel? userChatModel,
    required String title,
    required img,
    required onPressChat}) {
  Get.defaultDialog(
      backgroundColor: null,
      actions: [
        InkWell(
          onTap: onPressChat,
          child: Icon(
            LucideIcons.phone,
            size: 6.w,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        InkWell(
          onTap: onPressChat,
          child: Icon(
            LucideIcons.video,
            size: 6.w,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        InkWell(
          onTap: onPressChat,
          child: Icon(
            LucideIcons.messageCircle300,
            size: 6.w,
            color: AppColors.primaryColor,
          ),
        ),
      ],
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.only(bottom: 10),
      content: SizedBox(
        width: 70.w,
        height: 30.h,
        child: userChatModel != null
            ? userChatModel.image == "image" ||
                    userChatModel.image.toString() == "null"
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pref!
                          ? AppColors.darkcolor
                          : AppColors.black2TextColor,
                    ),
                    child: textNormal(
                        title[0],
                        pref! ? AppColors.blackTextColor : AppColors.whiteColor,
                        14.w,
                        FontWeight.bold),
                  )
                : CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: userChatModel.image!)
            : img == null
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pref!
                          ? AppColors.darkcolor
                          : AppColors.black2TextColor,
                    ),
                    child: textNormal(
                        title[0],
                        pref! ? AppColors.blackTextColor : AppColors.whiteColor,
                        14.w,
                        FontWeight.bold),
                  )
                : CachedNetworkImage(
                    fit: BoxFit.cover, imageUrl: "$img"),
      ));
}
