import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/langauge_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/settings/language_button.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class LanguageView extends StatelessWidget {
  LanguageView({super.key});
  final AppSettingsController controller = Get.put(AppSettingsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Make isRtl reactive to language changes
      final isRtl = controller.selectedLanguage.value == 'ar';

      return Scaffold(
        backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
        body: Padding(
          padding:
              EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h, bottom: 2.h),
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        isRtl
                            ? IconsaxPlusLinear.arrow_right_3
                            : IconsaxPlusLinear.arrow_left_1,
                        size: 5.5.w,
                        color:
                            pref! ? AppColors.whiteColor : AppColors.blackColor,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    textNormal(
                      S.of(context).language,
                      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                      4.5.w,
                      FontWeight.w500,
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                textNormal(
                  controller.selectedLanguage.value == 'ar'
                      ? S.of(context).arabic
                      : S.of(context).english,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w400,
                ),
                SizedBox(height: 3.h),
                LanguageButton(
                  language: S.of(context).arabic,
                  isSelected: controller.selectedLanguage.value == 'ar',
                  onTap: () => controller.changeLanguage('ar'),
                ),
                LanguageButton(
                  language: S.of(context).english,
                  isSelected: controller.selectedLanguage.value == 'en',
                  onTap: () => controller.changeLanguage('en'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
