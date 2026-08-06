import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/bottom_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

messageError(title, body) {
  Get.defaultDialog(
    backgroundColor: AppColors.whiteColor,
    title: title,
    titlePadding: EdgeInsets.all(2.w),
    titleStyle: GoogleFonts.poppins(
        color: AppColors.primaryColor,
        fontSize: 6.w,
        fontWeight: FontWeight.w500),
    content: Column(
      children: [
        SizedBox(
          width: 80.w,
          child: textNormal(
              body, center: true, AppColors.blackColor, 3.5.w, FontWeight.w400),
        ),
        SizedBox(
          height: 4.w,
        ),
        buttonWidget(
            colorBorder: AppColors.primaryColor,
            colorFill: AppColors.primaryColor,
            colorText: AppColors.whiteColor,
            width: 60.w,
            text: "cancel",
            onPress: () {
              Get.appUpdate();
              Get.back();
            },
            size: 3.w),
        SizedBox(
          height: 2.w,
        ),
      ],
    ),
  );
}

messageErrorVerify(title, body, onPress) {
  Get.defaultDialog(
    backgroundColor: AppColors.whiteColor,
    title: title,
    titlePadding: EdgeInsets.all(2.w),
    titleStyle: GoogleFonts.poppins(
        color: AppColors.primaryColor,
        fontSize: 6.w,
        fontWeight: FontWeight.w500),
    content: Column(
      children: [
        SizedBox(
          width: 80.w,
          child: textNormal(
              body, center: true, AppColors.blackColor, 3.5.w, FontWeight.w400),
        ),
        SizedBox(
          height: 4.w,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttonWidget(
                colorBorder: AppColors.primaryColor,
                colorFill: AppColors.whiteColor,
                colorText: AppColors.primaryColor,
                width: 25.w,
                text: S.of(Get.context!).cancel,
                onPress: () {
                  Get.back();
                },
                size: 3.w),
            const SizedBox(
              width: 20,
            ),
            buttonWidget(
                colorBorder: AppColors.primaryColor,
                colorFill: AppColors.primaryColor,
                colorText: AppColors.whiteColor,
                width: 25.w,
                text: S.of(Get.context!).verify,
                onPress: onPress,
                size: 3.w),
          ],
        ),
        SizedBox(
          height: 2.w,
        ),
      ],
    ),
  );
}

messageErrorWithButton(title, body, onPress, btnTitle) {
  Get.defaultDialog(
    backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
    title: title,
    titlePadding: EdgeInsets.all(2.w),
    titleStyle: GoogleFonts.poppins(
        color: pref! ? AppColors.whiteColor : AppColors.primaryColor,
        fontSize: 6.w,
        fontWeight: FontWeight.w500),
    content: Column(
      children: [
        SizedBox(
          width: 80.w,
          child: textNormal(
              body,
              center: true,
              pref! ? AppColors.whiteColor : AppColors.blackColor,
              3.5.w,
              FontWeight.w400),
        ),
        SizedBox(
          height: 4.w,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttonWidget(
                colorBorder:
                    pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                colorFill:
                    pref! ? AppColors.secondaryColor : AppColors.whiteColor,
                colorText:
                    pref! ? AppColors.blackColor : AppColors.primaryColor,
                width: 25.w,
                text: btnTitle,
                onPress: onPress,
                size: 3.w),
            const SizedBox(
              width: 20,
            ),
            buttonWidget(
                colorBorder:
                    pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                colorFill: pref! ? AppColors.darkcolor : AppColors.primaryColor,
                colorText:
                    pref! ? AppColors.secondaryColor : AppColors.whiteColor,
                width: 25.w,
                text: S.of(Get.context!).cancel,
                onPress: () {
                  Get.back();
                },
                size: 3.w),
          ],
        ),
        SizedBox(
          height: 2.w,
        ),
      ],
    ),
  );
}
