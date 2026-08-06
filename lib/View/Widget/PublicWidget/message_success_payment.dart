import 'package:flutter/material.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

Future<void> messageSuccessPayment(BuildContext context) async {
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) {
      // Auto close after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close dialog

     

        }
      });

      return Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(
            right: isRtl ? 10.w : 10.w,
            left: isRtl ? 10.w : 10.w,
            top: 37.h,
            bottom: 37.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: pref! ? AppColors.darkcolor : AppColors.whiteColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              color: pref! ? AppColors.secondaryColor : null,
              AppImages.successPaymentImg,
              fit: BoxFit.fill,
              height: 16.w,
              width: 18.w,
            ),
            SizedBox(height: 2.h),
            textNormal(
                S.of(context).paymentSuccessful,
                pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                4.w,
                FontWeight.w600),
          ],
        ),
      );
    },
  );
}
