import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/function/html_decoder.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Widget/ChatWidgets/voice_recording_widgets.dart'; // 🌟 تأكد من استيراد ده
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/unblock_friend_dialog.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class ChatInputWidget extends StatelessWidget {
  final ChatController controller;
  final UserChatModel userChatModel;
  final bool isRtl;
  final VoidCallback onScrollToBottom;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.userChatModel,
    required this.isRtl,
    required this.onScrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = userChatModel.isBlocked;
    final isNotFriend = userChatModel.status == "Not Friend";
    final hasLastMessage = userChatModel.lastMessage != null;
    bool answer = controller.answer;

    final bool isBlockedByMe = isBlocked == "You blocked them";
    final bool isBlockedByThem = isBlocked == "They blocked you";
    final bool isGeneralBlocked = isBlockedByMe || isBlockedByThem || isBlocked == "blocked";

    if (isNotFriend && !hasLastMessage && (isBlocked == "None" || isBlocked == null)) {
      return _buildMessageInput(context, isRequestArea: true);
    } else if (isGeneralBlocked) {
      if (isBlockedByMe || isBlocked == "blocked") {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 4.w, color: pref! ? const Color(0xFFE57373) : const Color(0xFFB54231)),
                  SizedBox(width: 2.w),
                  textNormal(
                    S.of(context).msgIBlock,
                    pref! ? AppColors.whiteColor : AppColors.blackColor,
                    3.5.w,
                    FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Container(
                width: double.infinity,
                height: 5.h,
                decoration: BoxDecoration(
                  color: pref! ? const Color(0xFFE57373) : const Color(0xFFB54231),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    final friendId = controller.memberIdToBlock.isNotEmpty
                        ? controller.memberIdToBlock[0].id
                        : (userChatModel.user?.id ?? userChatModel.userId ?? 0);
                    final success = await controller.blockOrUnBlock(friendID: friendId, status: 0);
                    if (success) {
                      userChatModel.isBlocked = "None";
                      userChatModel.status = "Not Friend";
                      controller.update();
                      if (context.mounted) {
                        showUnblockFriendDialog(
                          context: context,
                          friendId: friendId,
                          onSendRequest: () async {
                            final reqSuccess = await controller.sendFriendRequest(friendID: friendId);
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
                  },
                  child: Center(
                    child: textNormal(
                      S.of(context).unBlock,
                      AppColors.whiteColor,
                      3.8.w,
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: pref! ? AppColors.darkcolor : const Color(0xFFF0EAE8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: pref! ? const Color(0xFFE57373).withOpacity(0.3) : const Color(0xFFB54231).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 4.w, color: pref! ? const Color(0xFFE57373) : const Color(0xFFB54231)),
              SizedBox(width: 2.w),
              textNormal(
                S.of(context).msgBlockUser,
                pref! ? AppColors.whiteColor : AppColors.blackColor,
                3.5.w,
                FontWeight.w500,
              ),
            ],
          ),
        );
      }
    } else if (isNotFriend && hasLastMessage && isBlocked == "None" && answer == false && userChatModel.user!.id.toString() != sharedPreferences!.getString('id')) {
      return _buildAcceptOrCancelArea(context);
    } else {
      return _buildMessageInput(context);
    }
  }

  Widget _buildMessageInput(BuildContext context, {bool isRequestArea = false}) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.replyingToMessage != null) _buildReplyPreview(context),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: .5.h),
            child: Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (!controller.isRecording)
                  GestureDetector(
                    onTap: () async {
                      await controller.sendImageMessage();
                      Future.delayed(const Duration(milliseconds: 100), onScrollToBottom);
                    },
                    child: Icon(IconsaxPlusLinear.gallery, size: 6.w, color: pref! ? AppColors.secondaryColor : AppColors.blackTextColor),
                  ),
                SizedBox(width: 2.w),
                _buildVoiceRecordingSection(),
                if (!controller.isRecording) ...[
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: pref! ? AppColors.whiteColor : AppColors.blackTextColor, fontSize: 3.5.w, fontWeight: FontWeight.w400),
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: S.of(context).sendYourMessage,
                        hintStyle: TextStyle(color: pref! ? AppColors.inActiveColor : AppColors.black2TextColor, fontSize: 3.5.w, fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 11.w,
                      height: 5.h,
                      decoration: ShapeDecoration(
                        color: pref! ? AppColors.secondaryColor : AppColors.buttoncolor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Center(
                        child: Icon(IconsaxPlusLinear.send_2, size: 4.w, color: pref! ? AppColors.blackColor : AppColors.whiteColor),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    final repMsg = controller.replyingToMessage!;
    final myUsername = sharedPreferences?.getString("username") ?? "";
    final myGuestName = sharedPreferences?.getString("usernameGust") ?? "";
    final myName = sharedPreferences?.getString("name") ?? "";

    final isMe = repMsg.isFromSender ||
        (myUsername.isNotEmpty && repMsg.senderName == myUsername) ||
        (myGuestName.isNotEmpty && repMsg.senderName == myGuestName) ||
        (myName.isNotEmpty && repMsg.senderName == myName);

    final senderDisplayName = isMe ? S.of(context).you : (repMsg.senderName ?? '');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: pref! ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: BorderDirectional(
          start: BorderSide(
            color: pref! ? AppColors.secondaryColor : AppColors.buttoncolor,
            width: 4,
          ),
        ),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderDisplayName,
                  style: TextStyle(
                    color: pref! ? AppColors.secondaryColor : AppColors.buttoncolor, 
                    fontWeight: FontWeight.bold,
                    fontSize: 3.w
                  ),
                ),
                Builder(
                  builder: (context) {
                    String msgText = '';
                    if (repMsg.messageType == 'text') {
                      msgText = repMsg.message.split('|||REPLY|||').last;
                      if (msgText.contains('|||MSG|||')) {
                        msgText = msgText.split('|||MSG|||').last;
                      }
                      if (msgText.contains('|||CALL|||')) {
                        msgText = msgText.split('|||CALL|||').last;
                      }

                      if (msgText.startsWith('|||GROUP_CALL_START|||') || msgText.startsWith('|||PRIVATE_CALL_START|||')) {
                        final callType = msgText.contains('video') ? (isRtl ? "مكالمة فيديو" : "Video Call") : (isRtl ? "مكالمة صوتية" : "Voice Call");
                        return Row(
                          children: [
                            Icon(msgText.contains('video') ? Icons.videocam : Icons.call, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      } else if (msgText == '|||CALL_ENDED|||' || msgText == '|||GROUP_CALL_ENDED|||' || msgText.contains('CALL_ENDED')) {
                        final callType = isRtl ? "تم إنهاء المكالمة" : "Call ended";
                        return Row(
                          children: [
                            Icon(Icons.call_end, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      } else if (msgText == '|||CALL_DECLINED|||' || msgText.contains('CALL_DECLINED')) {
                        final callType = isRtl ? "مكالمة فائتة" : "Missed call";
                        return Row(
                          children: [
                            Icon(Icons.phone_missed, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      } else if (msgText == '|||CALL_BUSY|||' || msgText.contains('CALL_BUSY')) {
                        final callType = isRtl ? "المستخدم مشغول" : "User is busy";
                        return Row(
                          children: [
                            Icon(Icons.phone_paused, size: 4.w, color: Colors.orangeAccent),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      }
                    } else if (repMsg.messageType == 'image') {
                      return Row(
                        children: [
                          Icon(Icons.image, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                          SizedBox(width: 1.w),
                          Text(isRtl ? "صورة" : "Image", style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                        ],
                      );
                    } else if (repMsg.messageType == 'voice' || repMsg.messageType == 'audio') {
                      return Row(
                        children: [
                          Icon(Icons.mic, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                          SizedBox(width: 1.w),
                          Text(isRtl ? "تسجيل صوتي" : "Voice Message", style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                        ],
                      );
                    } else {
                      msgText = repMsg.messageType;
                    }
                    
                    return Text(
                      decodeHtmlEntities(msgText),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: pref! ? Colors.white70 : Colors.black54,
                        fontSize: 3.w
                      ),
                    );
                  }
                )
              ]
            )
          ),
          InkWell(
            onTap: () => controller.cancelReply(),
            child: Icon(Icons.close, size: 5.w, color: pref! ? Colors.white54 : Colors.black54),
          )
        ]
      )
    );
  }

  Widget _buildVoiceRecordingSection() {
    if (controller.isRecording) {
      return Expanded(
        child: EnhancedVoiceRecording(
          pref: pref!,
          isRecording: controller.isRecording,
          isPaused: controller.isRecordingPaused,
          onStartRecording: controller.startRecording,
          onStopRecording: () async {
            await controller.stopRecording();
            Future.delayed(const Duration(milliseconds: 100), onScrollToBottom);
          },
          onCancelRecording: controller.cancelRecording,
          onPauseRecording: controller.pauseRecording,
          onResumeRecording: controller.resumeRecording,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => controller.startRecording(),
        child: Icon(IconsaxPlusLinear.microphone, color: pref! ? AppColors.secondaryColor : AppColors.blackTextColor, size: 6.w),
      );
    }
  }

  void _sendMessage() {
    controller.sendTextMessage();
    Future.delayed(const Duration(milliseconds: 100), onScrollToBottom);
  }

  Widget _buildAcceptOrCancelArea(BuildContext context) {
    return Container(
      width: 80.w,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(border: Border.all(color: AppColors.primaryColor), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          textNormal(S.of(context).wantToSendMsg, AppColors.blackTextColor, 3.5.w, FontWeight.w500),
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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryColor)),
                  child: Row(children: [Icon(Icons.check, color: AppColors.primaryColor, size: 5.w), textNormal("  ${S.of(context).accept}", AppColors.primaryColor, 4.w, FontWeight.w400)]),
                ),
              ),
              InkWell(
                onTap: () {
                  final friendId = controller.memberIdToBlock.isNotEmpty
                      ? controller.memberIdToBlock[0].id
                      : (userChatModel.user?.id ?? 0);
                  controller.blockOrUnBlock(friendID: friendId, status: 1);
                  userChatModel.isBlocked = "You blocked them";
                  controller.update();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.redColor)),
                  child: textNormal("X ${S.of(context).cancel}", AppColors.redColor, 4.w, FontWeight.w400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}