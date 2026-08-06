import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

Widget textFieldWidget(controller, hintText, iconic, obscure,
    String? Function(String?)? validator, keyBoard, onPress, icon,
    {lines = false, onTap, required TextDirection textDirection}) {
  return InkWell(
    onTap: onTap,
    child: TextFormField(
      controller: controller,
      keyboardType: keyBoard,
      obscureText: obscure,
      validator: validator,
      maxLines: lines ? 11 : 1,
      maxLength: lines ? 500 : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.ibmPlexSansArabic(
          color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          fontSize: 3.5.w,
          fontWeight: FontWeight.w400),
      decoration: InputDecoration(
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  size: 6.w,
                  color: AppColors.primaryColor,
                ),
          suffixIcon: iconic == true
              ? InkWell(
                  onTap: onPress,
                  child: Icon(
                    obscure == true
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.primaryColor,
                    size: 6.w,
                  ),
                )
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide.none),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.all(4.w),
          errorStyle: GoogleFonts.ibmPlexSansArabic(
              color: AppColors.redColor,
              fontSize: 3.5.w,
              fontWeight: FontWeight.w500),
          hintStyle: GoogleFonts.ibmPlexSansArabic(
              color: AppColors.inActiveColor,
              fontSize: 3.5.w,
              fontWeight: FontWeight.w500),
          hintText: hintText,
          filled: true,
          fillColor: pref! ? AppColors.darkcolor : AppColors.whiteColor),
    ),
  );
}
