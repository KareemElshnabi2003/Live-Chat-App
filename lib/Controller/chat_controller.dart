import 'dart:developer';
import 'package:live_chat/Data/Model/user_chat_model.dart';
// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:live_chat/Controller/chat_mixins/chat_audio_recording_mixin.dart';
import 'package:live_chat/Controller/chat_mixins/chat_base_controller.dart';
import 'package:live_chat/Controller/chat_mixins/chat_calls_radio_mixin.dart';
import 'package:live_chat/Controller/chat_mixins/chat_members_friendship_mixin.dart';
import 'package:live_chat/Controller/chat_mixins/chat_messages_mixin.dart';
import 'package:live_chat/Controller/chat_mixins/chat_pusher_mixin.dart';

class ChatController extends ChatBaseController
    with
        ChatAudioRecordingMixin,
        ChatCallsRadioMixin,
        ChatMembersFriendshipMixin,
        ChatMessagesMixin,
        ChatPusherMixin {

  static bool isOutgoingCallInProgress = false;
  static bool isCurrentCallPublisher = false;
  static String activeOutgoingChatId = "";

  @override
  void onInit() {
    super.onInit();
    chatId = Get.arguments?['chatId']?.toString() ?? '';
    if (Get.arguments?['userChatModel'] is UserChatModel) {
      userChatModel = Get.arguments['userChatModel'];
    }

    if (chatId.isNotEmpty) {
      if (ChatBaseController.messagesCache.containsKey(chatId) &&
          ChatBaseController.messagesCache[chatId]!.isNotEmpty) {
        messages.assignAll(ChatBaseController.messagesCache[chatId]!);
        isLoadingInitial.value = false;
      }
      initPusher();

      if (!shouldSkipInitialGetMessages) {
        getMessages();
      } else {
        log("ChatController: Non-friend chat (id: $chatId), skipping initial getMessages() until a message is sent.");
        isLoadingInitial.value = false;
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        if (isPublicChat) {
          getMemberToBlock();
          getRadios();
        }
      });
    }

    initCallsAndRadio();
  }

  @override
  void onClose() {
    if (chatId.isNotEmpty) {
      if (shouldSkipInitialGetMessages) {
        // مسح كاش الرسائل المؤقت فور الخروج إذا لم يكن صديقاً
        ChatBaseController.messagesCache.remove(chatId);
        messages.clear();
      } else if (messages.isNotEmpty) {
        ChatBaseController.messagesCache[chatId] = List.from(messages);
      }
    }
    disposeCallsAndRadio();
    messageController.dispose();
    closeRecorder();
    disconnectPusher();
    super.onClose();
  }
}
