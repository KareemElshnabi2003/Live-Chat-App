// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/bottm_sheet__controller.dart';
import 'package:live_chat/Controller/capabilities_controller.dart';
import 'package:live_chat/Controller/market_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

showBottomSheetmore({
  required BuildContext context,
  required String name,
  required String price,
  required String active,
  required String powerId,
  required Widget afterParhes,
  String? daysRemaining,
}) {
  Get.put(BottomSheetController());
  // Fix: Put MarketController if it doesn't exist, otherwise find existing one
  MarketController marketController;
  if (Get.isRegistered<MarketController>()) {
    marketController = Get.find<MarketController>();
  } else {
    marketController = Get.put(MarketController());
  }
  CapabilitiesController capabilityController;
  if (Get.isRegistered<CapabilitiesController>()) {
    capabilityController = Get.find<CapabilitiesController>();
  } else {
    capabilityController = Get.put(CapabilitiesController());
  }
  marketController.closeEnergy.value = active == "Active" ? false : true;
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  return showModalBottomSheet(
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: pref! ? AppColors.darkcolor : AppColors.bgColor,
    context: context,
    builder: (context) => GetBuilder<BottomSheetController>(
      builder: (c) => PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          capabilityController.fetchUserPowers();
        },
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: isRtl ? 2.w : 4.w,
            right: isRtl ? 4.w : 2.w,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              minHeight: MediaQuery.of(context).size.height * 0.2,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 70,
                    color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isRtl ? 2.w : 4.w,
                      vertical: 2.w,
                    ),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Align(
                          alignment: isRtl
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: textClick(
                            S.of(context).close,
                            true,
                            () {
                              capabilityController.fetchUserPowers();

                              Get.back();
                            },
                            pref! ? AppColors.whiteColor : AppColors.blackColor,
                            3.5.w,
                          ),
                        ),
                        SizedBox(height: 2.w),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              children: [
                                textNormal(
                                  S.of(context).name,
                                  AppColors.inActiveColor,
                                  3.5.w,
                                  FontWeight.w500,
                                ),
                                Flexible(
                                  child: textNormal(
                                    name,
                                    pref!
                                        ? AppColors.whiteColor
                                        : AppColors.inActiveColor,
                                    3.5.w,
                                    FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.w),
                            Row(
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              children: [
                                Icon(
                                  isRtl
                                      ? LucideIcons.circlePoundSterling
                                      : LucideIcons.circleDollarSign,
                                  color: pref!
                                      ? AppColors.secondaryColor
                                      : AppColors.blackColor,
                                  size: 4.w,
                                ),
                                SizedBox(width: isRtl ? 1.5.w : 2.w),
                                Flexible(
                                  child: textNormal(
                                    "${S.of(context).price} $price",
                                    pref!
                                        ? AppColors.whiteColor
                                        : AppColors.blackTextColor,
                                    3.5.w,
                                    FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.w),
                            Row(
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              children: [
                                Icon(
                                  isRtl
                                      ? LucideIcons.moveLeft
                                      : LucideIcons.moveRight,
                                  color: pref!
                                      ? AppColors.secondaryColor
                                      : AppColors.blackColor,
                                  size: 4.w,
                                ),
                                SizedBox(width: isRtl ? 1.5.w : 2.w),
                                textNormal(
                                  daysRemaining ?? "",
                                  pref!
                                      ? AppColors.whiteColor
                                      : AppColors.blackTextColor,
                                  3.5.w,
                                  FontWeight.w400,
                                ),
                              ],
                            ),
                            SizedBox(height: 5.w),
                            SizedBox(height: 5.w),
                            SizedBox(
                              width: 100.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    LucideIcons.arrowBigLeft200,
                                    color: AppColors.blackColor,
                                    size: 6.w,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  SizedBox(width: 70.w, child: afterParhes),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              children: [
                                textNormal(
                                  S.of(context).closeEnergy,
                                  pref!
                                      ? AppColors.whiteColor
                                      : AppColors.inActiveColor,
                                  3.5.w,
                                  FontWeight.w500,
                                ),
                                Obx(() => Switch(
                                      value: marketController.closeEnergy.value,
                                      onChanged: (value) {
                                        marketController.closePower(
                                            status: value ? 0 : 1,
                                            powerId: powerId);
                                        marketController.closeEnergy.value =
                                            value;
                                      },
                                      activeColor: pref!
                                          ? AppColors.secondaryColor
                                          : AppColors.primaryColor,
                                      activeTrackColor: pref!
                                          ? AppColors.secondaryColor
                                              .withOpacity(.5)
                                          : AppColors.primaryColor
                                              .withOpacity(0.5),
                                    )),
                              ],
                            ),
                            SizedBox(height: 4.w),
                          ],
                        ),
                        SizedBox(height: 2.w),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
