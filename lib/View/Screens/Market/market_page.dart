import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/market_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/View/Screens/Home/show_bottom_sheet_pin_chat_widget.dart';
import 'package:live_chat/View/Screens/Market%20Bottom%20Sheet/market_buy_charge_bottom_sheet.dart';
import 'package:live_chat/View/Screens/Market%20Bottom%20Sheet/market_see_more_bottom_sheet.dart';
import 'package:live_chat/View/Screens/notifications/notifications.dart';
import 'package:live_chat/View/Widget/PublicWidget/chat_card_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final ScrollController _scrollController = ScrollController();
  late MarketController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MarketController());
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user scrolls near the bottom
      controller.loadMorePowers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
        },
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage.value.isNotEmpty
                  ? _buildErrorState(context, controller, isRtl)
                  : SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Obx(() => _headerPage(
                                numOfStars: controller.numOfStars.value,
                                onPress: () {
                                  showBottomSheetPinChatWidget(
                                      context: context);
                                },
                                onTapCharge: () {
                                  showBottomSheetMarketBuyChargeWidget(
                                      context: context);
                                },
                                isRtl: isRtl,
                              )),
                          SizedBox(height: 5.h),
                          _buildStore(isRtl),
                          _buildStoreInformation(controller.storePowers, isRtl),

                          // Loading indicator for pagination
                          Obx(() => controller.isLoadingMore.value
                              ? Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: const CircularProgressIndicator(),
                                )
                              : !controller.hasMoreData.value &&
                                      controller.storePowers.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: textNormal(
                                        isRtl
                                            ? "لا يوجد المزيد"
                                            : "No more items",
                                        pref!
                                            ? AppColors.inActiveColor
                                            : AppColors.blackColor
                                                .withOpacity(0.6),
                                        3.w,
                                        FontWeight.w500,
                                        textDirection: isRtl
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, MarketController controller, bool isRtl) {
    final isNetworkError = controller.errorMessage.value.contains('Error') ||
        controller.errorMessage.value.contains('Failed to fetch') ||
        controller.errorMessage.value.toLowerCase().contains('socket') ||
        controller.errorMessage.value.toLowerCase().contains('network') ||
        controller.errorMessage.value.toLowerCase().contains('connection');

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isNetworkError
                    ? AppColors.secondaryColor.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError ? LucideIcons.wifiOff : LucideIcons.wifiOff,
                size: 20.w,
                color: isNetworkError
                    ? AppColors.secondaryColor
                    : AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 3.h),
            textNormal(
                isNetworkError
                    ? (isRtl
                        ? "لا يوجد اتصال بالإنترنت"
                        : "No Internet Connection")
                    : (isRtl ? "حدث خطأ" : "Something went wrong"),
                pref! ? AppColors.whiteColor : AppColors.blackColor,
                4.5.w,
                FontWeight.w700,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
            SizedBox(height: 2.h),
            textNormal(
                isNetworkError
                    ? (isRtl
                        ? "يرجى التحقق من اتصالك بالإنترنت"
                        : "Please check your internet connection")
                    : controller.errorMessage.value,
                pref!
                    ? AppColors.inActiveColor
                    : AppColors.blackColor.withOpacity(0.6),
                3.5.w,
                FontWeight.w600,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () async {
                if (isNetworkError) {
                  await controller.refreshData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              icon: Icon(LucideIcons.refreshCw,
                  size: 5.w,
                  color: pref! ? AppColors.blackColor : AppColors.whiteColor),
              label: textNormal(
                  isRtl ? "إعادة المحاولة" : "Try Again",
                  pref! ? AppColors.blackColor : AppColors.whiteColor,
                  3.5.w,
                  FontWeight.w600,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerPage({
    required int numOfStars,
    required VoidCallback onPress,
    required VoidCallback onTapCharge,
    required bool isRtl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      padding: EdgeInsets.only(
        left: isRtl ? 0 : 4.w,
        right: isRtl ? 4.w : 0,
        top: 6.h,
        bottom: 2.h,
      ),
      child: Column(
        children: [
          _buildAppBar(onPress: onPress, isRtl: isRtl),
          SizedBox(height: 1.h),
          Row(
            children: [
              CircleAvatar(
                radius: 5.w,
                backgroundColor:
                    pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                child: CircleAvatar(
                  backgroundImage:
                      const AssetImage("lib/Images/play_store_512.png"),
                  radius: 4.w,
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              textNormal(
                S.of(Get.context!).mayolivechat,
                pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                3.5.w,
                FontWeight.bold,
              ),
            ],
          ),
          SizedBox(
            height: 1.5.h,
          ),
          chatCardWidget(
            needsAcceptance: false,
            power: null,
            imageUrl: true,
            numOfMessage: 0,
            onPressImg: () {},
            private: false,
            img: const AssetImage(AppImages.marketImg),
            ttitle: S.of(Get.context!).chargeStars,
            body: S.of(Get.context!).numberOfStarsCount(numOfStars),
            onPressJoin: onTapCharge,
            action: S.of(Get.context!).chargeStarsNow,
            ontap: onTapCharge,
            market: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar({required VoidCallback onPress, required bool isRtl}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildUserGreeting(isRtl),
        _buildActionButtons(onPress: onPress, isRtl: isRtl),
      ],
    );
  }

  Widget _buildUserGreeting(bool isRtl) {
    PowerModel? powerModel;
    if (sharedPreferences!.getString("powermodel").toString() != "null") {
      final power = jsonDecode(sharedPreferences!.getString("powermodel")!)
          as Map<String, dynamic>;
      powerModel = PowerModel.fromJson(power);
    }

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        (sharedPreferences!.getString("img") != null && sharedPreferences!.getString("img").toString().trim().isNotEmpty && sharedPreferences!.getString("img").toString() != "null")
          ? CircleAvatar(
              radius: 4.w,
              backgroundImage: CachedNetworkImageProvider(
                  "${sharedPreferences!.getString("img")}"),
            )
          : CircleAvatar(
              radius: 4.w,
              backgroundColor: Colors.grey,
            ),
        SizedBox(width: 2.w),
        Row(
          children: [
            sharedPreferences!.getString("powermodel") == "" ||
                    sharedPreferences!.getString("powermodel") == "null"
                ? textNormal(
                    sharedPreferences!.getString("username")!,
                    pref! ? AppColors.whiteColor : AppColors.blackColor,
                    3.5.w,
                    FontWeight.w400,
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                  )
                : PowerTextWidget(
                    powerModel: powerModel!,
                    displyText: sharedPreferences!.getString("username"),
                  )
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      {required VoidCallback onPress, required bool isRtl}) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildPinChatButton(onPress: onPress, isRtl: isRtl),
        IconButton(
          icon: Icon(
            LucideIcons.bell,
            size: 5.w,
            color: pref! ? AppColors.inActiveColor : AppColors.blackColor,
          ),
          onPressed: () {
            Get.to(
              () => Notifications(),
              transition: Transition.leftToRight,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPinChatButton(
      {required VoidCallback onPress, required bool isRtl}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: 4.5.h,
        decoration: ShapeDecoration(
          color: pref! ? AppColors.secondaryColor : AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(
                LucideIcons.keyRound,
                color: pref! ? AppColors.blackColor : Colors.white,
                size: 4.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStore(bool isRtl) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // Name column - centered and takes maximum available space
              Expanded(
                flex: 5,
                child: Center(
                  child: textNormal(
                    S.of(Get.context!).name,
                    center: true,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
              // Price column
              Expanded(
                flex: 2,
                child: Center(
                  child: textNormal(
                    S.of(Get.context!).price,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
              // Procedure column
              Expanded(
                flex: 2,
                child: Center(
                  child: textNormal(
                    S.of(Get.context!).procedure,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
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

  Widget _buildStoreInformation(List<PowerModel> storePowers, bool isRtl) {
    final String? name = sharedPreferences!.getString("username");
    final String displayName =
        (name != null && name.isNotEmpty) ? name : "Guest";

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: storePowers.length,
      itemBuilder: (context, index) {
        final power = storePowers[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
          decoration: BoxDecoration(
            color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // Name column - centered and takes maximum space
              Expanded(
                flex: 7,
                child: Center(
                  child: _buildPowerTextWithFallback(
                    power: power,
                    displayName: displayName,
                    isRtl: isRtl,
                  ),
                ),
              ),
              // Price column
              Expanded(
                flex: 3,
                child: Center(
                  child: textNormal(
                    "${power.price} ${S.of(Get.context!).points}",
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.2.w,
                    FontWeight.w500,
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
              // Procedure column
              Expanded(
                flex: 2,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      power.isPurches == 1
                          ? null
                          : showBottomSheetMarketMoreWidget(
                              context: context,
                              isBuy: power.isPurches == 0 ? false : true,
                              name: sharedPreferences!.getString("name") ??
                                  "Guest",
                              price: "${power.price} ${S.of(context).points}",
                              afterParhes: SizedBox(
                                width: 30.w,
                                child: _buildPowerTextWithFallback(
                                  power: power,
                                  displayName: displayName,
                                  isRtl: isRtl,
                                ),
                              ),
                              powerId: power.id!,
                            );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 1.5.w),
                      decoration: BoxDecoration(
                        color: power.isPurches == 1
                            ? AppColors.inActiveColor.withOpacity(0.3)
                            : (pref!
                                ? AppColors.secondaryColor
                                : AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: textNormal(
                        power.isPurches == 1
                            ? S.of(context).isBuy
                            : S.of(Get.context!).more,
                        power.isPurches == 1
                            ? AppColors.inActiveColor
                            : (pref!
                                ? AppColors.blackColor
                                : AppColors.whiteColor),
                        3.2.w,
                        FontWeight.w500,
                        textDirection:
                            isRtl ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build power text with proper fallback
  Widget _buildPowerTextWithFallback({
    required PowerModel power,
    required String displayName,
    required bool isRtl,
  }) {
    try {
      return PowerTextWidget(
        powerModel: power,
        displyText: displayName,
      );
    } catch (e) {
      // Fallback to normal text if PowerTextWidget fails
      return textNormal(
        displayName,
        pref! ? AppColors.whiteColor : AppColors.blackColor,
        3.5.w,
        FontWeight.w400,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      );
    }
  }
}
