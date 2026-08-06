import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

// ignore: camel_case_types
class row_optin extends StatelessWidget {
  final String name;
  final Icon icon;
  final VoidCallback ontap;
  final TextDirection textDirection;

  const row_optin({
    super.key,
    required this.icon,
    required this.name,
    required this.ontap,
    this.textDirection = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = textDirection == TextDirection.rtl;
    return InkWell(
      onTap: ontap,
      child: SizedBox(
        width: 100.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: textDirection,
          children: [
            Row(
              textDirection: textDirection,
              children: [
                icon,
                SizedBox(width: isRtl ? 1.w : 2.w),
                textNormal(
                  name,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  4.w,
                  FontWeight.w400,
                ),
              ],
            ),
            Icon(
              isRtl
                  ? IconsaxPlusLinear.arrow_left_1
                  : IconsaxPlusLinear.arrow_right_3,
              size: 5.5.w,
              color: pref! ? AppColors.whiteColor : AppColors.blackColor,
            ),
          ],
        ),
      ),
    );
  }
}
