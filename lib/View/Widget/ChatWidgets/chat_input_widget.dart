import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Widget/ChatWidgets/voice_recording_widgets.dart'; // 🌟 تأكد من استيراد ده
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
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

    if (isNotFriend && !hasLastMessage && isBlocked == "None") {
      return _buildMessageInput(context, isRequestArea: true);
    } else if (isBlocked == "You blocked them" || isBlocked == "They blocked you") {
      if (isBlocked == "You blocked them") {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              textNormal(S.of(context).msgIBlock, AppColors.blackColor, 3.5.w, FontWeight.w400),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                height: 5.h,
                decoration: BoxDecoration(color: AppColors.redColor, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textClick(S.of(context).unBlock, true, () {
                      controller.blockOrUnBlock(friendID: controller.memberIdToBlock[0].id, status: 0);
                      userChatModel.isBlocked = "None";
                    }, AppColors.whiteColor, 4.w),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return textNormal(S.of(context).msgBlockUser, AppColors.blackColor, 3.5.w, FontWeight.w400);
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: pref! ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.replyingToMessage!.senderName ?? '',
                  style: TextStyle(
                    color: pref! ? AppColors.secondaryColor : AppColors.buttoncolor, 
                    fontWeight: FontWeight.bold,
                    fontSize: 3.w
                  ),
                ),
                Builder(
                  builder: (context) {
                    String msgText = '';
                    if (controller.replyingToMessage!.messageType == 'text') {
                      msgText = controller.replyingToMessage!.message.split('|||REPLY|||').last;
                      if (msgText.startsWith('|||GROUP_CALL_START|||') || msgText.startsWith('|||PRIVATE_CALL_START|||')) {
                        final callType = msgText.contains('video') ? (isRtl ? "مكالمة فيديو" : "Video Call") : (isRtl ? "مكالمة صوتية" : "Voice Call");
                        return Row(
                          children: [
                            Icon(msgText.contains('video') ? Icons.videocam : Icons.call, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      } else if (msgText == '|||CALL_ENDED|||' || msgText == '|||GROUP_CALL_ENDED|||') {
                        final callType = isRtl ? "تم إنهاء المكالمة" : "Call ended";
                        return Row(
                          children: [
                            Icon(Icons.call_end, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      } else if (msgText == '|||CALL_DECLINED|||') {
                        final callType = isRtl ? "مكالمة فائتة" : "Missed call";
                        return Row(
                          children: [
                            Icon(Icons.phone_missed, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      }
                    } else if (controller.replyingToMessage!.messageType == 'image') {
                      return Row(
                        children: [
                          Icon(Icons.image, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                          SizedBox(width: 1.w),
                          Text(isRtl ? "صورة" : "Image", style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                        ],
                      );
                    } else if (controller.replyingToMessage!.messageType == 'voice' || controller.replyingToMessage!.messageType == 'audio') {
                      return Row(
                        children: [
                          Icon(Icons.mic, size: 4.w, color: pref! ? Colors.white70 : Colors.black54),
                          SizedBox(width: 1.w),
                          Text(isRtl ? "تسجيل صوتي" : "Voice Message", style: TextStyle(color: pref! ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                        ],
                      );
                    } else {
                      msgText = controller.replyingToMessage!.messageType;
                    }
                    
                    return Text(
                      msgText,
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
                  controller.blockOrUnBlock(friendID: controller.memberIdToBlock[0].id, status: 1);
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