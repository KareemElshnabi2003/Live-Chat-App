import 'package:flutter/material.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class LanguageButton extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageButton({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 6.h,
        margin: EdgeInsets.only(bottom: 1.5.h),
        decoration: ShapeDecoration(
          color: isSelected
              ? pref!
                  ? AppColors.secondaryColor
                  : AppColors.primaryColor
              : pref!
                  ? AppColors.darkcolor
                  : AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            side: isSelected
                ? BorderSide.none
                : const BorderSide(width: 0.50, color: AppColors.inActiveColor),
            borderRadius: BorderRadius.circular(isSelected ? 30 : 10),
          ),
        ),
        child: Center(
          child: textNormal(
            language,
            isSelected
                ? pref!
                    ? AppColors.blackTextColor
                    : AppColors.whiteColor
                : pref!
                    ? AppColors.inActiveColor
                    : AppColors.blackTextColor,
            3.5.w,
            FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
