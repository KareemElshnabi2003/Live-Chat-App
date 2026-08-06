import 'package:flutter/material.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

messageSuccessSendStars(context) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  showDialog(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(
          right: isRtl ? 5.w : 7.w,
          left: isRtl ? 7.w : 5.w,
          top: 35.h,
          bottom: 35.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: pref! ? AppColors.darkcolor : AppColors.whiteColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.successPaymentImg,
            fit: BoxFit.fill,
            height: 17.w,
            width: 18.w,
            color: pref! ? AppColors.secondaryColor : null,
          ),
          SizedBox(height: 2.h),
          textNormal(
              S.of(context).sentSuccessfully,
              pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              4.w,
              FontWeight.w600),
          SizedBox(height: 2.h),
          SizedBox(
            width: 70.w,
            child: textNormal(
                center: true,
                S.of(context).starsSentSuccessfully,
                pref! ? AppColors.inActiveColor : AppColors.black2TextColor,
                3.5.w,
                FontWeight.w400),
          ),
        ],
      ),
    ),
  );
}
