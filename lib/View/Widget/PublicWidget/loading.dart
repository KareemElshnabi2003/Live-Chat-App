import 'package:flutter/material.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

Widget loading(height) {
  return SizedBox(
    height: height,
    width: 100.w,
    child:const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
      ),
    ),
  );
}
