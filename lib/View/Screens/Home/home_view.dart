// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Controller/main_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/format_last_message.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Market/market_page.dart';
import 'package:live_chat/View/Screens/notifications/notifications.dart';
import 'package:live_chat/View/Screens/settings/setting_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/chat_card_widget.dart';
import 'package:live_chat/View/Screens/Home/show_bottom_sheet_pin_chat_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/slider_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/sugessted_friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/home/nav_bar.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final hContrtoller = Get.put(HomeNavigationController());
    final mainContrtoller = Get.put(MainController());
    // ignore: unused_local_variable
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        hContrtoller.currentPageIndex == 0
            ? _showExitConfirmation(context)
            : hContrtoller.changePage(0);
      },
      child: GetBuilder<HomeNavigationController>(
        builder: (navController) => Scaffold(
          backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
          body: navController.currentPageIndex == 0
              ? _buildHomeContent(navController, mainContrtoller, onPress: () {
            showBottomSheetPinChatWidget(context: context);
          })
              : navController.currentPageIndex == 1
              ? _buildChatPage(navController, mainContrtoller, onPress: () {
            showBottomSheetPinChatWidget(context: context);
          })
              : navController.currentPageIndex == 2
              ? const MarketPage()
              : const SettingView(),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: navController.currentPageIndex,
            onTap: (i) {
              navController.changePage(i);
            },
          ),
        ),
      ),
    );
  }

  Widget _showExitConfirmation(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.wifiOff,
                size: 20.w,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 3.h),
            textNormal(
                S.of(context).warning,
                pref! ? AppColors.whiteColor : AppColors.blackColor,
                4.5.w,
                FontWeight.w700),
            SizedBox(height: 2.h),
            textNormal(
                S.of(context).exitConfirmation,
                pref!
                    ? AppColors.inActiveColor
                    : AppColors.blackColor.withOpacity(0.6),
                3.5.w,
                FontWeight.w600),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () {
                exit(0);
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
                  S.of(context).exit,
                  pref! ? AppColors.blackColor : AppColors.whiteColor,
                  3.5.w,
                  FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderImg(MainController controller) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    return autoSliderImage(
      images: List.generate(
        controller.adsAdmin.length,
            (index) => InkWell(
          onTap: () {
            controller.launchURL(controller.adsAdmin[index].link!);
          },
          child: Stack(
            fit: StackFit.expand, // 🌟 عشان الصورة تملا المكان كله
            children: [
              // 1. الصورة الأساسية للإعلان
              controller.adsAdmin[index].image == "null" ||
                  controller.adsAdmin[index].image == "image" ||
                  controller.adsAdmin[index].image == null
                  ? Image.asset(AppImages.noChatImg, fit: BoxFit.cover)
                  : CachedNetworkImage(
                errorWidget: (context, url, error) =>
                    Image.asset(AppImages.errorImg),
                imageUrl: controller.adsAdmin[index].image!.trim(),
                fit: BoxFit.cover,
              ),

              // 2. وسم "إعلان" الشيك اللي هيظهر فوق الصورة
              Positioned(
                top: 1.h,
                right: isRtl ? 2.w : null, // 🌟 يمين في العربي
                left: isRtl ? null : 2.w,  // 🌟 شمال في الانجليزي
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), // خلفية شفافة شيك
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.secondaryColor.withOpacity(0.5),
                        width: 1
                    ),
                  ),
                  child: Text(
                    "إعلان", // لو عندك S.of(context).ad استخدمها
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 3.w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatPage(HomeNavigationController controller, MainController mainController, {required onPress}) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.updateChatUI();
      },
      color: AppColors.secondaryColor,
      backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: 7.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(controller, onPress: onPress),
              if (mainController.adsAdmin.isNotEmpty) SizedBox(height: 2.h),
              if (mainController.adsAdmin.isNotEmpty)
                _sliderImg(mainController),
              if (mainController.adsAdmin.isNotEmpty) SizedBox(height: 2.h),
              _buildOtherConversationSection(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherConversationSection(HomeNavigationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        _buildSectionHeader(
          title: S.of(Get.context!).otherChats,
          horizontalPadding: 4.w,
        ),
        SizedBox(height: 2.h),
        _buildOtherChatList(controller),
      ],
    );
  }

  Widget _buildOtherChatList(HomeNavigationController controller) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    return FutureBuilder<List<UserChatModel>>(
      future: controller.getSystemChats(),
      initialData: controller.systemChats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading(10.h);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return controller.statuesRequest == StatuesRequest.socketException
              ? Center(
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.wifiOff,
                      size: 20.w,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  textNormal(
                      isRtl
                          ? "لا يوجد اتصال بالإنترنت"
                          : "No Internet Connection",
                      pref! ? AppColors.whiteColor : AppColors.blackColor,
                      4.5.w,
                      FontWeight.w700),
                  SizedBox(height: 2.h),
                  textNormal(
                      isRtl
                          ? "يرجى التحقق من اتصالك بالإنترنت"
                          : "Please check your internet connection",
                      pref!
                          ? AppColors.inActiveColor
                          : AppColors.blackColor.withOpacity(0.6),
                      3.5.w,
                      FontWeight.w600),
                  SizedBox(height: 4.h),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await controller.updateChatUI();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pref!
                          ? AppColors.secondaryColor
                          : AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    icon: Icon(LucideIcons.refreshCw,
                        size: 5.w,
                        color: pref!
                            ? AppColors.blackColor
                            : AppColors.whiteColor),
                    label: textNormal(
                        isRtl ? "إعادة المحاولة" : "Try Again",
                        pref!
                            ? AppColors.blackColor
                            : AppColors.whiteColor,
                        3.5.w,
                        FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
              : Center(child: noData(S.of(context).noChat));
        } else {
          return SizedBox(
            width: 100.w,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: isRtl ? 0 : 4.w,
                right: isRtl ? 4.w : 0,
              ),
              itemBuilder: (context, index) {
                final chat = snapshot.data![index];
                return chatCardWidget(
                  needsAcceptance: chat.accept=="1"?true:false,

                  power: null,
                  imageUrl: chat.image.toString() == "null" || chat.image == ""
                      ? false
                      : true,
                  numOfMessage: 0,
                  onPressImg: () {
                    dialogImgWidget(
                        title: chat.name!,
                        img: chat.image,
                        onPressChat: () {
                          controller.onPressGroubChat(
                            chatModel: chat,
                            isGust: false,
                            id: chat.id,
                          );
                        },
                        userChatModel: null);
                  },
                  private: chat.status == "Private" ? true : false,
                  img: chat.image == null || chat.image == "null"||chat.image == ""
                      ? const AssetImage(AppImages.noChatImg)
                      : CachedNetworkImageProvider(chat.image!),
                  body: "${chat.membersCount} ${S.of(context).engaged_people}",
                  ttitle: chat.name!,
                  onPressJoin: () {
                    controller.onPressGroubChat(
                      chatModel: chat,
                      isGust: false,
                      id: chat.id,
                    );
                  },
                  isFriendsSection: false,
                  action: S.of(context).joinNow,
                  ontap: () {
                    controller.onPressGroubChat(
                      chatModel: chat,
                      isGust: false,
                      id: chat.id,
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemCount: snapshot.data!.length,
            ),
          );
        }
      },
    );
  }

  Widget _buildHomeContent(
      HomeNavigationController controller, MainController mainController,
      {required onPress}) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.updateUI();
      },
      color: AppColors.secondaryColor,
      backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(controller, onPress: onPress),
            if (mainController.adsAdmin.isNotEmpty) SizedBox(height: 2.h),
            if (mainController.adsAdmin.isNotEmpty) _sliderImg(mainController),
            if (mainController.adsAdmin.isNotEmpty) SizedBox(height: 2.h),
            _buildPrivateChatsSection(controller),
            _buildFriendsSection(controller),
            _buildSuggestedFriendsSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(HomeNavigationController controller, {required onPress}) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return Container(
      padding: EdgeInsets.only(
        left: isRtl ? 0 : 4.w,
        right: isRtl ? 4.w : 0,
        top: 5.h,
        bottom: 2.h,
      ),
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(onPress: onPress),
          SizedBox(height: 2.h),

          // 🌟 اللوجو بس
          _buildPositiveChatHeader(),
          SizedBox(height: 2.h),

          // ==============================
          // 🌟 Pinned Chat Section (يختفي بالكامل لو مفيش محادثة شغالة)
          // ==============================
          if (controller.statuesRequest == StatuesRequest.loading)
            loading(10.h)
          else if (controller.pinChatModel != null && controller.pinChatModel!.conversation != null) ...[
            // 🌟 نقلنا العنوان هنا! مش هيتعرض غير لو المحادثة موجودة فعلاً
            Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                textNormal(
                  S.of(Get.context!).positive_chat,
                  pref! ? AppColors.whiteColor : AppColors.blackColor,
                  4.w,
                  FontWeight.w400,
                ),
                SizedBox(width: 2.w),
                Icon(
                  LucideIcons.pin300,
                  color: pref! ? AppColors.secondaryColor : AppColors.blackColor,
                  size: 5.w,
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // كارت المحادثة
            chatCardWidget(
              power: null,
              imageUrl: controller.pinChatModel!.conversation!.image.toString() == "image" ||
                  controller.pinChatModel!.conversation!.image.toString() == "null" ||
                  controller.pinChatModel!.conversation!.image == "" ||
                  controller.pinChatModel!.conversation!.image == null
                  ? false
                  : true,
              numOfMessage: 0,
              needsAcceptance: controller.pinChatModel!.conversation!.accept == "1", // 🌟 تفعيل القفل للمثبتة لو محتاجة
              onPressImg: () {
                dialogImgWidget(
                  title: controller.pinChatModel!.conversation!.name!,
                  userChatModel: controller.pinChatModel!.conversation!,
                  img: null,
                  onPressChat: () {
                    controller.onPressPinChat(
                      chatModel: controller.pinChatModel!.conversation!,
                      id: controller.pinChatModel!.conversation!.id,
                      isGust: false,
                    );
                  },
                );
              },
              private: controller.pinChatModel!.conversation!.status == "Private"
                  ? true
                  : false,
              img: controller.pinChatModel!.conversation!.image == null ||
                  controller.pinChatModel!.conversation!.image == "null" ||
                  controller.pinChatModel!.conversation!.image == ""
                  ? const AssetImage(AppImages.noChatImg)
                  : CachedNetworkImageProvider(controller.pinChatModel!.conversation!.image!),
              body: "${controller.pinChatModel!.conversation!.membersCount} ${S.of(Get.context!).engaged_people}",
              ttitle: controller.pinChatModel!.conversation!.name!,
              onPressJoin: () {
                controller.onPressPinChat(
                  chatModel: controller.pinChatModel!.conversation!,
                  id: controller.pinChatModel!.conversationId,
                  isGust: false,
                );
              },
              action: S.of(Get.context!).joinNow,
              ontap: () {
                controller.onPressPinChat(
                  chatModel: controller.pinChatModel!.conversation!,
                  id: controller.pinChatModel!.conversation!.id,
                  isGust: false,
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ],
      ),
    );
  }
  Widget _buildAppBar({required onPress}) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildUserGreeting(),
        _buildActionButtons(onPress: onPress),
      ],
    );
  }

  Widget _buildUserGreeting() {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    String? userImage = sharedPreferences!.getString("img");
    String? username = sharedPreferences!.getString("username");
    String? powerString = sharedPreferences!.getString("powermodel");

    // Default to username if power model is invalid
    Widget displayWidget;

    if (powerString != null &&
        powerString.isNotEmpty &&
        powerString != "null") {
      try {
        final power = jsonDecode(powerString) as Map<String, dynamic>;
        final powerModel = PowerModel.fromJson(power);
        displayWidget = PowerTextWidget(
          powerModel: powerModel,
          displyText: username,
        );
      } catch (e) {
        // Fallback to normal text if parsing fails
        displayWidget = textNormal(
          username ?? "User",
          pref! ? AppColors.whiteColor : AppColors.blackColor,
          3.5.w,
          FontWeight.w400,
        );
      }
    } else {
      displayWidget = textNormal(
        username ?? "User",
        pref! ? AppColors.whiteColor : AppColors.blackColor,
        3.5.w,
        FontWeight.w400,
      );
    }

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        (userImage != null && userImage.trim().isNotEmpty && userImage != "null") ? CircleAvatar(
            radius: 4.w,
            backgroundImage:
            CachedNetworkImageProvider(userImage)

        ) : CircleAvatar(
            radius: 4.w,
            backgroundColor:Colors.grey
        ),
        SizedBox(width: 3.w),
        displayWidget,
      ],
    );
  }

  Widget _buildActionButtons({required onPress}) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildPinChatButton(onPress: onPress),
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

  Widget _buildPinChatButton({required onPress}) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
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

  Widget _buildPositiveChatHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 5.w,
          backgroundColor:
          pref! ? AppColors.secondaryColor : AppColors.primaryColor,
          child: CircleAvatar(
            backgroundImage: const AssetImage("lib/Images/play_store_512.png"),
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
    );
  }
  Widget _buildPrivateChatsSection(HomeNavigationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        _buildSectionHeader(
          title: S.of(Get.context!).yourPrivateChats,
          horizontalPadding: 4.w,
        ),
        SizedBox(height: 2.h),
        _buildChatList(controller, itemCount: 2)
      ],
    );
  }

  Widget _buildFriendsSection(HomeNavigationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        _buildSectionHeader(
          title: S.of(Get.context!).yourFriends,
          horizontalPadding: 4.w,
        ),
        SizedBox(height: 2.h),
        controller.statuesRequest == StatuesRequest.loading
            ? loading(10.h)
            : controller.friends.isEmpty
            ? Center(child: noData(S.of(Get.context!).noChat))
            : _buildChatFreindesList(
          controller,
          itemCount: 2,
          isFriendsSection: true,
        ),
      ],
    );
  }

  Widget _buildSuggestedFriendsSection(HomeNavigationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        _buildSectionHeader(
          title: S.of(Get.context!).suggestedFriends,
          horizontalPadding: 4.w,
        ),
        SizedBox(height: 2.h),
        controller.statuesRequest == StatuesRequest.loading
            ? loading(10.h)
            : controller.friendsSuggestion.isEmpty
            ? Center(child: noData(S.of(Get.context!).noChat))
            : _buildSuggestedFriendsList(controller),
      ],
    );
  }

