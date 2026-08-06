// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:live_chat/Controller/bottm_sheet__controller.dart';
import 'package:live_chat/Controller/market_controller.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Screens/Market%20Bottom%20Sheet/market_buy_charge_bottom_sheet.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_success_payment.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/createchat/button.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'dart:convert';

void showBottomSheetMarketMoreWidget({
  required BuildContext context,
  required String name,
  required String price,
  required Widget afterParhes,
  required bool isBuy,
  required int powerId,
}) {
  Get.put(BottomSheetController());
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final MarketController marketController = Get.put(MarketController());

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (context) => GetBuilder<BottomSheetController>(
      builder: (c) => AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: c.sheetMarket == "secondPage"
              ? 20.h
              : 40.h, // Adjusted height for additional content
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                right: 4.w,
                left: 4.w,
                top: 4.w,
              ),
              width: 100.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 4,
                    width: 70,
                    color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                  Row(
                    mainAxisAlignment:
                        isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      textClick(
                        c.sheetMarket != "firstPage"
                            ? S.of(context).back
                            : S.of(context).close,
                        true,
                        () {
                          c.sheetMarket == "secondPage"
                              ? c.updateMarketSheet("firstPage")
                              : Get.back();
                          c.rotateCardtoMain();
                          log(c.sheetMarket);
                        },
                        pref! ? AppColors.whiteColor : AppColors.blackColor,
                        3.5.w,
                      ),
                    ],
                  ),
                  if (c.sheetMarket == "secondPage")
                    textNormal(
                      S.of(context).confirmPurchase,
                      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                      4.w,
                      FontWeight.w600,
                    ),
                  if (c.sheetMarket == "secondPage") SizedBox(height: 2.h),
                  if (c.sheetMarket == "firstPage")
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
                        const SizedBox(width: 5),
                        textNormal(
                          name,
                          pref!
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          3.5.w,
                          FontWeight.w500,
                        ),
                      ],
                    ),
                  if (c.sheetMarket == "firstPage") SizedBox(height: 2.h),
                  if (c.sheetMarket == "firstPage")
                    Row(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Icon(
                          LucideIcons.circlePoundSterling300,
                          color: pref!
                              ? AppColors.secondaryColor
                              : AppColors.blackColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        textNormal(
                          "${S.of(context).price} : $price",
                          pref!
                              ? AppColors.inActiveColor
                              : AppColors.blackTextColor,
                          3.5.w,
                          FontWeight.w400,
                        ),
                      ],
                    ),
                  if (c.sheetMarket == "firstPage") SizedBox(height: 2.h),
                  if (c.sheetMarket == "firstPage")
                    Row(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          color: pref!
                              ? AppColors.secondaryColor
                              : AppColors.blackColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        textNormal(
                          "${S.of(context).reminingTime} : 30 ${S.of(context).days}",
                          pref!
                              ? AppColors.inActiveColor
                              : AppColors.blackTextColor,
                          3.5.w,
                          FontWeight.w400,
                        ),
                      ],
                    ),
                  if (c.sheetMarket == "firstPage") SizedBox(height: 2.h),
                  if (c.sheetMarket == "firstPage")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Icon(
                          isRtl
                              ? LucideIcons.moveLeft300
                              : LucideIcons.moveRight300,
                          color: pref!
                              ? AppColors.secondaryColor
                              : AppColors.blackColor,
                          size: 5.w,
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 50.w,
                          child: afterParhes,
                        ),
                      ],
                    ),
                  if (c.sheetMarket == "firstPage") SizedBox(height: 3.h),
                  if (c.sheetMarket == "firstPage")
                    Button(
                      ontap: () {
                        final double requiredStars =
                            double.parse(price.split(' ').first);
                        final int requiredStarsInt = requiredStars.toInt();
                        marketController.fetchUserProfile();
                        log(marketController.numOfStars.value.toString());
                        if (marketController.numOfStars >= requiredStarsInt) {
                          c.updateMarketSheet("secondPage");
                        } else {
                          Get.snackbar(
                            S.of(context).insufficientStars,
                            S.of(context).pleasePurchaseMoreStars,
                            backgroundColor: AppColors.redColor,
                            colorText: AppColors.whiteColor,
                            snackPosition: SnackPosition.BOTTOM,
                            onTap: (_) {
                              showBottomSheetMarketBuyChargeWidget(
                                  context: context);
                            },
                          );
                        }
                      },
                      text: S.of(context).purchase,
                    ),
                  if (c.sheetMarket == "secondPage")
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Button(
                        text:
                            isBuy ? S.of(context).isBuy : S.of(context).confirm,
                        ontap: () async {
                          if (isBuy) {
                          } else {
                            try {
                              final response = await http.post(
                                Uri.parse(
                                  '${AppApi.stores}/$powerId/buy_power',
                                ),
                                headers: {
                                  'Accept': 'application/json',
                                  'Lang':
                                      sharedPreferences!.getString("local") ==
                                              "en"
                                          ? "en"
                                          : "ar",
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                  'Authorization':
                                      'Bearer ${sharedPreferences!.getString("token")}',
                                },
                                body: jsonEncode({
                                  'power_id': powerId,
                                  'store_id': 9,
                                }),
                              );

                              final responseData = jsonDecode(response.body);
                              if (response.statusCode == 200 &&
                                  responseData['status'] == 'success') {
                                final double requiredStars =
                                    double.parse(price.split(' ').first);
                                final int requiredStarsInt =
                                    requiredStars.toInt();
                                marketController.numOfStars -= requiredStarsInt;
                                Get.back();
                                messageSuccessPayment(context);
                                c.sheetMarket = "firstPage";
                                marketController.refreshData();

                                c.rotateCardtoMain();
                              } else {
                                Get.snackbar(
                                  S.of(context).error,
                                  responseData['message'] ??
                                      S.of(context).purchaseFailed,
                                  backgroundColor: AppColors.redColor,
                                  colorText: AppColors.whiteColor,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            } catch (e) {
                              Get.snackbar(
                                S.of(context).error,
                                S.of(context).purchaseFailed,
                                backgroundColor: AppColors.redColor,
                                colorText: AppColors.whiteColor,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              log('Purchase error: $e');
                            }
                          }
                        },
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
