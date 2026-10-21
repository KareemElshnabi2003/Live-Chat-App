import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_chat/Controller/audio_call_controller.dart';
import 'package:live_chat/Controller/video_call_controller.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/function/html_decoder.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/View/Widget/PublicWidget/video_call_notification.dart';
import 'package:live_chat/main.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'chat_base_controller.dart';
import 'chat_messages_mixin.dart';
import 'chat_calls_radio_mixin.dart';

mixin ChatPusherMixin on ChatBaseController, ChatMessagesMixin, ChatCallsRadioMixin {
  late PusherChannelsFlutter pusher;
  final Set<String> subscribedChannels = {};
  static bool _pusherInitialized = false;

  void disconnectPusher() {
    for (var channel in subscribedChannels) {
      pusher.unsubscribe(channelName: channel);
    }
    pusher.disconnect();
  }

  @override
  void updateCallStatusInternal() {
    updateCallActiveStatusFromMessages();
  }

  @override
  void syncReadStatusForPassedMessagesInternal() {
    syncReadStatusForPassedMessages();
  }

  @override
  void handleMessageReadInternal(dynamic eventData) {
    handleMessageReadEvent(eventData);
  }

  void initPusher() async {
    pusher = PusherChannelsFlutter.getInstance();
    if (!_pusherInitialized) {
      try {
        await pusher.init(
          apiKey: "f63bff3d533540e54682",
          cluster: "ap2",
          onEvent: (event) async {
            log("🎯 PUSHER EVENT: ${event.eventName}");

            if (!Get.isRegistered<ChatController>()) return;
            final ctrl = Get.find<ChatController>();

            dynamic eventData = {};
            if (event.data != null) {
              if (event.data is Map) {
                eventData = event.data;
              } else if (event.data.toString().isNotEmpty &&
                  event.data.toString() != "{}") {
                try {
                  eventData = jsonDecode(event.data.toString());
                  if (eventData is String) eventData = jsonDecode(eventData);
                } catch (e) {
                  log("⚠️ Pusher jsonDecode: $e");
                  eventData = {};
                }
              }
            }

            final eventNameLower = event.eventName.toLowerCase();

            if (eventNameLower.contains("read") ||
                eventNameLower.contains("seen") ||
                (eventData is Map &&
                    (eventData['status'] == 'read' ||
                        eventData['status'] == 'seen' ||
                        eventData['event']
                                ?.toString()
                                .toLowerCase()
                                .contains('read') ==
                            true ||
                        eventData['type']
                                ?.toString()
                                .toLowerCase()
                                .contains('read') ==
                            true))) {
              log("👁️ [PUSHER] Read event received: ${event.eventName} with data: $eventData");
              ctrl.handleMessageReadEvent(eventData);
            }

            try {
              if (event.eventName.contains("message-created")) {
                final msgData = eventData is Map ? eventData : {};
                if (msgData.isEmpty) return;
                final myId = sharedPreferences!.getString("id") ??
                    sharedPreferences!.getString("idGust") ??
                    "";

                bool isMe = msgData['sender_id'].toString() == myId.toString();

                if (isMe) {
                  final serverId = msgData['id']?.toString();
                  final msgText = decodeHtmlEntities(msgData['message'] ?? '');
                  final idx = ctrl.messages.indexWhere((m) =>
                      m.isFromSender &&
                      (m.messageId == serverId || (m.isPending && m.message == msgText)));
                  if (idx != -1) {
                    ctrl.messages[idx] = ctrl.messages[idx].copyWith(
                      messageId: serverId ?? ctrl.messages[idx].messageId,
                      isPending: false,
                    );
                    ctrl.messages.refresh();
                  }
                } else {
                  String messageType = msgData['message_type'] ?? 'text';
                  String messageContent = decodeHtmlEntities(msgData['message'] ?? '');

                  ChatMessage newMsg = ChatMessage(
                    senderName: msgData['sender_name'] ?? 'Unknown',
                    imageUrl: msgData['sender_image']?.toString(),
                    reaction: [],
                    message: messageContent,
                    messageType: messageType,
                    messageId: msgData['id'].toString(),
                    isPending: false,
                    isFromSender: false,
                    isRead: false,
                    timestamp: DateFormat('h:mm a').format(DateTime.now()),
                  );

                  ctrl.messages.insert(0, newMsg);
                  ctrl.syncReadStatusForPassedMessages();

                  final bool isGroup = ctrl.isGroupChat;
                  final String callerName = msgData['sender_name'] ?? 'مستخدم';
                  final String callerImg = msgData['sender_image'] ?? '';

                  if (messageContent.startsWith('|||GROUP_CALL_START|||') ||
                      messageContent.startsWith('|||PRIVATE_CALL_START|||')) {
                    final bool isAudio = messageContent.endsWith('audio');
                    ctrl.isIncomingCallActive = true;
                    ctrl.update();

                    if (ChatController.isOutgoingCallInProgress &&
                        ChatController.activeOutgoingChatId == ctrl.chatId) {
                      log("📞 Suppressing incoming call screen for active outgoing call publisher");
                      return;
                    }

                    if (!ctrl.isIncomingCallScreenShowing) {
                      ctrl.isIncomingCallScreenShowing = true;
                      Get.to(() => IncomingCallScreen(
                        callerName: callerName,
                        callerImage: callerImg,
                        groubImg: isGroup ? (ctrl.userChatModel?.image ?? '') : '',
                        groubName: isGroup ? (ctrl.userChatModel?.name ?? '') : '',
                        isVideoCall: !isAudio,
                        isGroub: isGroup,
                        onPressAnswer: () async {
                          if (Get.isRegistered<VideoCallController>()) {
                            log("🛑 Ending active video call before switching to new call");
                            await Get.find<VideoCallController>().endCall();
                            Get.delete<VideoCallController>(force: true);
                          }
                          if (Get.isRegistered<AudioCallController>()) {
                            log("🛑 Ending active audio call before switching to new call");
                            await Get.find<AudioCallController>().endCall();
                            Get.delete<AudioCallController>(force: true);
                          }

                          ctrl.isIncomingCallScreenShowing = false;
                          ctrl.audio = isAudio;
                          final myId = int.tryParse(sharedPreferences?.getString("id") ?? "0") ?? 0;
                          final myName = sharedPreferences?.getString("name") ?? "";
                          await ctrl.getTokenCall(
                            isGroub: isGroup,
                            groubUsersNames: isGroup
                                ? {
                                    myId: myName,
                                  }
                                : {},
                            usernameFriend: isGroup ? "" : callerName,
                            isJoin: true,
                          );
                        },
                        onPressReject: () {
                          ctrl.isIncomingCallScreenShowing = false;
                          ctrl.isIncomingCallActive = false;
                          ctrl.update();
                          if (!isGroup) {
                            ctrl.sendSystemMessage("|||CALL_DECLINED|||");
                          }
                        },
                      ));
                    }
                  } else if (messageContent == '|||CALL_BUSY|||') {
                    ctrl.isIncomingCallActive = false;
                    ctrl.update();
                    if (ctrl.isIncomingCallScreenShowing) {
                      ctrl.isIncomingCallScreenShowing = false;
                      Get.back();
                    }
                    if (Get.isRegistered<VideoCallController>()) {
                      final videoCtrl = Get.find<VideoCallController>();
                      videoCtrl.onBusyCall();
                    }
                    if (Get.isRegistered<AudioCallController>()) {
                      final audioCtrl = Get.find<AudioCallController>();
                      audioCtrl.onBusyCall();
                    }
                  } else if (messageContent == '|||CALL_ENDED|||' ||
                      messageContent == '|||GROUP_CALL_ENDED|||' ||
                      messageContent == '|||CALL_DECLINED|||') {
                    ctrl.isIncomingCallActive = false;
                    ctrl.update();
                    if (ctrl.isIncomingCallScreenShowing) {
                      ctrl.isIncomingCallScreenShowing = false;
                      IncomingCallScreen.isShowing = false;
                      if (Get.isDialogOpen == true) Get.back();
                      Get.back();
                      Get.snackbar(
                        "المكالمة",
                        messageContent == '|||CALL_DECLINED|||'
                            ? "تم رفض المكالمة"
                            : "تم إنهاء المكالمة",
                        backgroundColor: Colors.grey[900],
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                    if (Get.isRegistered<VideoCallController>()) {
                      final videoCtrl = Get.find<VideoCallController>();
                      videoCtrl.onRemoteEndedCall();
                    }
                    if (Get.isRegistered<AudioCallController>()) {
                      final audioCtrl = Get.find<AudioCallController>();
                      audioCtrl.onRemoteEndedCall();
                    }
                  }
                }
              }
            } catch (e) {
              log("❌ Error parsing Pusher data: $e");
            }
          },
        );
      } catch (e) {
        log("❌ Pusher init error: $e");
      }
      _pusherInitialized = true;
    }

    String targetChannel = "live-chat-ngoum-$chatId";
    if (!subscribedChannels.contains(targetChannel)) {
      await pusher.subscribe(channelName: targetChannel);
      subscribedChannels.add(targetChannel);
    }
    await pusher.connect();
  }

  void syncReadStatusForPassedMessages() {
    if (isGroupChat) return;

    int firstOtherIndex = -1;
    for (int i = 0; i < messages.length; i++) {
      if (!messages[i].isFromSender) {
        firstOtherIndex = i;
        break;
      }
    }

    if (firstOtherIndex != -1) {
      bool updated = false;
      for (int i = firstOtherIndex + 1; i < messages.length; i++) {
        if (messages[i].isFromSender && !messages[i].isRead) {
          messages[i] = messages[i].copyWith(isRead: true);
          updated = true;
        }
      }
      if (updated) {
        log("✅ [SYNC] Marked all messages older than other's reply as read (✓✓)");
        messages.refresh();
        update();
      }
    }
  }

  void handleMessageReadEvent(dynamic eventData) {
    try {
      log("👁️ [PUSHER] handleMessageReadEvent: isGroupChat=$isGroupChat, chatStatus=${userChatModel?.status}, data=$eventData");
      if (isGroupChat) {
        log("👥 [PUSHER] message-read ignored because this is a group chat");
        return;
      }

      final myId = sharedPreferences!.getString("id") ??
          sharedPreferences!.getString("idGust") ??
          "";

      dynamic effectiveData = eventData;
      if (effectiveData is Map) {
        if (effectiveData['data'] is Map) {
          effectiveData = effectiveData['data'];
        } else if (effectiveData['message'] is Map) {
          effectiveData = effectiveData['message'];
        }
      }

      if (effectiveData is Map) {
        final readerId =
            (effectiveData['reader_id'] ?? effectiveData['read_by'])?.toString();
        if (readerId != null && readerId.isNotEmpty && readerId == myId) {
          log("👁️ [PUSHER] Ignored read event because current user is the reader: $readerId");
          return;
        }
      }

      bool updated = false;
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].isFromSender && !messages[i].isRead) {
          messages[i] = messages[i].copyWith(isRead: true);
          updated = true;
        }
      }

      if (updated) {
        log("✅ [PUSHER] Successfully marked sent messages as read (✓✓)!");
        messages.refresh();
        update();
      }
    } catch (e) {
      log("❌ Error handling message-read event: $e");
    }
  }
}
