import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

Widget chatCardWidget({
  required ImageProvider img,
  required PowerModel? power,
  required String ttitle,
  required String body,
  required VoidCallback onPressJoin,
  required VoidCallback onPressImg,
  bool isFriendsSection = false,
  bool isFriend = true,
  required bool private,
  required String action,
  required int numOfMessage,
  required VoidCallback ontap,
  required bool imageUrl,
  bool market = false,
 required bool needsAcceptance,
}) {
  final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

  return SizedBox(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Expanded(
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: onPressImg,
                    child: Container(
                      width: 19.w,
                      height: 19.w,
                      decoration: BoxDecoration(
                        color: imageUrl
                            ? null
                            : (pref!
                            ? AppColors.darkcolor
                            : AppColors.black2TextColor),
                        image: imageUrl
                            ? DecorationImage(
                          image: img,
                          fit: BoxFit.fill,
                        )
                            : null,
                        borderRadius:
                        BorderRadius.circular(isFriendsSection ? 80 : 20),
                      ),
                      alignment: Alignment.center,
                      child: !imageUrl
                          ? textNormal(
                        ttitle[0],
                        AppColors.whiteColor,
                        7.w,
                        FontWeight.bold,
                      )
                          : null,
                    ),
                  ),
                  if (private)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.lock,
                        color: AppColors.primaryColor,
                        size: 6.w,
                      ),
                    ),
                ],
              ),
              SizedBox(width: 3.w),

              Flexible(
                child: InkWell(
                  onTap: onPressJoin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: power != null && isFriendsSection
                                ? PowerTextWidget(
                              powerModel: power,
                              displyText: ttitle,
                            )
                                : textNormal(
                              ttitle,
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              3.5.w,
                              FontWeight.w400,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (needsAcceptance) ...[
                            SizedBox(width: 1.5.w),
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 4.w,
                              color: AppColors.inActiveColor,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: textNormal(
                          body,
                          isFriendsSection
                              ? isFriend
                              ? AppColors.primaryColor
                              : AppColors.secondaryColor
                              : pref!
                              ? AppColors.inActiveColor
                              : AppColors.inActiveColor,
                          3.w,
                          FontWeight.w500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      textClick(
                        action,
                        false,
                        onPressJoin,
                        !isFriend
                            ? AppColors.redColor
                            : pref!
                            ? AppColors.secondaryColor
                            : AppColors.primaryColor,
                        3.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          height: 19.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pref! ? AppColors.blackColor : AppColors.bgColor,
            borderRadius: BorderRadius.only(
              topLeft:
              isRtl ? const Radius.circular(0) : const Radius.circular(20),
              bottomLeft:
              isRtl ? const Radius.circular(0) : const Radius.circular(20),
              topRight:
              isRtl ? const Radius.circular(20) : const Radius.circular(0),
              bottomRight:
              isRtl ? const Radius.circular(20) : const Radius.circular(0),
            ),
          ),
          child: GestureDetector(
            onTap: ontap,
            child: Icon(
              isFriend
                  ? (market
                  ? LucideIcons.moveUp300
                  : (isRtl
                  ? LucideIcons.moveLeft300
                  : LucideIcons.moveRight300))
                  : Icons.close,
              color: pref! ? AppColors.whiteColor : AppColors.blackColor,
              size: 5.w,
            ),
          ),
        ),
      ],
    ),
  );
}