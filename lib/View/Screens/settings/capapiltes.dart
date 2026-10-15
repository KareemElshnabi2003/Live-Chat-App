import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Controller/capabilities_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/View/Screens/Market%20Bottom%20Sheet/more_settings.dart';
import 'package:live_chat/View/Widget/PublicWidget/shimmer_widgets.dart';
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
                      ? const UserListShimmer(itemCount: 4, shrinkWrap: true)
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
                width: 55.w,
                child: textNormal(
                  S.of(context).name,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 15.w,
                child: textNormal(
                  S.of(context).price,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 15.w,
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

  bool _isPowerActive(PowerModel power) {
    final activeStr = power.active?.toString().toLowerCase().trim() ?? "";
    if (activeStr == "active" || activeStr == "1" || activeStr == "true") {
      return true;
    }
    try {
      final powerStr = sharedPreferences?.getString("powermodel");
      if (powerStr != null && powerStr.isNotEmpty && powerStr != "null") {
        final decoded = jsonDecode(powerStr);
        if (decoded is Map<String, dynamic>) {
          final currentId = decoded['id']?.toString();
          final currentPowerId = decoded['power_id']?.toString();
          final pId = power.id?.toString();
          final pPowerId = power.powerId?.toString();
          if (currentId != null && (currentId == pId || currentId == pPowerId)) {
            return true;
          }
          if (currentPowerId != null &&
              (currentPowerId == pPowerId || currentPowerId == pId)) {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  void _onTapPower(
      BuildContext context, PowerModel power, bool expire, String powerName) {
    if (expire) {
      HomeNavigationController homeNavigationController =
          Get.put(HomeNavigationController());
      Get.back();
      homeNavigationController.changePage(2);
    } else {
      showBottomSheetmore(
        active: power.active ?? "",
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
  }

  Widget _buildStoreInformation(
      BuildContext context, CapabilitiesController controller) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final powerName =
        sharedPreferences!.getString("username") ?? "Unknown Power";

    return Column(
      children: controller.powers.map((power) {
        bool isExpired(String expireDate) {
          DateTime expireDateTime = DateTime.parse(expireDate);
          DateTime now = DateTime.now();
          return now.isAfter(expireDateTime);
        }

        String expireAt = power.expireAt ?? "";
        bool expire = expireAt.isNotEmpty && isExpired(expireAt);
        final isActive = _isPowerActive(power);

        return Padding(
          padding: EdgeInsets.only(bottom: 1.5.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onTapPower(context, power, expire, powerName),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isActive
                    ? (pref!
                        ? const Color(0xFF1E3A2F).withOpacity(0.3)
                        : const Color(0xFFE8F5E9).withOpacity(0.8))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isActive
                    ? Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 1.2,
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  SizedBox(
                    width: 55.w,
                    child: Column(
                      crossAxisAlignment: isRtl
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PowerTextWidget(
                          powerModel: power,
                          displyText: powerName,
                        ),
                        if (isActive) ...[
                          SizedBox(height: 0.6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.3.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.7),
                                  width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 3.2.w, color: Colors.green),
                                SizedBox(width: 1.w),
                                textNormal(
                                  S.of(context).Active,
                                  Colors.green,
                                  2.8.w,
                                  FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
                  SizedBox(
                    width: 15.w,
                    child: textNormal(
                      expire ? S.of(context).renewal : S.of(context).more,
                      expire
                          ? AppColors.redColor
                          : (pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor),
                      3.5.w,
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getRemainingTime(String? expireAt, context) {
    if (expireAt == null || expireAt.isEmpty) return "N/A";
    final expireDate = DateTime.parse(expireAt);
    final now = DateTime.now();
    final difference = expireDate.difference(now);
    if (difference.isNegative) return "Expired";
    return "${difference.inDays} ${S.of(context).days}";
  }
}
