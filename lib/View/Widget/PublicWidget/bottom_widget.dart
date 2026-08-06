import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

Widget buttonWidget(
    {colorBorder, colorFill, colorText, width, text, onPress, size}) {
  return InkWell(
    splashColor: AppColors.whiteColor,
    splashFactory: NoSplash.splashFactory,
    onTap: onPress,
    child: Container(
      height: 6.h,
      alignment: Alignment.center,
      width: width,
      decoration: BoxDecoration(
          color: colorFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBorder)),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSansArabic(
            color: colorText, fontSize: size, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
