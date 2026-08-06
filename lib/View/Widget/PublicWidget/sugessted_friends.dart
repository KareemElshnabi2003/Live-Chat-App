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
import 'package:live_chat/generated/l10n.dart';

// ignore: non_constant_identifier_names
Widget SuggestedFriends({
  required ImageProvider img,
  required PowerModel? power,
  required String ttitle,
  required bool imgUrl,
  required String body,
  required VoidCallback sendRequest,
  required VoidCallback removeRequest,
  required VoidCallback chat,
  required VoidCallback onPressImg,
  required bool requestSend,
}) {
  final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

  return SizedBox(
    height: 10.h,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Row(
          children: [
            imgUrl
                ? InkWell(
                    onTap: onPressImg,
                    child: Container(
                      width: 19.w,
                      height: 19.w,
                      decoration: BoxDecoration(
                        color: pref! ? AppColors.darkcolor : null,
                        image: DecorationImage(
                          image: img,
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(80),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: onPressImg,
                    child: Container(
                      alignment: Alignment.center,
                      width: 19.w,
                      height: 19.w,
                      decoration: BoxDecoration(
                        color: pref!
                            ? AppColors.darkcolor
                            : AppColors.black2TextColor,
                        borderRadius: BorderRadius.circular(80),
                      ),
                      child: textNormal(ttitle[0], AppColors.whiteColor, 7.w,
                          FontWeight.bold),
                    ),
                  ),
            SizedBox(width: 3.w),
            InkWell(
              onTap: requestSend ? removeRequest : sendRequest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40.w,
                    // height: 5.h,
                    child: power.toString() == "null"
                        ? textNormal(
                            multi: true,
                            numOfRow: 1,
                            ttitle,
                            pref!
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            3.5.w,
                            FontWeight.w400,
                          )
                        : PowerTextWidget(
                            powerModel: power!,
                            displyText: ttitle,
                          ),
                  ),
                  // const Spacer(flex: 1),
                  const SizedBox(
                    height: 10,
                  ),
                  textNormal(
                    body,
                    requestSend
                        ? AppColors.secondaryColor
                        : pref!
                            ? AppColors.inActiveColor
                            : AppColors.black2TextColor,
                    3.w,
                    FontWeight.w500,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // const Spacer(flex: 2),
                  textClick(
                    requestSend
                        ? S.of(Get.context!).cancel
                        : S.of(Get.context!).send,
                    false,
                    sendRequest,
                    requestSend
                        ? AppColors.redColor
                        : pref!
                            ? AppColors.secondaryColor
                            : AppColors.primaryColor,
                    3.w,
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(
              right: isRtl ? 1.3.w : 5.w, left: isRtl ? 5.w : 1.3.w),
          height: 14.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft:
                  isRtl ? const Radius.circular(0) : const Radius.circular(25),
              bottomLeft:
                  isRtl ? const Radius.circular(0) : const Radius.circular(25),
              topRight:
                  isRtl ? const Radius.circular(25) : const Radius.circular(0),
              bottomRight:
                  isRtl ? const Radius.circular(25) : const Radius.circular(0),
            ),
          ),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              GestureDetector(
                onTap: requestSend ? sendRequest : removeRequest,
                child: Container(
                  height: 12.w,
                  width: 12.w,
                  decoration: ShapeDecoration(
                    color: pref! ? AppColors.blackColor : AppColors.bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      requestSend ? Icons.close : LucideIcons.plus,
                      size: 4.w,
                      color: pref!
                          ? AppColors.secondaryColor
                          : AppColors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: chat,
                child: Container(
                  height: 12.w,
                  width: 12.w,
                  decoration: ShapeDecoration(
                    color: pref! ? AppColors.blackColor : AppColors.bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      LucideIcons.messageCircle300,
                      size: 4.w,
                      color: pref!
                          ? AppColors.secondaryColor
                          : AppColors.blackColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}
