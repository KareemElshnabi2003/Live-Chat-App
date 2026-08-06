import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

Widget otpWidget(verifyCode, Function(String)? onSubmit) {
  return Center(
    child: SizedBox(
      height: 12.h,
      width: 100.w,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OtpTextField(
          focusedBorderColor: pref! ? AppColors.bgColor : AppColors.blackColor,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          textStyle: GoogleFonts.ibmPlexSansArabic(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: pref! ? AppColors.whiteColor : AppColors.primaryColor),
          fieldWidth: 12.w,
          fieldHeight: 7.h,
          borderColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          borderWidth: 2,
          numberOfFields: 6,
          margin: EdgeInsets.only(right: 1.w, left: 1.w),
          fillColor: pref! ? AppColors.darkcolor : Colors.white,
          filled: true,

          borderRadius: BorderRadius.circular(20),
          showFieldAsBox: true,
          disabledBorderColor:
              pref! ? AppColors.darkcolor : AppColors.whiteColor,
          enabledBorderColor:
              pref! ? AppColors.darkcolor : AppColors.whiteColor,

          onSubmit: onSubmit, // end onSubmit
        ),
      ),
    ),
  );
}
