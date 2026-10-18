// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/settings.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_change_music.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_sheet_persons_chat.dart';
import 'package:live_chat/View/Widget/ChatWidgets/voice_recording_widgets.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/unblock_friend_dialog.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

//region Voice Recording Wave Widget

class ChatViewFriend extends StatefulWidget {
  final UserChatModel? userChatModel;
  final bool isPin;
  final bool isGust;

  const ChatViewFriend({
    super.key,
    required this.userChatModel,
    required this.isPin,
    required this.isGust,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatViewFriend> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = Get.put(ChatController());
    controller.isPublicChat = false;
    controller.userChatModel = widget.userChatModel;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !controller.isLoadingMore &&
          controller.hasMoreMessages) {
        controller.loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildVoiceRecordingSection(ChatController controller, bool isRtl) {
    if (controller.isRecording) {
      return Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          child: EnhancedVoiceRecording(
            isRecording: controller.isRecording,
            isPaused: false,
            pref: pref ?? false,
            onStartRecording: controller.startRecording,
            onStopRecording: controller.stopRecording,
            onCancelRecording: controller.cancelRecording,
            onPauseRecording: () {},
            onResumeRecording: () {},
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => controller.startRecording(),
        child: Icon(
          IconsaxPlusLinear.microphone,
          color: pref! ? AppColors.secondaryColor : AppColors.blackTextColor,
          size: 6.w,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //>>>> 20/7/2026   Get.put(ChatController());
    // ignore: unused_local_variable
    final controller = Get.find<ChatController>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Get.back();
        } else {
          Get.offAll(() => const HomeView());
        }
      },
      child: Scaffold(
        backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
        body: SafeArea(
          child: GetBuilder<ChatController>(
            builder: (controller) => controller.statuesRequest ==
                    StatuesRequest.loading
                ? Center(
                    child: textNormal(
                      S.of(context).joining,
                      AppColors.primaryColor,
                      3.5.w,
                      FontWeight.w500,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      image: _getBackgroundImage(widget.userChatModel!),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 2.h,
                        right: 3.w,
                        left: 3.w,
                      ),
                      child: Column(
                        children: [
                          _buildAppBar(controller, isRtl),
                          if (widget.isPin && _hasAd(widget.userChatModel!))
                            const SizedBox(height: 20),
                          if (widget.isPin && _hasAd(widget.userChatModel!))
                            const SizedBox(height: 20),
                          if (widget.isPin && _hasAd(widget.userChatModel!))
                            _buildAdBanner(widget.userChatModel!),
                          SizedBox(height: 2.h),
                          _buildMusicBar(controller, isRtl, context),
                          Expanded(
                            child: Obx(() {
                              return ListView.separated(
                                separatorBuilder: (context, index) {
                                  if (index >= controller.messages.length - 1) {
                                    return const SizedBox(height: 20);
                                  }
                                  final currentMessage =
                                      controller.messages[index];
                                  final nextMessage =
                                      controller.messages[index + 1];
                                  return SizedBox(
                                    height: nextMessage.senderName !=
                                            currentMessage.senderName
                                        ? 15
                                        : 0,
                                  );
                                },
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.h, horizontal: 0),
                                reverse: true,
                                itemCount: controller.messages.length +
                                    (controller.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == controller.messages.length &&
                                      controller.isLoadingMore) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final message = controller.messages[index];
                                  final isLastInGroup = _isLastMessageInGroup(
                                      controller.messages, index);
                                  final isFirstInGroup = _isFirstMessageInGroup(
                                      controller.messages, index);
                                  return ChatBubbleWidget(
                                    key: ValueKey(
                                        "${message.messageId}_${message.isRead}_${message.isPending}"),
                                    name: message.senderName?.toString() ?? '',
                                    img: message.imageUrl?.toString() ?? 'null',
                                    message: message,
                                    showAvatar: isFirstInGroup,
                                    isFirstInGroup: isFirstInGroup,
                                    isLastInGroup: isLastInGroup,
                                    onLongPress: () => _showReactionBottomSheet(
                                        context, index, controller),
                                  );
                                },
                              );
                            }),
                          ),
                          _buildInputArea(controller, isRtl, context),
                          SizedBox(height: 2.5.h),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  DecorationImage? _getBackgroundImage(UserChatModel model) {
    if (model.userTheme.toString() != "null") {
      return DecorationImage(
        image: CachedNetworkImageProvider("${model.userTheme}"),
        fit: BoxFit.cover,
      );
    } else if (model.themeId?.toString() != "null") {
      return DecorationImage(
        image: CachedNetworkImageProvider("${model.themeId?.theme}"),
        fit: BoxFit.cover,
      );
    } else {
      return null;
    }
  }

  bool _hasAd(UserChatModel model) {
    return (model.adTitle?.isNotEmpty == true && model.adTitle != "null") ||
        (model.adLink?.isNotEmpty == true && model.adLink != "null");
  }

  Widget _buildAdBanner(UserChatModel model) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blackColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              LucideIcons.pin300,
              color: AppColors.inActiveColor,
              size: 6.w,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textNormal(
                model.adTitle ?? "",
                AppColors.blackTextColor,
                3.5.w,
                FontWeight.w500,
              ),
              textClick(
                model.adLink ?? "",
                true,
                () {},
                AppColors.blackTextColor,
                3.5.w,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(ChatController controller, bool isRtl) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        Get.offAll(() => const HomeView());
                      }
                    },
                    child: Icon(
                      isRtl
                          ? IconsaxPlusLinear.arrow_right_3
                          : IconsaxPlusLinear.arrow_left_1,
                      size: 5.w,
                      color: pref!
                          ? AppColors.blackColor
                          : AppColors.blackTextColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    widget.userChatModel!.name!,
                    style: TextStyle(
                      color: pref!
                          ? AppColors.blackColor
                          : AppColors.blackTextColor,
                      fontSize: 4.w,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _buildAppBarActions(controller, isRtl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarActions(ChatController controller, bool isRtl) {
    final isCurrentUser = widget.userChatModel!.user!.id.toString() ==
        sharedPreferences!.getString("id");
    final isGroup = widget.userChatModel!.status != "Friends" &&
        widget.userChatModel!.status != "Not Friend";

    if (isGroup) {
      if (isCurrentUser) {
        return Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // _buildShareIcon(controller),
            // const SizedBox(width: 16),
            _buildMusicIcon(),
            const SizedBox(width: 16),
            _buildProfileIcon(controller),
            const SizedBox(width: 16),
            _buildSettingsIcon(),
            const SizedBox(width: 16),
            _buildCallMenu(isRtl),
          ],
        );
      } else {
        return Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // _buildShareIcon(controller),
            // const SizedBox(width: 16),
            _buildMusicIcon(),
            const SizedBox(width: 16),
            _buildProfileIcon(controller),
            _buildCallMenu(isRtl),
          ],
        );
      }
    } else {
      return Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          _buildAudioCallIcon(),
          const SizedBox(width: 16),
          _buildVideoCallIcon(),
          const SizedBox(width: 16),
          _buildBlockIcon(controller),
        ],
      );
    }
  }

  // Widget _buildShareIcon(ChatController controller) => GestureDetector(
  //       onTap: () =>
  //           controller.shareChat(link: widget.userChatModel!.chatLink!),
  //       child: Icon(
  //         IconsaxPlusLinear.share,
  //         size: 5.5.w,
  //         color: pref! ? AppColors.whiteColor : AppColors.blackColor,
  //         shadows: [
  //           Shadow(
  //               blurRadius: 15.0,
  //               color: pref! ? AppColors.blackColor : Colors.white)
  //         ],
  //       ),
  //     );

  Widget _buildMusicIcon() => GestureDetector(
        onTap: () => showBottomSheetChangeMusicWidget(context: context),
        child: Icon(
          IconsaxPlusLinear.music,
          color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          size: 5.5.w,
          shadows: [
            Shadow(
                blurRadius: 15.0,
                color: pref! ? AppColors.blackColor : Colors.white)
          ],
        ),
      );

  Widget _buildProfileIcon(ChatController controller) => GestureDetector(
        onTap: () {
          final isGuestUser = sharedPreferences?.getString("id") == null;
          if (isGuestUser) {
            messageErrorWithButton(
              S.of(context).alert,
              S.of(context).pleaseLoginToAccess,
              () {
                Get.back();
                Get.back();
              },
              S.of(context).login,
            );
          } else {
            controller.getMembers();
            showBottomSheetControlPersonWidget(
              idAdmins: widget.userChatModel!.chatAdmins!,
              isNeedAccept: widget.userChatModel!.accept == "0",
              idOwner: widget.userChatModel!.user!.id.toString(),
              context: context,
            );
          }
        },
        child: Icon(
          IconsaxPlusLinear.profile,
          size: 5.5.w,
          color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          shadows: [
            Shadow(
                blurRadius: 15.0,
                color: pref! ? AppColors.blackColor : Colors.white)
          ],
        ),
      );

  Widget _buildSettingsIcon() => GestureDetector(
        onTap: () {
          Get.to(
            () => const Settings(),
            arguments: {"chatModel": widget.userChatModel},
            transition: Transition.leftToRight,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        child: Icon(
          IconsaxPlusLinear.setting,
          size: 5.5.w,
          color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          shadows: [
            Shadow(
                blurRadius: 15,
                color: pref! ? AppColors.blackColor : Colors.white),
          ],
        ),
      );

  Widget _buildCallMenu(bool isRtl) => PopupMenuButton<String>(
        color: pref! ? AppColors.blackColor : Colors.white,
        borderRadius: BorderRadius.circular(10),
        onSelected: (String value) async {
          final controller = Get.find<ChatController>();
          final isGroup = widget.userChatModel!.status == "Public" ||
              widget.userChatModel!.status == "Private";
          final currentUserId = int.tryParse(sharedPreferences?.getString("id") ?? "0") ?? 0;
          final currentUserName = sharedPreferences?.getString("name") ?? "";

          if (value == 'video_call') {
            controller.audio = false;
            await controller.getTokenCall(
                isGroub: isGroup,
                groubUsersNames: isGroup
                    ? {
                        currentUserId: currentUserName,
                      }
                    : {},
                usernameFriend: isGroup ? "" : widget.userChatModel!.name,
                isJoin: controller.isIncomingCallActive);
          } else if (value == 'audio_call') {
            controller.audio = true;
            await controller.getTokenCall(
                isGroub: isGroup,
                groubUsersNames: isGroup
                    ? {
                        currentUserId: currentUserName,
                      }
                    : {},
                usernameFriend: isGroup ? "" : widget.userChatModel!.name,
                isJoin: controller.isIncomingCallActive);
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'video_call',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textNormal(
                  S.of(context).videocall,
                  pref! ? AppColors.whiteColor : AppColors.blackColor,
                  3.5.w,
                  FontWeight.w500,
                ),
                SizedBox(width: 2.w),
                Icon(
                  IconsaxPlusLinear.video,
                  size: 5.w,
                  color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                )
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'audio_call',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textNormal(
                  S.of(context).audiocall,
                  pref! ? AppColors.whiteColor : AppColors.blackColor,
                  3.5.w,
                  FontWeight.w500,
                ),
                SizedBox(width: 2.w),
                Icon(
                  IconsaxPlusLinear.call,
                  size: 5.5.w,
                  color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                ),
              ],
            ),
          ),
        ],
        child: Icon(
          Icons.more_vert,
          size: 5.5.w,
          color: pref! ? AppColors.blackColor : AppColors.blackColor,
        ),
      );

  Widget _buildAudioCallIcon() => GetBuilder<ChatController>(
        builder: (controller) {
          final isBlocked = controller.isIncomingCallActive;
          return GestureDetector(
            onTap: () async {
              if (isBlocked) {
                Get.snackbar(
                  "تنبيه",
                  "يوجد مكالمة جارية بالفعل، يمكنك الضغط على 'انضمام الآن' من الرسالة في الشات",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              final isGroup = widget.userChatModel!.status == "Public" ||
                  widget.userChatModel!.status == "Private";
              controller.audio = true;
              await controller.getTokenCall(
                  isGroub: isGroup,
                  groubUsersNames: isGroup
                      ? {
                          int.parse(sharedPreferences!.getString("id")!):
                              sharedPreferences!.getString("name")!
                        }
                      : {},
                  usernameFriend: isGroup ? "" : widget.userChatModel!.name);
            },
            child: Icon(
              IconsaxPlusLinear.call_calling,
              size: 5.5.w,
              color: isBlocked ? Colors.grey : AppColors.blackColor,
            ),
          );
        },
      );

  Widget _buildVideoCallIcon() => GetBuilder<ChatController>(
        builder: (controller) {
          final isBlocked = controller.isIncomingCallActive;
          return GestureDetector(
            onTap: () async {
              if (isBlocked) {
                Get.snackbar(
                  "تنبيه",
                  "يوجد مكالمة جارية بالفعل، يمكنك الضغط على 'انضمام الآن' من الرسالة في الشات",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              final isGroup = widget.userChatModel!.status == "public" ||
                  widget.userChatModel!.status == "private";
              controller.audio = false;
              await controller.getTokenCall(
                  isGroub: isGroup,
                  groubUsersNames: isGroup
                      ? {
                          int.parse(sharedPreferences!.getString("id")!):
                              sharedPreferences!.getString("name")!
                        }
                      : {},
                  usernameFriend: isGroup ? "" : widget.userChatModel!.name);
            },
            child: Icon(
              IconsaxPlusLinear.video,
              size: 5.5.w,
              color: isBlocked ? Colors.grey : AppColors.blackColor,
            ),
          );
        },
      );

  Widget _buildBlockIcon(ChatController controller) => GestureDetector(
        onTap: () async {
          await controller.getMemberToBlock();
          messageErrorWithButton(
            S.of(context).warning,
            S.of(context).sureToBlock,
            () {
              controller.blockOrUnBlock(
                friendID: controller.memberIdToBlock[0].id.toString(),
                status: 1,
              );
              widget.userChatModel!.isBlocked = "You blocked them";
              Get.back();
            },
            S.of(context).block,
          );
        },
        child: Icon(
          Icons.block,
          size: 5.5.w,
          color: AppColors.redColor,
        ),
      );

  Widget _buildMusicBar(
      ChatController controller, bool isRtl, BuildContext context) {
    if (controller.currentlyPlaying != null || controller.isRadioPlaying) {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: isRtl ? 2.w : 4.w, vertical: 1.h),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(
              controller.isRadioPlaying ? Icons.radio : IconsaxPlusLinear.music,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: textNormal(
                controller.isRadioPlaying
                    ? "${S.of(context).radio} ${controller.currentRadioIndex! + 1}"
                    : S.of(context).nowPlaying('{music}'),
                AppColors.blackTextColor,
                3.5.w,
                FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.isRadioPlaying) {
                  controller.stopRadio();
                }
              },
              child: Icon(IconsaxPlusLinear.close_circle, size: 4.w),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInputArea(
      ChatController controller, bool isRtl, BuildContext context) {
    final isBlocked = widget.userChatModel!.isBlocked;
    final isNotFriend = widget.userChatModel!.status == "Not Friend";
    final hasLastMessage = widget.userChatModel!.lastMessage != null;
    bool answer = controller.answer;
    print("==================================");
    print(
        '''$isNotFriend,    $isBlocked   , $hasLastMessage  ,  $answer , ${sharedPreferences!.getString('id') != widget.userChatModel!.user!.id.toString()}''');
    print("==================================");

    if (isNotFriend && !hasLastMessage && isBlocked == "None") {
      return _buildRequestFriendArea(controller, context);
    } else if (isBlocked == "You blocked them" ||
        isBlocked == "They blocked you") {
      if (isBlocked == "You blocked them") {
        // ignore: avoid_unnecessary_containers
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textNormal(S.of(context).msgIBlock, AppColors.blackColor, 3.5.w,
                  FontWeight.w400),
              const SizedBox(width: 20),
              textClick(S.of(context).unBlock, true, () async {
                final blockId = controller.memberIdToBlock.isNotEmpty
                    ? controller.memberIdToBlock[0].id
                    : (widget.userChatModel?.user?.id ?? widget.userChatModel?.userId ?? 0);
                final success = await controller.blockOrUnBlock(
                  friendID: blockId,
                  status: 0,
                );
                if (success) {
                  widget.userChatModel!.isBlocked = "None";
                  widget.userChatModel!.status = "Not Friend";
                  controller.update();
                  if (context.mounted) {
                    showUnblockFriendDialog(
                      context: context,
                      friendId: blockId,
                      onSendRequest: () async {
                        final reqSuccess = await controller.sendFriendRequest(friendID: blockId);
                        if (reqSuccess) {
                          Get.snackbar(
                            S.of(context).success,
                            S.of(context).youSendRequest,
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                    );
                  }
                }
              }, AppColors.redColor, 3.5.w),
            ],
          ),
        );
      } else {
        return Container(
          child: textNormal(S.of(context).msgBlockUser, AppColors.blackColor,
              3.5.w, FontWeight.w400),
        );
      }
    } else if (isNotFriend &&
        hasLastMessage &&
        isBlocked == "None" &&
        answer == false &&
        widget.userChatModel!.user!.id.toString() !=
            sharedPreferences!.getString('id')) {
      return _buildAcceptOrCancelArea(controller, context);
    } else {
      return _buildMessageInput(controller, isRtl);
    }
  }

  Widget _buildRequestFriendArea(
      ChatController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: .5.h),
        child: Row(
          textDirection: Directionality.of(context) == TextDirection.rtl
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            if (!controller.isRecording)
              GestureDetector(
                onTap: controller.sendImageMessage,
                child: Icon(
                  IconsaxPlusLinear.gallery,
                  size: 6.w,
                  color: pref!
                      ? AppColors.secondaryColor
                      : AppColors.blackTextColor,
                ),
              ),
            SizedBox(width: 2.w),
            buildVoiceRecordingSection(
                controller, Directionality.of(context) == TextDirection.rtl),
            if (!controller.isRecording) ...[
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color:
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    fontSize: 3.5.w,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: S.of(context).sendYourMessage,
                    hintStyle: TextStyle(
                      color: pref!
                          ? AppColors.inActiveColor
                          : AppColors.black2TextColor,
                      fontSize: 3.5.w,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                  onSubmitted: (_) => controller.sendTextMessage(),
                  maxLines: null,
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: controller.sendTextMessage,
                child: Container(
                  width: 11.w,
                  height: 5.h,
                  decoration: ShapeDecoration(
                    color: pref!
                        ? AppColors.secondaryColor
                        : AppColors.buttoncolor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Center(
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? IconsaxPlusLinear.send_2
                          : IconsaxPlusLinear.send_2,
                      size: 4.w,
                      color:
                          pref! ? AppColors.blackColor : AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptOrCancelArea(
      ChatController controller, BuildContext context) {
    return Container(
      width: 80.w,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 65.w,
        child: Column(
          children: [
            textNormal(S.of(context).wantToSendMsg, AppColors.blackTextColor,
                3.5.w, FontWeight.w500),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    controller.answer = true;
                    controller.update();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check,
                            color: AppColors.primaryColor, size: 5.w),
                        textNormal("  ${S.of(context).accept}",
                            AppColors.primaryColor, 4.w, FontWeight.w400),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.blockOrUnBlock(
                      friendID: controller.memberIdToBlock[0].id,
                      status: 1,
                    );
                    widget.userChatModel!.isBlocked = "You blocked them";
                    controller.update();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.redColor),
                    ),
                    child: textNormal("X ${S.of(context).cancel}",
                        AppColors.redColor, 4.w, FontWeight.w400),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller, bool isRtl) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: isRtl ? 4.w : 4.w, vertical: .5.h),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            if (!controller.isRecording)
              GestureDetector(
                onTap: controller.sendImageMessage,
                child: Icon(
                  IconsaxPlusLinear.gallery,
                  size: 6.w,
                  color: pref!
                      ? AppColors.secondaryColor
                      : AppColors.blackTextColor,
                ),
              ),
            SizedBox(width: 2.w),
            buildVoiceRecordingSection(controller, isRtl),
            if (!controller.isRecording) ...[
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color:
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    fontSize: 3.5.w,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: S.of(context).sendYourMessage,
                    hintStyle: TextStyle(
                      color: pref!
                          ? AppColors.inActiveColor
                          : AppColors.black2TextColor,
                      fontSize: 3.5.w,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                  onSubmitted: (_) => controller.sendTextMessage(),
                  maxLines: null,
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: controller.sendTextMessage,
                child: Container(
                  width: 11.w,
                  height: 5.h,
                  decoration: ShapeDecoration(
                    color: pref!
                        ? AppColors.secondaryColor
                        : AppColors.buttoncolor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Center(
                    child: Icon(
                      isRtl
                          ? IconsaxPlusLinear.send_2
                          : IconsaxPlusLinear.send_2,
                      size: 4.w,
                      color:
                          pref! ? AppColors.blackColor : AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReactionBottomSheet(
      BuildContext context, int messageIndex, ChatController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              S.of(context).react,
              style: TextStyle(
                color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                fontSize: 4.w,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReactionButton('❤️', messageIndex, controller, context),
                _buildReactionButton('😂', messageIndex, controller, context),
                _buildReactionButton('😢', messageIndex, controller, context),
                _buildReactionButton('😮', messageIndex, controller, context),
                _buildReactionButton('😡', messageIndex, controller, context),
                _buildReactionButton('👍', messageIndex, controller, context),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji, int messageIndex,
      ChatController controller, BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.addReactionToMessage(
          messageIndex,
          emoji,
          controller.messages[messageIndex].messageId,
        );
        Navigator.pop(context);
      },
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color:
              pref! ? AppColors.blackColor.withOpacity(0.3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: 6.w))),
      ),
    );
  }

  bool _isLastMessageInGroup(List<ChatMessage> messages, int index) {
    if (index == 0) return true;
    return messages[index].senderName != messages[index - 1].senderName;
  }

  bool _isFirstMessageInGroup(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;
    return messages[index].senderName != messages[index + 1].senderName;
  }
}
//endregion

//region ChatBubbleWidget
class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final VoidCallback onLongPress;
  final String name;
  final String img;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.onLongPress,
    required this.name,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0.w,
        vertical: isFirstInGroup
            ? 0.w
            : message.reaction.isNotEmpty
                ? 3.w
                : 3.w,
      ),
      child: Row(
        mainAxisAlignment: isRtl
            ? (message.isFromSender
                ? MainAxisAlignment.start
                : MainAxisAlignment.end)
            : (message.isFromSender
                ? MainAxisAlignment.end
                : MainAxisAlignment.start),
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          if (isRtl && message.isFromSender) SizedBox(width: 0.w),
          if (isRtl && message.isFromSender)
            _buildAvatar(showAvatar, true, name, img),
          if (!isRtl && !message.isFromSender)
            _buildAvatar(showAvatar, false, name, img),
          if (!isRtl && !message.isFromSender) SizedBox(width: 0.w),
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 70.w),
                    decoration: BoxDecoration(
                      color: message.isFromSender
                          ? (pref!
                              ? AppColors.darkcolor
                              : AppColors.buttoncolor)
                          : AppColors.whiteColor,
                      borderRadius:
                          _getBorderRadius(isRtl, message.isFromSender),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    child: Column(
                      crossAxisAlignment: isRtl
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        _buildMessageContent(
                          message.isPending,
                          message.messageType,
                          message.message,
                          message.isFromSender,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.ltr,
                          children: [
                            Text(
                              message.timestamp.toString(),
                              style: TextStyle(
                                color: message.isFromSender
                                    ? AppColors.whiteColor.withOpacity(0.85)
                                    : AppColors.blackTextColor.withOpacity(0.65),
                                fontSize: 2.5.w,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (message.isFromSender) ...[
                              SizedBox(width: 1.w),
                              _buildMessageStatusIcon(message),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (message.reaction.isNotEmpty)
                    Positioned(
                      bottom: -10,
                      right: message.isFromSender ? 8 : null,
                      left: !message.isFromSender ? 8 : null,
                      child: InkWell(
                        onTap: () =>
                            _showReactionMessageBottomSheet(context, message),
                        child: Row(
                          children: [
                            Container(
                              width: 5.7.w,
                              height: 5.7.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  message.reaction[0].react!,
                                  style: TextStyle(fontSize: 3.5.w),
                                ),
                              ),
                            ),
                            if (message.reaction.length > 1)
                              Text(
                                "+${message.reaction.length - 1}",
                                style: TextStyle(fontSize: 2.5.w),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isRtl && !message.isFromSender)
            _buildAvatar(showAvatar, false, name, img),
          if (isRtl && !message.isFromSender) SizedBox(width: 2.w),
          if (!isRtl && message.isFromSender) SizedBox(width: 2.w),
          if (!isRtl && message.isFromSender)
            _buildAvatar(showAvatar, true, name, img),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
      bool wait, String type, String content, bool isFromSender) {
    switch (type) {
      case 'text':
        return Text(
          content,
          style: TextStyle(
            color:
                isFromSender ? AppColors.whiteColor : AppColors.blackTextColor,
            fontSize: 3.w,
            fontWeight: FontWeight.w400,
          ),
        );
      case 'image':
        Widget imageWidget = content.startsWith('http')
            ? CachedNetworkImage(imageUrl: content)
            : Image.file(File(content));
        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => _showImageInScreen(imgUrl: content),
              child: imageWidget,
            ),
            if (wait) Icon(Icons.timelapse_rounded, size: 5.w),
          ],
        );
      case 'voice':
        return Stack(
          children: [
            AudioMessageWidget(
              url: content.startsWith('http') ? content : '',
              localPath: content.startsWith('http') ? null : content,
            ),
            if (wait) Icon(Icons.timelapse_rounded, size: 5.w),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _showImageInScreen({required String imgUrl}) {
    Get.defaultDialog(
      radius: 0,
      backgroundColor: AppColors.blackColor,
      title: S.of(Get.context!).imageViewerTitle,
      content: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.5,
        maxScale: 4.0,
        child: Container(
          color: AppColors.blackColor,
          height: 80.h,
          width: 100.w,
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool show, bool isSender, String name, String img) {
    print("image >>>>>>>>>>>> $img");
    return SizedBox(
      width: 10.w,
      height: 8.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: show
            ? CircleAvatar(
                radius: 4.w,
                backgroundColor:
                    isSender ? AppColors.buttoncolor : Colors.grey[300],
                backgroundImage: img.toString() != "null"
                    ? CachedNetworkImageProvider(img)
                    : null,
                child: img.toString() == "null"
                    ? Text(
                        name.isNotEmpty ? name[0] : '',
                        style: TextStyle(
                          color: isSender
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          fontSize: 3.w,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              )
            : null,
      ),
    );
  }

  BorderRadius _getBorderRadius(bool isRtl, bool isSender) {
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    if (isSender) {
      if (isFirstInGroup && isLastInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? radius : smallRadius,
          topRight: isRtl ? smallRadius : radius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      }
      if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomRight: radius,
          bottomLeft: radius,
        );
      } else if (isFirstInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? radius : smallRadius,
          topRight: isRtl ? smallRadius : radius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      } else {
        return BorderRadius.circular(12);
      }
    } else {
      if (isFirstInGroup && isLastInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? smallRadius : radius,
          topRight: isRtl ? radius : smallRadius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      }
      if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomRight: radius,
          bottomLeft: radius,
        );
      } else if (isFirstInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? smallRadius : radius,
          topRight: isRtl ? radius : smallRadius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      } else {
        return BorderRadius.circular(12);
      }
    }
  }

  Widget _buildMessageStatusIcon(ChatMessage message) {
    if (message.isPending) {
      return Icon(
        Icons.access_time_rounded,
        size: 3.2.w,
        color: Colors.white70,
      );
    } else if (message.isRead) {
      return Icon(
        Icons.done_all_rounded,
        size: 3.8.w,
        color: const Color(0xFF34B7F1), // اللون الأزرق المميز للصحين مثل الواتساب
      );
    } else {
      return Icon(
        Icons.check_rounded,
        size: 3.5.w,
        color: Colors.white70,
      );
    }
  }
}
//endregion

//region AudioMessageWidget
class AudioMessageWidget extends StatefulWidget {
  final String url;
  final String? localPath;

  const AudioMessageWidget({super.key, required this.url, this.localPath});

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  late AudioPlayer _player;
  bool isPlaying = false;
  Duration? duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      print("vvoice >>>>>>>>> ${widget.localPath}");
      print(" >>>>>>>>>");
      await _player.setLoopMode(LoopMode.off);
      if (widget.localPath != null && await File(widget.localPath!).exists()) {
        await _player.setFilePath(widget.localPath!);
      } else {
        await _player.setUrl(widget.url);
      }

      _player.durationStream.listen((d) {
        if (mounted) setState(() => duration = d ?? Duration.zero);
      });

      _player.positionStream.listen((p) {
        if (mounted) setState(() => position = p);
      });

      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              isPlaying = false;
              position = Duration.zero;
              _player.seek(Duration.zero);
              _player.stop();
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.teal,
              size: 7.w,
            ),
            onPressed: () async {
              try {
                if (isPlaying) {
                  await _player.pause();
                } else {
                  await _player.play();
                }
              } catch (e) {
                debugPrint('Error during playback: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${S.of(context).playbackError}: $e')));
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  activeColor: Colors.teal,
                  inactiveColor: Colors.grey[400],
                  value: position.inSeconds.toDouble(),
                  max: duration?.inSeconds.toDouble() ?? 1.0,
                  onChanged: (value) async {
                    await _player.seek(Duration(seconds: value.toInt()));
                    setState(() => position = Duration(seconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position),
                        style: TextStyle(
                            fontSize: 2.5.w, color: Colors.grey[700])),
                    Text(_formatDuration(duration ?? Duration.zero),
                        style: TextStyle(
                            fontSize: 2.5.w, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//endregion

void _showReactionMessageBottomSheet(
    BuildContext context, ChatMessage chatMessage) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            S.of(context).react,
            style: TextStyle(
              color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
              fontSize: 4.w,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: 100.w,
            child: ListView.separated(
              itemCount: chatMessage.reaction.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(2.w),
              itemBuilder: (context, index) => Row(
                children: [
                  Text(chatMessage.reaction[index].react!,
                      style: TextStyle(fontSize: 6.w)),
                  const SizedBox(width: 10),
                  textNormal(
                    chatMessage.reaction[index].user!.username ==
                                sharedPreferences!.getString("usernameGust") ||
                            chatMessage.reaction[index].user!.username ==
                                sharedPreferences!.getString("username")
                        ? S.of(context).you
                        : chatMessage.reaction[index].user!.username,
                    AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    ),
  );
}
