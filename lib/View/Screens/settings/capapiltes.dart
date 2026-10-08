import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Controller/capabilities_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Screens/Market%20Bottom%20Sheet/more_settings.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';



class Capabilities extends StatelessWidget {
  const Capabilities({super.key});

  @override
  Widget build(BuildContext context) {
    final CapabilitiesController controller = Get.put(CapabilitiesController());
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
                  SizedBox(width: isRtl ? 1.5.w : 2.w),
                  textNormal(
                    S.of(context).capabilities,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    4.5.w,
                    FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              _buildStore(context),
              SizedBox(height: 3.h),
              Obx(() =>
                  controller.statuesRequest.value == StatuesRequest.loading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.powers.isEmpty
                          ? Center(
                              child: textNormal(
                                S.of(context).noPowersAvailable,
                                pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                                4.w,
                                FontWeight.w500,
                              ),
                            )
                          : _buildStoreInformation(context, controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStore(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 3.w, left: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              SizedBox(
                width: 60.w,
                child: textNormal(
                  S.of(context).name,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 13.w,
                child: textNormal(
                  S.of(context).price,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
                ),
              ),
              // SizedBox(
              //   width: 18.w,
              //   child: textNormal(
              //     S.of(context).reminingTime,
              //     pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              //     3.5.w,
              //     FontWeight.w500,
              //   ),
              // ),
              SizedBox(
                width: 13.w,
                child: textNormal(
                  S.of(context).procedure,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.inActiveColor,
          thickness: 0.2,
        ),
      ],
    );
  }

  Widget _buildStoreInformation(
      BuildContext context, CapabilitiesController controller) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final powerName =
        sharedPreferences!.getString("username") ?? "Unknown Power";
    bool expire = false;

    return Column(
      children: controller.powers.map((power) {
        bool isExpired(String expireDate) {
          DateTime expireDateTime = DateTime.parse(expireDate);
          DateTime now = DateTime.now();

          return now.isAfter(expireDateTime);
        }

        String expireAt = power.expireAt!;
        if (isExpired(expireAt)) {
          expire = true;
        } else {
          expire = false;
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              SizedBox(
                width: 60.w,
                child: PowerTextWidget(
                  powerModel: power,
                  displyText: powerName,
                ),
              ),
              SizedBox(
                width: 15.w,
                child: textNormal(
                  "${power.price} ${S.of(context).points}",
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.w,
                  FontWeight.w500,
                ),
              ),
              // SizedBox(
              //   width: 18.w,
              //   child: textNormal(
              //     _getRemainingTime(power.expireAt, context),
              //     pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              //     3.5.w,
              //     FontWeight.w500,
              //   ),
              // ),
              InkWell(
                onTap: () async {
                  if (expire) {
                    HomeNavigationController homeNavigationController =
                        Get.put(HomeNavigationController());
                    Get.back();
                    homeNavigationController.changePage(2);
                  } else {
                    showBottomSheetmore(
                      active: power.active!,
                      powerId: power.id.toString(),
                      daysRemaining: _getRemainingTime(power.expireAt, context),
                      afterParhes: PowerTextWidget(
                        powerModel: power,
                        displyText: powerName,
                      ),
                      context: context,
                      name: powerName,
                      price: "${power.price} ${S.of(context).points}",
                    );
                  }
                },
                child: SizedBox(
                  width: 13.w,
                  child: textNormal(
                    expire ? S.of(context).renewal : S.of(context).more,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getRemainingTime(String? expireAt, context) {
    if (expireAt == null) return "N/A";
    final expireDate = DateTime.parse(expireAt);
    final now = DateTime.now();
    final difference = expireDate.difference(now);
    if (difference.isNegative) return "Expired";
    return "${difference.inDays} ${S.of(context).days}";
  }
}
