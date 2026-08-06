import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_chat/generated/l10n.dart';

class NotificationController extends GetxController {
  var isNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    isNotificationEnabled.value = prefs.getBool('notificationsEnabled') ?? true;
  }

  void toggleNotification(bool value) async {
    isNotificationEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
  }
}

class NotificationView extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: isRtl ? 4.w : 4.w, vertical: 2.h),
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment:
                    isRtl ? MainAxisAlignment.start : MainAxisAlignment.start,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                    S.of(context).notifications,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    4.5.w,
                    FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Obx(() => textNormal(
                    controller.isNotificationEnabled.value
                        ? S.of(context).notificationsEnabled
                        : S.of(context).notificationsDisabled,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                  )),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Row(
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Icon(
                        LucideIcons.bell300,
                        size: 5.5.w,
                        color:
                            pref! ? AppColors.whiteColor : AppColors.blackColor,
                      ),
                      SizedBox(width: 2.w),
                      textNormal(
                        S.of(context).notifications,
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                        4.w,
                        FontWeight.w400,
                      ),
                    ],
                  ),
                  Obx(() => Switch(
                        value: controller.isNotificationEnabled.value,
                        onChanged: controller.toggleNotification,
                        // ignore: deprecated_member_use
                        activeColor: pref!
                            ? AppColors.secondaryColor
                            : AppColors.buttoncolor,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
