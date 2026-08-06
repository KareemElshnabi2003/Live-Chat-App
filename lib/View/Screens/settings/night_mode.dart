import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/langauge_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/settings/language_button.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class NightModeView extends StatelessWidget {
  NightModeView({super.key});
  final AppSettingsController controller = Get.put(AppSettingsController());

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GetBuilder<AppSettingsController>(
        builder: (controller) => PopScope(
              canPop: false,
              // ignore: deprecated_member_use
              onPopInvoked: (didPop) => Get.off(
                () => const HomeView(),
                transition: Transition.leftToRight,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
              ),
              child: Scaffold(
                backgroundColor: sharedPreferences!.getBool("isDarkMode")!
                    ? AppColors.blackColor
                    : AppColors.bgColor,
                body: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isRtl ? 4.w : 4.w, vertical: 2.h),
                  child: Directionality(
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: isRtl
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.start,
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.off(
                                  () => const HomeView(),
                                  transition: Transition.leftToRight,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOut,
                                );
                              },
                              child: Icon(
                                isRtl
                                    ? IconsaxPlusLinear.arrow_right_3
                                    : IconsaxPlusLinear.arrow_left_1,
                                size: 5.5.w,
                                color: pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            textNormal(
                              S.of(context).nightMode,
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              4.5.w,
                              FontWeight.w500,
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        textNormal(
                          controller.isDarkMode.value
                              ? S.of(context).darkModeEnabled
                              : S.of(context).lightMode,
                          pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          3.5.w,
                          FontWeight.w400,
                        ),
                        SizedBox(height: 3.h),
                        LanguageButton(
                          language: S.of(context).lightMode,
                          isSelected: !controller.isDarkMode.value,
                          onTap: () => controller.toggleTheme(false),
                        ),
                        LanguageButton(
                          language: S.of(context).darkMode,
                          isSelected: controller.isDarkMode.value,
                          onTap: () => controller.toggleTheme(true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