// 🌟 تعديل عرض الأقسام بشكل احترافي للعداد والسهم
  Widget _buildSectionHeader({
    required String title,
    double horizontalPadding = 0,
  }) {
    final navController = HomeNavigationController.to;
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    // 🌟 تحديد هل القسم ده محتاج عداد ولا لأ، وقيمته كام
    bool showCounter = false;
    int counterValue = 0;

    if (title == S.of(Get.context!).yourFriends) {
      showCounter = true;
      counterValue = navController.totalFriendsCount;
    } else if (title == S.of(Get.context!).yourPrivateChats) {
      showCounter = true;
      counterValue = navController.totalPrivateChatsCount;
    }

    return GestureDetector(
      onTap: () {
        if (title == S.of(Get.context!).yourPrivateChats) {
          navController.navigateToPrivateChats();
        } else if (title == S.of(Get.context!).yourFriends) {
          navController.navigateToFriends();
        } else if (title == S.of(Get.context!).suggestedFriends) {
          navController.navigateToSuggestedFriends();
        } else {
          navController.navigateToAnotherChats();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🌟 عشان نرمي السهم والعداد أقصى الشمال
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // العنوان
            textNormal(
              title,
              pref! ? AppColors.whiteColor : AppColors.blackColor,
              4.5.w,
              FontWeight.w400,
            ),

            // 🌟 العداد والسهم متجمعين مع بعض
            Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (title == S.of(Get.context!).yourFriends && navController.totalReceivedRequestsCount > 0) ...[
                  Container(
                    width: 2.5.w,
                    height: 2.5.w,
                    decoration: const BoxDecoration(
                      color: AppColors.redColor, // نقطة حمرا للتنبيه
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
                if (showCounter) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // بادينج مريح
                    decoration: BoxDecoration(
                      color: pref! ? AppColors.secondaryColor : AppColors.primaryColor, // 🌟 لون صريح وبارز
                      borderRadius: BorderRadius.circular(20), // شكل بيضاوي/دائري شيك
                    ),
                    child: textNormal(
                      "$counterValue",
                      pref! ? AppColors.blackColor : Colors.white, // 🌟 الخط أبيض عشان ينطق على اللون الأساسي
                      3.5.w,
                      FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2.w), // مسافة بين العداد والسهم
                ],
                Icon(
                  isRtl ? LucideIcons.moveLeft300 : LucideIcons.moveRight300,
                  color: AppColors.secondaryColor,
                  size: 7.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } Widget _buildChatList(
      HomeNavigationController controller, {
        required int itemCount,
        bool isFriendsSection = false,
      }) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    return SizedBox(
      width: 100.w,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: isRtl ? 0 : 4.w,
          right: isRtl ? 4.w : 0,
        ),
        itemBuilder: (context, index) {
          if (index == 0 && !isFriendsSection) {
            return chatCardWidget(
              needsAcceptance: false,
              power: null,
              imageUrl: true,
              numOfMessage: 0,
              onPressImg: () {},
              private: false,
              img: const AssetImage(AppImages.noChatImg),
              body: S.of(context).startCreatingNewWorld,
              ttitle: S.of(context).newChat,
              onPressJoin: controller.onPressCreateChat,
              isFriendsSection: isFriendsSection,
              action: S.of(context).createNow,
              ontap: controller.onPressCreateChat,
            );
          }

          return controller.userMyChatModel != null
              ? chatCardWidget(
            needsAcceptance: controller.userMyChatModel!.accept=="1"?true:false,

            power: null,
            imageUrl:
            controller.userMyChatModel!.image.toString() == "image" ||
                controller.userMyChatModel!.image.toString() ==
                    "null" ||
                controller.userMyChatModel!.image == ""|| controller.userMyChatModel!.image==
                null
                ? false
                : true,
            numOfMessage: controller.userMyChatModel!.unreadCount!,
            onPressImg: () {
              dialogImgWidget(
                  title: controller.userMyChatModel!.name!,
                  img: controller.userMyChatModel!.image,
                  onPressChat: () {
                    controller.onPressGroubChat(
                        chatModel: controller.userMyChatModel!,
                        isGust: false,
                        id: controller.userMyChatModel!.id);
                  },
                  userChatModel: controller.userMyChatModel);
            },
            private: controller.userMyChatModel!.status == "Private"
                ? true
                : false,
            img: controller.userMyChatModel!.image == "image" ||
                controller.userMyChatModel!.image.toString() == "null"
                ? const AssetImage(AppImages.noChatImg)
                : CachedNetworkImageProvider(
                "${controller.userMyChatModel!.image}"),
            body: formatLastMessage(context, controller.userMyChatModel!),
            ttitle: controller.userMyChatModel!.name!,
            onPressJoin: () {
              controller.onPressGroubChat(
                  chatModel: controller.userMyChatModel!,
                  isGust: false,
                  id: controller.userMyChatModel!.id);
            },
            isFriendsSection: isFriendsSection,
            action: S.of(context).joinNow,
            ontap: () {
              controller.onPressGroubChat(
                  chatModel: controller.userMyChatModel!,
                  isGust: false,
                  id: controller.userMyChatModel!.id);
            },
          )
              : null;
        },
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemCount: controller.userMyChatModel != null ? itemCount : 1,
      ),
    );
  }

  Widget _buildChatFreindesList(
      HomeNavigationController controller, {
        required int itemCount,
        bool isFriendsSection = false,
      }) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;

    return SizedBox(
      width: 100.w,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: isRtl ? 0 : 4.w,
          right: isRtl ? 4.w : 0,
        ),
        itemBuilder: (context, index) {
          return chatCardWidget(
              needsAcceptance: false,

              power: controller.friends[index].power,
              imageUrl: controller.friends[index].image.toString() == "null" ||
                  controller.friends[index].image == ""
                  ? false
                  : true,
              numOfMessage: 0,
              onPressImg: () {
                dialogImgWidget(
                    title: controller.friends[index].name!,
                    img: controller.friends[index].image,
                    userChatModel: null,
                    onPressChat: () {
                      if (controller.friends[index].requestStatus ==
                          "friends") {
                        controller.createChatFriend(
                          index: index,
                            requestStatus: controller.friends[index].requestStatus!,
                            friendID: controller.friends[index].id!);
                      } else {}
                    });
              },
              private: false,
              img: controller.friends[index].image == "image" ||
                  controller.friends[index].image.toString() == "null"|| controller.friends[index].image.toString() == ""
                  ? const AssetImage(AppImages.noChatImg)
                  : CachedNetworkImageProvider(
                  controller.friends[index].image!),
              body: controller.friends[index].requestStatus == "friends"
                  ? S.of(context).friend
                  : S.of(context).requestWaiting,
              ttitle: controller.friends[index].username!,
              onPressJoin: () {
                if (controller.friends[index].requestStatus == "friends") {
                  controller.createChatFriend(
                    requestStatus: controller.friends[index].requestStatus! ,
                      index: index,
                      friendID: controller.friends[index].id!);
                } else {
                  controller.sendFriendRequest(
                      index: index, friendID: controller.friends[index].id);
                }
              },
              isFriendsSection: isFriendsSection,
              action: controller.friends[index].requestStatus == "friends"
                  ? S.of(context).correspondent
                  : S.of(context).cancel,
              ontap: () {
                if (controller.friends[index].requestStatus == "friends") {
                  controller.createChatFriend(
                    index: index,
                      requestStatus:  controller.friends[index].requestStatus!,
                      friendID: controller.friends[index].id!);
                } else {
                  controller.sendFriendRequest(
                      index: index, friendID: controller.friends[index].id);
                }
              },
              isFriend: controller.friends[index].requestStatus == "friends"
                  ? true
                  : false);
        },
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemCount:
        controller.friends.length > 2 ? 2 : controller.friends.length,
      ),
    );
  }

  Widget _buildSuggestedFriendsList(HomeNavigationController controller) {
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
    return SizedBox(
      width: 100.w,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            right: isRtl ? 4.w : 0, left: isRtl ? 0 : 4.w, bottom: 2.h),
        itemBuilder: (context, index) => GetBuilder<HomeNavigationController>(
          builder: (c) => SuggestedFriends(
            power: controller.friendsSuggestion[index].power,
            imgUrl: controller.friendsSuggestion[index].image.toString() ==
                "null" ||
                controller.friendsSuggestion[index].image == ""
                ? false
                : true,
            onPressImg: () {
              dialogImgWidget(
                  title: controller.friendsSuggestion[index].name!,
                  img: controller.friendsSuggestion[index].image,
                  userChatModel: null,
                  onPressChat: () {
                    controller.createChatFriend(
                      requestStatus: controller.friendsSuggestion[index].requestStatus! ,
                        index: index,
                        friendID: controller.friendsSuggestion[index].id!);
                  });
            },
            chat: () {
              controller.createChatFriend(
                index: index,
                  requestStatus:  controller.friendsSuggestion[index].requestStatus!,
                  friendID: controller.friendsSuggestion[index].id!);
            },
            removeRequest: () {
              controller.sendFriendRequest(
                index: index,
                friendID: controller.friendsSuggestion[index].id,
              );
            },
            requestSend:
            controller.friendsSuggestion[index].requestStatus == "none"
                ? false
                : true,
            sendRequest: () {
              controller.sendFriendRequest(
                index: index,
                friendID: controller.friendsSuggestion[index].id,
              );
            },
            img: controller.friendsSuggestion[index].image == "image" ||
                controller.friendsSuggestion[index].image.toString() ==
                    "null"||    controller.friendsSuggestion[index].image.toString() ==
                ""
                ? const AssetImage(AppImages.noChatImg)
                : CachedNetworkImageProvider(
                controller.friendsSuggestion[index].image!),
            body: controller.friendsSuggestion[index].requestStatus == "none"
                ? S.of(context).notFriend
                : S.of(context).requestWaiting,
            ttitle: controller.friendsSuggestion[index].username ?? "",
          ),
        ),
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemCount: controller.friendsSuggestion.length,
      ),
    );
  }
}