// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/friend_suggest_model.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Widget/PublicWidget/dialog_img.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/no_data.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class RequestsController extends GetxController {
  StatuesRequest statuesRequest = StatuesRequest.none;
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.put(Api()));
  final RxList<SuggestFreindModel> friends =
      <SuggestFreindModel>[].obs; // Reactive list
  int currentPage = 1;
  RxBool hasMoreData = true.obs; // Reactive boolean
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    _initialFetch();
  }

  void navigateToChats({UserChatModel? userchat}) {
    Get.to(
      () => ChatView(
        isGust: false,
        isPin: false,
        userChatModel: userchat,
      ),
      arguments: {"chatId": userchat!.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  createChatFriend({required friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.createChatFriend(
        friendId: friendID, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response['data'];

      navigateToChats(userchat: UserChatModel.fromJson(responseBody));
    } else{          showUserFriendlyError(statuesRequest);
}
    update();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _initialFetch() async {
    await refreshData();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        statuesRequest != StatuesRequest.loading &&
        hasMoreData.value) {
      getFriends(page: currentPage + 1);
    }
  }

  Future<void> getFriends({int page = 1}) async {
    if (!hasMoreData.value && page != 1) return;

    if (page == 1) {
      friends.clear();
      hasMoreData.value = true;
    }

    statuesRequest = StatuesRequest.loading;
    update();

    var response = await _chatsRemoteData.getFriende(
        page: page, perPage: 15, token: sharedPreferences!.getString("token"));
    print("response for page $page: $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      if (responseBody.isEmpty) {
        hasMoreData.value = false;
      } else {
        friends.assignAll(
          responseBody
              .map((e) => SuggestFreindModel.fromJson(e))
              .where((element) => element.requestStatus == "request_received"),
        );
        currentPage = page;
      }
    } else {
      hasMoreData.value = false;
              showUserFriendlyError(statuesRequest);

    }

    update();
  }

  Future<void> rejectFriend({required int friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptOrRejectRequestFriend(
        status: 0,
        friendId: friendID,
        token: sharedPreferences!.getString("token"));
    print("response reject ??? $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      friends.removeWhere((friend) => friend.id == friendID);
    } else {          showUserFriendlyError(statuesRequest);
}
    update();
  }

  Future<void> acceptFriend({required int friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptOrRejectRequestFriend(
        status: 1,
        friendId: friendID,
        token: sharedPreferences!.getString("token"));
    print("response ??? $response");

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      friends.removeWhere((friend) => friend.id == friendID);
    }  else{          showUserFriendlyError(statuesRequest);
}
    update();
  }

  Future<void> refreshData() async {
    currentPage = 1;
    hasMoreData.value = true;
    await getFriends(page: 1);
  }

  var isEditing = false.obs;

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }
}

class ChatItem {
  final ImageProvider image;
  final String title;
  final String body;

  ChatItem({
    required this.image,
    required this.title,
    required this.body,
  });
}

// ignore: non_constant_identifier_names
Widget FriendsChatCard({
  required ImageProvider img,
  required PowerModel power,
  required VoidCallback onPressImg,
  required VoidCallback onPressChat,
  required bool imgUrl,
  required String ttitle,
  required String body,
  required VoidCallback onPressAccept,
  required VoidCallback onPressReject,
}) {
  final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
  return Padding(
    padding: EdgeInsets.only(
      left: isRtl ? 0.w : 4.w,
      right: isRtl ? 4.w : 0.w,
    ),
    child: SizedBox(
      height: 19.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              imgUrl
                  ? InkWell(
                      onTap: onPressImg,
                      child: Container(
                        width: 19.w,
                        height: 19.w,
                        decoration: BoxDecoration(
                          color: pref! ? AppColors.darkcolor : null,
                          image: DecorationImage(
                            image: img,
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(80),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: onPressImg,
                      child: Container(
                        alignment: Alignment.center,
                        width: 19.w,
                        height: 19.w,
                        decoration: BoxDecoration(
                          color: pref!
                              ? AppColors.darkcolor
                              : AppColors.black2TextColor,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: textNormal(ttitle[0], AppColors.whiteColor, 7.w,
                            FontWeight.bold),
                      ),
                    ),
              SizedBox(width: 2.w),
              InkWell(
                onTap: onPressChat,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    power.toString() != "null"
                        ? PowerTextWidget(
                            powerModel: power,
                            displyText: ttitle,
                          )
                        : textNormal(
                            ttitle,
                            pref!
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            3.5.w,
                            FontWeight.w400),
                    const Spacer(flex: 1),
                    textNormal(
                        body,
                        pref!
                            ? AppColors.inActiveColor
                            : AppColors.black2TextColor,
                        3.w,
                        FontWeight.w500),
                    const Spacer(flex: 1),
                    textNormal(
                        "",
                        pref!
                            ? AppColors.inActiveColor
                            : AppColors.black2TextColor,
                        3.w,
                        FontWeight.w500),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (!isRtl)
                SizedBox(
                  width: 4.w,
                ),
              InkWell(
                onTap: onPressAccept,
                child: Container(
                  height: 12.w,
                  width: 12.w,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color:
                            pref! ? AppColors.whiteColor : AppColors.blackColor,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color:
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              InkWell(
                onTap: onPressReject,
                child: Container(
                  height: 12.w,
                  width: 12.w,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.redColor)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: AppColors.redColor,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
              if (isRtl)
                SizedBox(
                  width: 4.w,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class Requests extends StatelessWidget {
  Requests({super.key});

  final controller = Get.put(RequestsController());
  final homeController = Get.put(HomeNavigationController());

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(
          left: isRtl ? 0.w : 4.w,
          right: isRtl ? 4.w : 0.w,
          top: 5.h,
          bottom: 2.h,
        ),
        child: GetBuilder<RequestsController>(
          builder: (controller) => RefreshIndicator(
            onRefresh: controller.refreshData,
            color: AppColors.secondaryColor,
            backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
            child: ListView(
              controller: controller.scrollController,
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(context),
                SizedBox(height: 5.h),
                _buildChatList(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            GestureDetector(
              onTap: () {
                Get.off(
                  () => Friends(),
                  transition: Transition.leftToRight,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: Icon(
                isRtl
                    ? IconsaxPlusLinear.arrow_right_3
                    : IconsaxPlusLinear.arrow_left_1,
                size: 5.5.w,
                color: pref! ? AppColors.whiteColor : AppColors.blackColor,
              ),
            ),
            SizedBox(width: 2.w),
            textNormal(
              S.of(context).requests,
              pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              4.5.w,
              FontWeight.w500,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatList(RequestsController controller) {
    return Obx(() {
      if (controller.statuesRequest == StatuesRequest.loading &&
          controller.friends.isEmpty) {
        return loading(80.h);
      } else if (controller.friends.isEmpty) {
        return controller.statuesRequest == StatuesRequest.socketException
            ? messageErrorWithButton(
                S.of(Get.context!).error,
                S.of(Get.context!).noInternet,
                () {
                  controller.getFriends(page: 1);
                },
                S.of(Get.context!).retry,
              )
            : Center(
                child: SizedBox(
                    width: 80.w,
                    child: noData(S.of(Get.context!).notFriendRequest)),
              );
      } else {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: controller.friends.length + 1, // +1 for loading indicator
          itemBuilder: (context, index) {
            if (index == controller.friends.length) {
              return controller.statuesRequest == StatuesRequest.loading &&
                      controller.friends.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: loading(10.h),
                    )
                  : const SizedBox.shrink();
            }
            final friend = controller.friends[index];
            return FriendsChatCard(
              onPressChat: () {
                controller.createChatFriend(
                    friendID: controller.friends[index].id);
              },
              power: friend.power!,
              imgUrl: friend.image.toString() == "null" || friend.image == ""
                  ? false
                  : true,
              onPressImg: () {
                dialogImgWidget(
                    title: friend.username!,
                    img: friend.image,
                    onPressChat: () {
                      controller.createChatFriend(
                          friendID: controller.friends[index].id);
                    },
                    userChatModel: null);
              },
              onPressAccept: () {
                controller.acceptFriend(friendID: friend.id!);
              },
              onPressReject: () {
                controller.rejectFriend(friendID: friend.id!);
              },
              img: friend.image == "image" || friend.image.toString() == "null"
                  ? const AssetImage(AppImages.noChatImg)
                  : CachedNetworkImageProvider(friend.image!),
              body: S.of(context).sendToYouRequest,
              ttitle: friend.username!,
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
        );
      }
    });
  }
}
