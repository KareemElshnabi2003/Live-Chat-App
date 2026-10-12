//region ChatBubbleWidget
import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/chat_controller.dart'; // added
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/View/Widget/ChatWidgets/audio_message_widget.dart';
import 'package:live_chat/View/Widget/ChatWidgets/show_reaction_message_bottom_sheet_widget.dart';
import 'package:live_chat/Core/function/html_decoder.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:swipe_to/swipe_to.dart'; // added

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final VoidCallback onLongPress;
  final String name;
  final bool pref;
  final String? img; // 🌟 التصحيح عشان الـ null

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.onLongPress,
    required this.name,
    required this.img, required this.pref,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SwipeTo(
      onRightSwipe: (details) {
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().setReply(message);
        }
      },
      onLeftSwipe: (details) {
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().setReply(message);
        }
      },
      child: Padding(
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
                            ? (pref
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
                          if (!message.isFromSender && isFirstInGroup)
                            Padding(
                              padding: EdgeInsets.only(bottom: 0.5.h),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 2.8.w,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          _buildMessageContent(
                            message.isPending,
                            message.messageType,
                            message.message,
                            message.isFromSender,
                            isRtl
                          ),
                          const SizedBox(height: 5),
                          Text(
                            message.timestamp.toString(),
                            style: TextStyle(
                              color: message.isFromSender
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              fontSize: 2.5.w,
                              fontWeight: FontWeight.w400,
                            ),
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
                              showReactionMessageBottomSheet(context, message),
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
                                    message.reaction[0].react ?? '',
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
      ),
    );
  }

  Widget _buildMessageContent(
      bool wait, String type, String content, bool isFromSender, bool isRtl) {
    switch (type) {
      case 'text':
        if (content.startsWith('|||GROUP_CALL_START|||')) {
           final callType = content.replaceAll('|||GROUP_CALL_START|||', '');
           return Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Icon(
                 callType == 'video' ? Icons.videocam : Icons.call,
                 color: isFromSender ? Colors.white : AppColors.buttoncolor,
                 size: 8.w,
               ),
               SizedBox(height: 1.h),
               Text(
                 callType == 'video' ? (isRtl ? "بدأت مكالمة فيديو" : "Video Call Started") : (isRtl ? "بدأت مكالمة صوتية" : "Voice Call Started"),
                 style: TextStyle(
                   color: isFromSender ? AppColors.whiteColor : AppColors.blackTextColor,
                   fontSize: 3.5.w,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               SizedBox(height: 1.h),
               ElevatedButton(
                 onPressed: () {
                   // This button is just decorative since tapping the notification starts the call,
                   // but users can tap it. To make it functional, we'd need ChatController access.
                   // Since we don't have direct access here easily without context lookup, 
                   // we just let it be a visual indicator. Or use Get.find<ChatController>().
                   if (Get.isRegistered<ChatController>()) {
                     final ctrl = Get.find<ChatController>();
                     ctrl.audio = callType == 'audio' || callType == 'voice';
                     ctrl.getTokenCall(
                       isGroub: true,
                       groubUsersNames: {
                         int.parse(sharedPreferences!.getString("id")!): sharedPreferences!.getString("name")!
                       },
                       usernameFriend: "",
                     );
                   }
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: isFromSender ? Colors.white : AppColors.buttoncolor,
                   foregroundColor: isFromSender ? AppColors.buttoncolor : Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                 ),
                 child: Text(S.of(Get.context!).join_now),
               )
             ]
           );
        } else if (content.startsWith('|||PRIVATE_CALL_START|||')) {
           final callType = content.replaceAll('|||PRIVATE_CALL_START|||', '');
           final text = isRtl ? 'تم بدء مكالمة' : 'Started a call';
           return Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Icon(callType == 'video' ? Icons.videocam : Icons.call, color: isFromSender ? Colors.white : AppColors.buttoncolor, size: 8.w),
               SizedBox(height: 1.h),
               Text(text, style: TextStyle(color: isFromSender ? Colors.white : AppColors.blackTextColor, fontWeight: FontWeight.bold, fontSize: 3.5.w)),
               if (!isFromSender) ...[
                 SizedBox(height: 1.h),
                 ElevatedButton(
                   onPressed: () {
                     if (Get.isRegistered<ChatController>()) {
                       final ctrl = Get.find<ChatController>();
                       ctrl.audio = callType == 'audio' || callType == 'voice';
                       ctrl.getTokenCall(
                         isGroub: false,
                         groubUsersNames: {},
                         usernameFriend: "",
                       );
                     }
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: isFromSender ? Colors.white : AppColors.buttoncolor,
                     foregroundColor: isFromSender ? AppColors.buttoncolor : Colors.white,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                   ),
                   child: Text(S.of(Get.context!).join_now),
                 ),
               ],
             ]
           );
        } else if (content == '|||CALL_DECLINED|||') {
           final text = isRtl ? 'تم رفض المكالمة' : 'Call declined';
           return Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               Icon(Icons.phone_missed, color: Colors.redAccent, size: 5.w),
               SizedBox(width: 2.w),
               Text(text, style: TextStyle(color: isFromSender ? Colors.white : AppColors.blackTextColor, fontStyle: FontStyle.italic, fontSize: 3.5.w)),
             ]
           );
        } else if (content == '|||CALL_ENDED|||' || content == '|||GROUP_CALL_ENDED|||') {
           final text = isRtl ? 'تم إنهاء المكالمة' : 'Call ended';
           return Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               Icon(Icons.call_end, color: isFromSender ? Colors.white : AppColors.buttoncolor, size: 5.w),
               SizedBox(width: 2.w),
               Text(text, style: TextStyle(color: isFromSender ? Colors.white : AppColors.blackTextColor, fontWeight: FontWeight.bold, fontSize: 3.5.w)),
             ]
           );
        } else if (content.contains('|||REPLY|||')) {
           final parts = content.split('|||REPLY|||');
           String replyText = parts.length > 1 ? parts[1] : '';
           String originalSender = '';
           String originalMessage = parts[0];
           String originalType = 'text';

           if (parts[0].contains('|||MSG|||')) {
             final subParts = parts[0].split('|||MSG|||');
             originalSender = subParts[0];
             originalMessage = subParts.length > 1 ? subParts[1] : '';
             originalType = 'text';
           } else if (parts[0].contains('|||IMG|||')) {
             final subParts = parts[0].split('|||IMG|||');
             originalSender = subParts[0];
             originalMessage = subParts.length > 1 ? subParts[1] : '';
             originalType = 'image';
           } else if (parts[0].contains('|||VOICE|||')) {
             final subParts = parts[0].split('|||VOICE|||');
             originalSender = subParts[0];
             originalMessage = subParts.length > 1 ? subParts[1] : '';
             originalType = 'voice';
           } else if (parts[0].contains('|||CALL|||')) {
             final subParts = parts[0].split('|||CALL|||');
             originalSender = subParts[0];
             originalMessage = subParts.length > 1 ? subParts[1] : '';
             originalType = 'call';
           }

           // If the original message was any call message (even if tagged as MSG), handle as call
           if (originalMessage.contains('CALL') ||
               originalMessage.startsWith('|||GROUP_CALL') ||
               originalMessage.startsWith('|||PRIVATE_CALL') ||
               originalMessage.startsWith('|||CALL_')) {
             originalType = 'call';
           }

           // Resolve whether the original message was sent by the current viewer
           final myUsername = sharedPreferences?.getString("username") ?? "";
           final myGuestName = sharedPreferences?.getString("usernameGust") ?? "";
           final myName = sharedPreferences?.getString("name") ?? "";

           bool isOriginalSenderMe = false;
           String resolvedSender = originalSender;

           if (resolvedSender.isNotEmpty) {
             if ((myUsername.isNotEmpty && resolvedSender == myUsername) ||
                 (myGuestName.isNotEmpty && resolvedSender == myGuestName) ||
                 (myName.isNotEmpty && resolvedSender == myName)) {
               isOriginalSenderMe = true;
             }

             // Backward compatibility for messages with hardcoded 'أنت' or 'You' in the database
             if (resolvedSender == 'أنت' || resolvedSender == 'You') {
               if (message.isFromSender) {
                 isOriginalSenderMe = true;
               } else {
                 isOriginalSenderMe = false;
                 resolvedSender = (message.senderName != null && message.senderName!.isNotEmpty)
                     ? message.senderName!
                     : name;
               }
             }
           }

           final displaySender = isOriginalSenderMe
               ? (Get.context != null ? S.of(Get.context!).you : S.current.you)
               : resolvedSender;

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Container(
                 padding: EdgeInsets.all(2.w),
                 margin: EdgeInsets.only(bottom: 1.h),
                 decoration: BoxDecoration(
                   color: isFromSender ? Colors.white.withOpacity(0.2) : Colors.black12,
                   borderRadius: BorderRadius.circular(8),
                    border: BorderDirectional(
                      start: BorderSide(
                        color: isFromSender ? Colors.white : AppColors.buttoncolor,
                        width: 4,
                      ),
                    ),
                  ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     if (displaySender.isNotEmpty)
                       Text(
                         displaySender,
                         style: TextStyle(
                           color: isFromSender ? Colors.white : AppColors.buttoncolor,
                           fontWeight: FontWeight.bold,
                           fontSize: 2.8.w
                         ),
                       ),
                     if (originalType == 'text')
                       Text(
                         decodeHtmlEntities(originalMessage),
                         style: TextStyle(
                           color: isFromSender ? Colors.white70 : Colors.black54, 
                           fontSize: 2.8.w
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       )
                     else if (originalType == 'image')
                       Row(
                         children: [
                           Icon(Icons.image, size: 4.w, color: isFromSender ? Colors.white70 : Colors.black54),
                           SizedBox(width: 1.w),
                           Expanded(
                             child: Text(
                               isRtl ? "صورة" : "Image",
                               style: TextStyle(color: isFromSender ? Colors.white70 : Colors.black54, fontSize: 2.8.w),
                             ),
                           ),
                           if (originalMessage.isNotEmpty)
                             ClipRRect(
                               borderRadius: BorderRadius.circular(4),
                               child: originalMessage.startsWith('http') 
                                 ? CachedNetworkImage(imageUrl: originalMessage, height: 10.w, width: 10.w, fit: BoxFit.cover) 
                                 : Image.file(File(originalMessage), height: 10.w, width: 10.w, fit: BoxFit.cover),
                             )
                         ]
                       )
                     else if (originalType == 'voice')
                       Row(
                         children: [
                           Icon(Icons.mic, size: 4.w, color: isFromSender ? Colors.white70 : Colors.black54),
                           SizedBox(width: 1.w),
                           Text(
                             isRtl ? "تسجيل صوتي" : "Voice Message",
                             style: TextStyle(color: isFromSender ? Colors.white70 : Colors.black54, fontSize: 2.8.w),
                           ),
                         ]
                       )
        
                     else if (originalType == 'call')
                       Builder(
                         builder: (context) {
                           if (originalMessage == '|||CALL_ENDED|||' || originalMessage == '|||GROUP_CALL_ENDED|||' || originalMessage.contains('CALL_ENDED')) {
                             return Row(
                               children: [
                                 Icon(Icons.call_end, size: 4.w, color: isFromSender ? Colors.white70 : Colors.black54),
                                 SizedBox(width: 1.w),
                                 Text(
                                   isRtl ? "تم إنهاء المكالمة" : "Call ended",
                                   style: TextStyle(color: isFromSender ? Colors.white70 : Colors.black54, fontSize: 2.8.w),
                                 ),
                               ]
                             );
                           } else if (originalMessage == '|||CALL_DECLINED|||' || originalMessage.contains('CALL_DECLINED')) {
                             return Row(
                               children: [
                                 Icon(Icons.phone_missed, size: 4.w, color: isFromSender ? Colors.white70 : Colors.black54),
                                 SizedBox(width: 1.w),
                                 Text(
                                   isRtl ? "مكالمة فائتة" : "Missed call",
                                   style: TextStyle(color: isFromSender ? Colors.white70 : Colors.black54, fontSize: 2.8.w),
                                 ),
                               ]
                             );
                           } else {
                             return Row(
                               children: [
                                 Icon(originalMessage.contains('video') ? Icons.videocam : Icons.call, size: 4.w, color: isFromSender ? Colors.white70 : Colors.black54),
                                 SizedBox(width: 1.w),
                                 Text(
                                   originalMessage.contains('video') ? (isRtl ? "مكالمة فيديو" : "Video Call") : (isRtl ? "مكالمة صوتية" : "Voice Call"),
                                   style: TextStyle(color: isFromSender ? Colors.white70 : Colors.black54, fontSize: 2.8.w),
                                 ),
                               ]
                             );
                           }
                         }
                       )
                   ],
                 ),
               ),
               Text(
                 decodeHtmlEntities(replyText),
                 style: TextStyle(
                   color: isFromSender ? AppColors.whiteColor : AppColors.blackTextColor,
                   fontSize: 3.w,
                   fontWeight: FontWeight.w400,
                 ),
               ),
             ]
           );
        }
        return Text(
          decodeHtmlEntities(content),
          style: TextStyle(
            color:
            isFromSender ? AppColors.whiteColor : AppColors.blackTextColor,
            fontSize: 3.w,
            fontWeight: FontWeight.w400,
          ),
        );
      case 'image':
        final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
        Widget imageWidget = content.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: content,
                memCacheWidth: 600,
                memCacheHeight: 600,
                placeholder: (context, url) => Container(
                  height: 150,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 140,
                  width: 200,
                  decoration: BoxDecoration(
                    color: isFromSender
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFromSender ? Colors.white24 : Colors.black12,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 32,
                          color: isFromSender ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isRtl ? "تعذر تحميل الصورة" : "Failed to load image",
                          style: TextStyle(
                            fontSize: 2.8.w,
                            color:
                                isFromSender ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Image.file(
                File(content),
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  width: 200,
                  decoration: BoxDecoration(
                    color: isFromSender
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 32,
                      color: isFromSender ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              );
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
              pref: pref,


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
    final isRtl = Directionality.of(Get.context!) == TextDirection.rtl;
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
          height: 70.h,
          width: 100.w,
          child: imgUrl.startsWith('http') 
              ? CachedNetworkImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.white54,
                          size: 50,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isRtl
                              ? "تعذر تحميل الصورة من السيرفر (403)"
                              : "Image could not be loaded",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Image.file(
                  File(imgUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool show, bool isSender, String name, String? img) {
    bool hasValidImage = img != null &&
        img.trim().isNotEmpty &&
        img.trim() != "null" &&
        img.trim() != "image" &&
        img.trim().startsWith('http');

    if (!show) {
      return SizedBox(width: 10.w, height: 8.w);
    }

    return SizedBox(
      width: 10.w,
      height: 8.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: ClipOval(
          child: SizedBox(
            width: 8.w,
            height: 8.w,
            child: hasValidImage
                ? CachedNetworkImage(
                    imageUrl: img.trim(),
                    memCacheWidth: 80,
                    memCacheHeight: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isSender ? AppColors.buttoncolor : Colors.grey[300],
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '',
                          style: TextStyle(
                            color: isSender
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            fontSize: 3.w,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isSender ? AppColors.buttoncolor : Colors.grey[300],
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '',
                          style: TextStyle(
                            color: isSender
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            fontSize: 3.w,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: isSender ? AppColors.buttoncolor : Colors.grey[300],
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '',
                        style: TextStyle(
                          color: isSender
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                          fontSize: 3.w,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
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
}
//endregion