// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Widget/ChatWidgets/chat_app_bar_widget.dart';
import 'package:live_chat/View/Widget/ChatWidgets/chat_helpers.dart';
import 'package:live_chat/View/Widget/ChatWidgets/chat_input_widget.dart';
import 'package:live_chat/View/Widget/ChatWidgets/chat_bubble_widget.dart';
import 'package:live_chat/View/Widget/ChatWidgets/pinned_ad_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class ChatView extends StatefulWidget {
  final UserChatModel? userChatModel;
  final bool isPin;
  final bool isGust;

  const ChatView({super.key, required this.userChatModel, required this.isPin, required this.isGust});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();
  bool showScrollToBottom = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void initState() {
    super.initState();
    final controller = Get.put(ChatController());
    
    // 🌟 تحديد نوع الشات عشان نمنع الـ APIs اللي ملهاش لازمة في الشات الخاص (بين شخصين)
    // غرف الدردشة بيبقى الـ status بتاعها Public أو Private، أما شات الأصدقاء مبيكونش كده
    controller.isPublicChat = widget.userChatModel?.status == 'Public' || widget.userChatModel?.status == 'Private';

    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!showScrollToBottom) setState(() => showScrollToBottom = true);
      } else {
        if (showScrollToBottom) setState(() => showScrollToBottom = false);
      }
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 && !controller.isLoadingMore && controller.hasMoreMessages) {
        controller.loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) { 
        if (didPop) return;
        Future.microtask(() {
          widget.isGust ? Get.back() : Get.offAll(() => const HomeView()); 
        });
      },
      child: Scaffold(
        backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
        body: SafeArea(
          child: GetBuilder<ChatController>(
            builder: (controller) => controller.statuesRequest == StatuesRequest.loading
                ? Center(child: textNormal(S.of(context).joining, AppColors.primaryColor, 3.5.w, FontWeight.w500))
                : Container(
              decoration: BoxDecoration(image: ChatHelpers.getBackgroundImage(widget.userChatModel!)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, right: 3.w, left: 3.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // عشان مياخدش مساحة زيادة
                      children: [
                        ChatAppBarWidget(controller: controller, userChatModel: widget.userChatModel!, isGust: widget.isGust, isRtl: isRtl),

                        if (widget.isPin && ChatHelpers.hasAd(widget.userChatModel!))
                          PinnedAdWidget(pref: pref!, adTitle: widget.userChatModel!.adTitle, adLink: widget.userChatModel!.adLink, adImage: widget.userChatModel!.adImage),

                        SizedBox(height: 2.h),
                        ChatHelpers.buildMusicBar(controller, isRtl, context),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Stack(
                        children: [
                          Obx(() {
                            return ListView.separated(
                              separatorBuilder: (context, index) {
                                if (index >= controller.messages.length - 1) return const SizedBox(height: 20);
                                return SizedBox(height: controller.messages[index + 1].senderName != controller.messages[index].senderName ? 15 : 0);
                              },
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 0),
                              reverse: true, // مهم جداً عشان الشات يبتدي من تحت
                              itemCount: controller.messages.length + (controller.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == controller.messages.length && controller.isLoadingMore) return const Center(child: CircularProgressIndicator());
                                final message = controller.messages[index];
                                final isLastInGroup = index == 0 || controller.messages[index].senderName != controller.messages[index - 1].senderName;
                                final isFirstInGroup = index == controller.messages.length - 1 || controller.messages[index].senderName != controller.messages[index + 1].senderName;

                                return ChatBubbleWidget(
                                  key: ValueKey(message.messageId),
                                  pref: pref!,
                                  name: message.senderName?.toString() ?? '',
                                  img: message.imageUrl,
                                  message: message,
                                  showAvatar: isFirstInGroup,
                                  isFirstInGroup: isFirstInGroup,
                                  isLastInGroup: isLastInGroup,
                                  onLongPress: () => ChatHelpers.showReactionBottomSheet(context, index, controller),
                                );
                              },
                            );
                          }),
                          if (showScrollToBottom)
                            Positioned(
                              bottom: 10, left: isRtl ? 4.w : null, right: isRtl ? null : 4.w,
                              child: FloatingActionButton(mini: true, backgroundColor: AppColors.primaryColor, onPressed: _scrollToBottom, child: const Icon(Icons.keyboard_arrow_down, color: Colors.white)),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // الجزء اللي تحت (شريط الإدخال)
                  Padding(
                    padding: EdgeInsets.only(right: 3.w, left: 3.w, bottom: 2.5.h),
                    child: ChatInputWidget(controller: controller, userChatModel: widget.userChatModel!, isRtl: isRtl, onScrollToBottom: _scrollToBottom),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }}