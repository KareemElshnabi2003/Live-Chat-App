import 'package:flutter/material.dart';
import 'package:live_chat/Core/function/html_decoder.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart'; // for sharedPreferences

String formatLastMessage(BuildContext context, UserChatModel chat) {
  if (chat.lastMessage == null || chat.lastMessage.toString() == "null") {
    return "${chat.membersCount ?? 0} ${S.of(context).engaged_people}";
  }

  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final isMe = chat.lastMessage!.senderId.toString() == sharedPreferences!.getString("id");
  final prefix = isMe ? "${S.of(context).you}: " : "";
  
  String msgType = chat.lastMessage!.messageType ?? "text";
  String msgContent = chat.lastMessage!.message ?? "";

  // Parse Reply or tags in text messages
  if (msgType == 'text') {
    if (msgContent.contains('|||REPLY|||')) {
      msgContent = msgContent.split('|||REPLY|||').last;
    } else {
      // If a reply message was truncated by the backend, the |||REPLY||| part might be lost, leaving only internal tags.
      if (msgContent.contains('|||MSG|||')) {
        msgContent = msgContent.split('|||MSG|||').last;
      } else if (msgContent.contains('|||IMG|||')) {
        return "$prefix${S.of(context).image}";
      } else if (msgContent.contains('|||VOICE|||')) {
        return "$prefix${S.of(context).voiceMessage}";
      } else if (msgContent.contains('|||CALL|||')) {
        return "$prefix${isRtl ? 'مكالمة' : 'Call'}";
      }
    }
    
    if (msgContent == '|||CALL_ENDED|||' || msgContent == '|||GROUP_CALL_ENDED|||' || msgContent.contains('CALL_ENDED')) {
      return "$prefix${isRtl ? "تم إنهاء المكالمة" : "Call ended"}";
    } else if (msgContent == '|||CALL_DECLINED|||' || msgContent.contains('CALL_DECLINED')) {
      return "$prefix${isRtl ? "مكالمة فائتة" : "Missed call"}";
    } else if (msgContent == '|||CALL_BUSY|||' || msgContent.contains('CALL_BUSY')) {
      return "$prefix${isRtl ? "المستخدم مشغول" : "User is busy"}";
    } else if (msgContent.startsWith('|||GROUP_CALL_START|||') || msgContent.startsWith('|||PRIVATE_CALL_START|||')) {
      return "$prefix${msgContent.contains('video') ? (isRtl ? "مكالمة فيديو" : "Video Call") : (isRtl ? "مكالمة صوتية" : "Voice Call")}";
    }
    
    return decodeHtmlEntities("$prefix$msgContent");
  } else if (msgType == 'voice') {
    return "$prefix${S.of(context).voiceMessage}";
  } else if (msgType == 'image') {
    return "$prefix${S.of(context).image}";
  } else if (msgType == 'call') {
    if (msgContent == '|||CALL_ENDED|||' || msgContent == '|||GROUP_CALL_ENDED|||' || msgContent.contains('CALL_ENDED')) {
      return "$prefix${isRtl ? "تم إنهاء المكالمة" : "Call ended"}";
    } else if (msgContent == '|||CALL_DECLINED|||' || msgContent.contains('CALL_DECLINED')) {
      return "$prefix${isRtl ? "مكالمة فائتة" : "Missed call"}";
    }
    return "$prefix${msgContent.contains('video') ? (isRtl ? "مكالمة فيديو" : "Video Call") : (isRtl ? "مكالمة صوتية" : "Voice Call")}";
  }

  return decodeHtmlEntities("$prefix$msgContent");
}
