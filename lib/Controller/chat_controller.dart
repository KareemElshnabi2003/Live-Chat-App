// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/Controller/create_chat_controller.dart';
import 'package:live_chat/Controller/video_call_controller.dart';
import 'package:live_chat/Controller/audio_call_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/DataSource/radio_remote_data.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/Data/Model/member_of_chat_model.dart';
import 'package:live_chat/Data/Model/message_model.dart';
import 'package:live_chat/Data/Model/radio_model.dart';
import 'package:live_chat/Data/Model/token_call_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/Core/Class/dynamic_link_service.dart';
import 'package:live_chat/View/Screens/create%20chat/audio_call_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/create%20chat/video_call_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/video_call_notification.dart';
import 'package:live_chat/Core/function/html_decoder.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  CreateChatController get createChatController => Get.put(CreateChatController());
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());
  final RadioRemoteData _radioRemoteData =
      RadioRemoteData(api: Get.find<Api>());

  bool isRecordingPaused = false;
  late PusherChannelsFlutter pusher;
  final Set<String> subscribedChannels = {};
  FlutterSoundRecorder? _recorder;
  bool isRecording = false;
  static bool _pusherInitialized = false;
  String? currentlyPlaying;
  StatuesRequest statuesRequest = StatuesRequest.none;
  MessageModel? messageModel;
  List<MessageModel> messagesApi = [];
  String chatId = '';
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreMessages = true;
  bool audio = false;
  bool isIncomingCallScreenShowing = false;
  bool isIncomingCallActive = false;
  bool isImagePickerActive = false;
  TokenCallModel? tokenCallModel;

  bool isPublicChat = true; // 🌟 هيتحدد من الشاشة
  UserChatModel? userChatModel;

  late final AudioPlayer audioPlayer;
  bool music1 = false, music2 = false, music3 = false;
  List<RadioModel> radios = [];
  StatuesRequest radioStatusRequest = StatuesRequest.none;
  int? currentRadioIndex;
  bool isRadioPlaying = false;

  final TextEditingController messageController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  bool answer = true;

  ChatMessage? replyingToMessage;

  void setReply(ChatMessage message) {
    replyingToMessage = message;
    update();
  }

  void cancelReply() {
    replyingToMessage = null;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    // 🌟 حماية من الكراش لو الـ Get.arguments فاضي بالصدفة
    chatId = Get.arguments?['chatId']?.toString() ?? '';

    if (chatId.isNotEmpty) {
      initPusher();
      getMessages(); // تحميل الرسائل فوراً لسرعة العرض

      // تأخير طلبات الـ API غير الأساسية لتسريع فتح الشاشة
      Future.delayed(const Duration(milliseconds: 500), () {
        if (isPublicChat) { // 🌟 منع استدعاء الـ APIs دي في الشات الخاص
          getMemberToBlock();
          getRadios();
        }
      });
    }

    audioPlayer = AudioPlayer();
    _recorder = FlutterSoundRecorder();
    _initRecorder(); // نقلناها لدالة منفصلة لأمان التهيئة
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder!.openRecorder();
    } catch (e) {
      log("Error opening recorder: $e");
    }
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

            if (event.data.toString() == "{}" || event.data == null) return;

            try {
              var eventData = jsonDecode(event.data.toString());
              if (eventData is String) eventData = jsonDecode(eventData);

              if (event.eventName.contains("message-created")) {
                final msgData = eventData;
                final myId = sharedPreferences!.getString("id") ??
                    sharedPreferences!.getString("idGust") ??
                    "";

                bool isMe = msgData['sender_id'].toString() == myId.toString();

                if (!isMe) {
                  String messageType = msgData['message_type'] ?? 'text';
                  String messageContent = decodeHtmlEntities(msgData['message'] ?? '');

                  ChatMessage newMsg = ChatMessage(
                    senderName: msgData['sender_name'] ?? 'Unknown',
                    imageUrl: msgData['sender_image']
                        ?.toString(), // شيلنا كلمة "null" هنا وبنبعتها null صريحة
                    reaction: [],
                    message: messageContent,
                    messageType: messageType,
                    messageId: msgData['id'].toString(),
                    isPending: false,
                    isFromSender: false,
                    timestamp: DateFormat('h:mm a').format(DateTime.now()),
                  );

                  // 🌟 تحسين الأداء: الإضافة والـ Refresh في خطوة واحدة
                  ctrl.messages.insert(0, newMsg);

                  // 🔔 Handle incoming call via Pusher in real-time
                  if (messageContent.startsWith('|||PRIVATE_CALL_START|||') ||
                      messageContent.startsWith('|||GROUP_CALL_START|||')) {
                    final bool isAlreadyInCall = Get.isRegistered<VideoCallController>() ||
                        Get.isRegistered<AudioCallController>();
                    String currentCallChatId = VideoCallController.chatId.isNotEmpty
                        ? VideoCallController.chatId
                        : AudioCallController.chatId;

                    // إذا كان المستخدم في نفس هذه المكالمة بالفعل، نتجاهل إشعار البدء المكرر
                    if (isAlreadyInCall && currentCallChatId == ctrl.chatId.toString()) {
                      log("🔇 [PUSHER] Already in this active call, ignoring duplicate start message");
                      return;
                    }

                    if (!ctrl.isIncomingCallScreenShowing && !IncomingCallScreen.isShowing) {
                      ctrl.isIncomingCallActive = true;
                      ctrl.update();
                      ctrl.isIncomingCallScreenShowing = true;
                      bool isGroup = messageContent.startsWith('|||GROUP_CALL_START|||');
                      String callType = messageContent
                          .replaceAll('|||PRIVATE_CALL_START|||', '')
                          .replaceAll('|||GROUP_CALL_START|||', '');
                      bool isAudio = callType == 'audio' || callType == 'voice';
                      String callerName = msgData['sender_name'] ?? 'Unknown';
                      String callerImage = (msgData['sender_image'] ?? '').toString();

                      Get.to(() => IncomingCallScreen(
                        callerName: callerName,
                        callerImage: callerImage,
                        groubImg: isGroup ? (ctrl.userChatModel?.image ?? '') : '',
                        groubName: isGroup ? (ctrl.userChatModel?.name ?? '') : '',
                        isVideoCall: !isAudio,
                        isGroub: isGroup,
                        onPressAnswer: () async {
                          // 🌟 إذا كان المستخدم في مكالمة جارية بالفعل، ننهيها أولاً قبل الانتقال للمكالمة الجديدة
                          if (Get.isRegistered<VideoCallController>()) {
                            log("🔚 Ending active video call before switching to new call");
                            await Get.find<VideoCallController>().endCall();
                            Get.delete<VideoCallController>(force: true);
                          }
                          if (Get.isRegistered<AudioCallController>()) {
                            log("🔚 Ending active audio call before switching to new call");
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
                            isJoin: true, // 🌟 Callee answers as subscriber
                          );
                        },
                        onPressReject: () {
                          ctrl.isIncomingCallScreenShowing = false;
                          ctrl.isIncomingCallActive = false;
                          ctrl.update();
                          // 🌟 فقط في المكالمات الفردية نرسل إشعار الرفض للمتصل، في الجروب الرفض فردي ولا ينهي المكالمة
                          if (!isGroup) {
                            ctrl.sendSystemMessage("|||CALL_DECLINED|||");
                          }
                        },
                      ))?.then((_) {
                        ctrl.isIncomingCallScreenShowing = false;
                      });
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
                    } else {
                      // 🌟 إغلاق شاشة المكالمة للمشترك إذا كان المتصل هو من أنهى المكالمة
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

  call(
      {required bool isGroub,
      required type,
      required Map<int, String> groubUsersNames,
      required usernameFriend}) async {
    statuesRequest = StatuesRequest.loading;
    update();

    try {
      var response = await _chatsRemoteData.getTokenCall(
          callType: audio ? "audio" : "video",
          isGroub: isGroub,
          role: type,
          chatId: int.parse(chatId));

      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        final responseBody = response['data'];
        if (responseBody != null) {
          tokenCallModel = TokenCallModel.fromJson(responseBody);

          final bool isCaller = (type == 'publisher');
          final callArgs = {
            "ChannelName": tokenCallModel!.channel,
            "Token": tokenCallModel!.token,
            "UId": tokenCallModel!.uid,
            "IsGroupCall": isGroub,
            "chatId": chatId,
            "RemoteUserName": usernameFriend,
            "UserNamesMap": groubUsersNames,
            "LocalUserName": sharedPreferences!.getString("name") ?? "",
            "isCaller": isCaller,
          };

          // 🌟 إرسال رسائل التتبع للمكالمات: فقط من أنشأ المكالمة هو من يرسل رسالة البدء
          if (isCaller) {
            if (isGroub) {
              messageController.text =
                  "|||GROUP_CALL_START|||${audio ? 'audio' : 'video'}";
              sendTextMessage();
            } else {
              messageController.text =
                  "|||PRIVATE_CALL_START|||${audio ? 'audio' : 'video'}";
              sendTextMessage();
            }
          }

          // Reset status before navigating so chat is clean when user returns
          statuesRequest = StatuesRequest.none;
          update();

          audio
              ? Get.to(() => const AudioCallPage(), arguments: callArgs)
              : Get.to(() => const VideoCallPage(), arguments: callArgs);
          return;
        } else {
          showUserFriendlyError(StatuesRequest.serverError);
        }
      } else {
        showUserFriendlyError(statuesRequest);
      }
    } catch (e) {
      log("❌ Exception in call(): $e");
      Get.snackbar("خطأ", "تعذر الاتصال بسيرفر المكالمات",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      statuesRequest = StatuesRequest.none;
      update();
    }
  }

  checkCall(
      {required bool isGroub,
      required Map<int, String>? groubUsersNames,
      required usernameFriend,
      bool isJoin = false}) async {
    if (statuesRequest == StatuesRequest.loading) return;
    statuesRequest = StatuesRequest.loading;
    update();

    try {
      var response = await _chatsRemoteData.checkCall(id: chatId);
      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        final responseBody = response['data'];
        if (responseBody != null) {
          final rawStatus = responseBody['status'];
          bool isActive = false;
          if (rawStatus is num) {
            isActive = rawStatus != 0;
          } else if (rawStatus is bool) {
            isActive = rawStatus;
          } else if (rawStatus != null) {
            final s = rawStatus.toString().trim().toLowerCase();
            isActive = s == "active" || s == "1" || s == "true";
          }

          if (isJoin && !isActive) {
            Get.snackbar(
              "تنبيه",
              "المكالمة غير نشطة أو قد انتهت بالفعل.",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }

          // 🌟 إذا كانت هناك مكالمة جارية بالفعل وضغط المستخدم على أيقونة الاتصال، ينضم إليها كمشترك ولا ينشئ مكالمة جديدة
          if (!isJoin && isActive) {
            Get.snackbar(
              "تنبيه",
              isGroub
                  ? "يوجد مكالمة جماعية جارية بالفعل، جاري الانضمام إليها..."
                  : "يوجد مكالمة جارية بالفعل مع هذا الشخص، جاري الانضمام إليها...",
              backgroundColor: Colors.blueGrey,
              colorText: Colors.white,
            );
          }

          String type = (isJoin || isActive) ? "subscriber" : "publisher";

          // Check if there is an active call of a different type
          if (isActive && responseBody['call_type'] != null) {
            String activeCallType = responseBody['call_type'].toString();
            bool activeIsAudio =
                activeCallType == 'audio' || activeCallType == 'voice';

            if (audio != activeIsAudio) {
              Get.snackbar(
                "تنبيه",
                "المكالمة الجارية هي مكالمة ${activeIsAudio ? 'صوتية' : 'فيديو'}. تم تحويلك إليها.",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              audio = activeIsAudio;
            }
          }

          await call(
              isGroub: isGroub,
              type: type,
              groubUsersNames: groubUsersNames ?? {},
              usernameFriend: usernameFriend);
          return;
        } else {
          showUserFriendlyError(StatuesRequest.serverError);
        }
      } else {
        showUserFriendlyError(statuesRequest);
      }
    } catch (e) {
      log("❌ Exception in checkCall(): $e");
      Get.snackbar("خطأ", "تعذر التحقق من حالة المكالمة",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      statuesRequest = StatuesRequest.none;
      update();
    }
  }

  getTokenCall(
      {required bool isGroub,
      required Map<int, String> groubUsersNames,
      required usernameFriend,
      bool isJoin = false}) async {
    await checkCall(
        isGroub: isGroub,
        groubUsersNames: groubUsersNames,
        usernameFriend: usernameFriend,
        isJoin: isJoin);
  }

  Future<void> getMessages({int page = 1}) async {
    if (isLoadingMore || !hasMoreMessages) return;
    if (page > 1) isLoadingMore = true;
    update();

    var response = await _chatsRemoteData.getMessages(
      idChat: chatId,
      page: page,
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      List responseBody = response['data'];
      if (responseBody.isEmpty) {
        hasMoreMessages = false;
      } else {
        List<MessageModel> newMessages =
            responseBody.map((e) => MessageModel.fromJson(e)).toList();
        if (page == 1) messagesApi.clear();
        messagesApi.addAll(newMessages);

        final myIdStr = sharedPreferences!.getString("id");
        List answers = messagesApi
            .where((element) => element.senderId.toString() == myIdStr)
            .toList();
        answer = answers.isNotEmpty;

        List<ChatMessage> newChatMessages = newMessages.map((e) {
          String messageType = e.messageType ?? 'text';
          bool isMe = myIdStr == "null"
              ? "${e.senderId}" ==
                  sharedPreferences!.getString("idGust").toString()
              : "${e.senderId}" == myIdStr.toString();

          return ChatMessage(
            senderName: e.senderName ?? 'Unknown',
            imageUrl: e.senderImage, // خليتها null صريحة من غير "null"
            reaction: e.messageReactions ?? [],
            message: decodeHtmlEntities(e.message ?? ''),
            messageType: messageType,
            messageId: e.id.toString(),
            isPending: false,
            isFromSender: isMe,
            timestamp:
                DateFormat('h:mm a').format(DateTime.parse(e.createdAt!)),
          );
        }).toList();

        if (page == 1) {
          messages
              .assignAll(newChatMessages); // 🌟 أسرع بكتير من clear ثم addAll
          _updateCallActiveStatus();
        } else {
          messages.addAll(newChatMessages);
        }
        currentPage = page;
      }
    } else {
      hasMoreMessages = false;
      showUserFriendlyError(statuesRequest);
    }
    isLoadingMore = false;
    update();
  }

  void _updateCallActiveStatus() {
    isIncomingCallActive = false;
    for (var msg in messages) {
      final content = msg.message;
      if (content == '|||CALL_ENDED|||' ||
          content == '|||GROUP_CALL_ENDED|||' ||
          content == '|||CALL_DECLINED|||' ||
          content == '|||CALL_BUSY|||') {
        isIncomingCallActive = false;
        break;
      }
      if (content.startsWith('|||PRIVATE_CALL_START|||') ||
          content.startsWith('|||GROUP_CALL_START|||')) {
        isIncomingCallActive = !msg.isFromSender;
        break;
      }
    }
  }

  Future<void> loadMoreMessages() async {
    if (!hasMoreMessages || isLoadingMore) return;
    await getMessages(page: currentPage + 1);
  }

  Future<void> sendMessage(
      {String? text,
      File? imgFile,
      File? audioFile,
      required String messageType,
      String? tempId}) async {
    dynamic response;
    if (imgFile != null || audioFile != null) {
      response = await _chatsRemoteData.sendMessagesWithFile(
        chatId: chatId,
        audio: audioFile,
        image: imgFile,
      );
    } else {
      response = await _chatsRemoteData.sendMessages(
        chatId: chatId,
        message: text ?? '',
      );
    }

    statuesRequest = handlingData(response);
    if (statuesRequest == StatuesRequest.success) {
      if (response['code'] == 403) {
        messageError(
            S.of(Get.context!).warning, S.of(Get.context!).waitForAccept);
      } else {
        // تحديث بيانات الـ Gust لو فاضية
        if (sharedPreferences!.getString("id").toString() == "null" &&
            sharedPreferences!.getString("idGust").toString() == "null") {
          sharedPreferences!
              .setString("idGust", response['data']['sender_id'].toString());
        }
        if (sharedPreferences!.getString("username").toString() == "null" &&
            sharedPreferences!.getString("usernameGust").toString() == "null") {
          sharedPreferences!.setString(
              "usernameGust", response['data']['sender_name'].toString());
        }

        int indexToUpdate =
            messages.indexWhere((msg) => msg.messageId == tempId);
        if (indexToUpdate != -1) {
          messages[indexToUpdate] = ChatMessage(
            imageUrl: messages[indexToUpdate].imageUrl ??
                response['data']['sender_image'],
            senderName: messages[indexToUpdate].senderName!.isEmpty
                ? response['data']['sender_name']
                : messages[indexToUpdate].senderName,
            reaction: messages[indexToUpdate].reaction,
            message: response['data']['message'] ?? '',
            messageType: response['data']['message_type'] ?? messageType,
            messageId: response['data']['id'].toString(),
            isFromSender: true,
            isPending: false,
            timestamp: messages[indexToUpdate].timestamp,
          );
        }
      }
    } else if (statuesRequest == StatuesRequest.forbiddenException) {
      messageError(S.of(Get.context!).warning, S.of(Get.context!).waitAccept);
      messages.removeWhere((msg) => msg.messageId == tempId);
    } else {
      messages.removeWhere((msg) => msg.messageId == tempId);
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  Future<void> sendSystemMessage(String finalMessage) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    messages.insert(
        0,
        ChatMessage(
          imageUrl: null,
          reaction: [],
          senderName: sharedPreferences!.getString("username") ??
              sharedPreferences!.getString("usernameGust") ??
              "",
          message: finalMessage,
          messageType: 'text',
          messageId: tempId,
          isFromSender: true,
          isPending: true,
          timestamp: DateFormat('h:mm a').format(DateTime.now()),
        ));
    update();

    statuesRequest = StatuesRequest.loading;
    var response = await _chatsRemoteData.sendMessages(
        chatId: chatId, message: finalMessage);

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      log('✅ System message sent: $finalMessage');
      int indexToUpdate = messages.indexWhere((msg) => msg.messageId == tempId);
      if (indexToUpdate != -1) {
        messages[indexToUpdate] = ChatMessage(
          imageUrl: messages[indexToUpdate].imageUrl,
          senderName: messages[indexToUpdate].senderName,
          reaction: messages[indexToUpdate].reaction,
          message: messages[indexToUpdate].message,
          messageType: messages[indexToUpdate].messageType,
          messageId: response['data']['id']?.toString() ?? tempId,
          isFromSender: true,
          isPending: false,
          timestamp: messages[indexToUpdate].timestamp,
        );
      }
    } else {
      messages.removeWhere((msg) => msg.messageId == tempId);
    }
    update();
  }

  Future<void> sendTextMessage() async {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      String finalMessage = text;
      if (replyingToMessage != null) {
        String msgContent = replyingToMessage!.message;
        String msgType = replyingToMessage!.messageType;
        
        if (msgContent.contains('|||REPLY|||')) {
           msgContent = msgContent.split('|||REPLY|||').last;
        }
        final myName = sharedPreferences!.getString("username") ?? sharedPreferences!.getString("usernameGust") ?? "";
        String senderNameForReply = (replyingToMessage!.senderName != null && replyingToMessage!.senderName!.isNotEmpty)
            ? replyingToMessage!.senderName!
            : (myName.isNotEmpty ? myName : "Unknown");
        
        String tag = 'MSG';
        if (msgType == 'image') tag = 'IMG';
        if (msgType == 'voice' || msgType == 'audio') tag = 'VOICE';
        if (msgType == 'call' ||
            (msgType == 'text' &&
                (msgContent.contains('CALL') ||
                    msgContent.startsWith('|||GROUP_CALL') ||
                    msgContent.startsWith('|||PRIVATE_CALL') ||
                    msgContent.startsWith('|||CALL_')))) {
          tag = 'CALL';
        }
        
        finalMessage = "$senderNameForReply|||$tag|||$msgContent|||REPLY|||$text";
      }

      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      messageController.clear();
      cancelReply();

      messages.insert(
          0,
          ChatMessage(
            imageUrl: null,
            reaction: [],
            senderName: sharedPreferences!.getString("username") ??
                sharedPreferences!.getString("usernameGust") ??
                "",
            message: finalMessage,
            messageType: 'text',
            messageId: tempId,
            isFromSender: true,
            isPending:
                true, // خلينا الـ text كمان Pending لحد ما يتبعت عشان الـ UI
            timestamp: DateFormat('h:mm a').format(DateTime.now()),
          ));

      await sendMessage(
          text: finalMessage, messageType: 'text', tempId: tempId);
    }
  }

  Future<void> sendImageMessage() async {
    if (isImagePickerActive) return;
    isImagePickerActive = true;
    update();

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70);
          
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();

        messages.insert(
            0,
            ChatMessage(
              imageUrl: null,
              reaction: [],
              senderName: sharedPreferences!.getString("username") ??
                  sharedPreferences!.getString("usernameGust") ??
                  "",
              message: file.path,
              messageType: 'image',
              messageId: tempId,
              isFromSender: true,
              isPending: true,
              timestamp: DateFormat('h:mm a').format(DateTime.now()),
            ));

        await sendMessage(imgFile: file, messageType: 'image', tempId: tempId);
      }
    } finally {
      isImagePickerActive = false;
      update();
    }
  }

  String? path;

  Future<void> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final tempDir = await getTemporaryDirectory();
      path =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: path);
      isRecording = true;
      isRecordingPaused = false;
      update();
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _recorder!.pauseRecorder();
      isRecordingPaused = true;
      update();
    } catch (e) {
      log("Pause error: $e");
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _recorder!.resumeRecorder();
      isRecordingPaused = false;
      update();
    } catch (e) {
      log("Resume error: $e");
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder!.stopRecorder();
      isRecording = false;
      isRecordingPaused = false;
      if (path != null && await File(path!).exists()) {
        await File(path!).delete();
      }
      path = null;
      update();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  Future<void> stopRecording() async {
    String? recordPath = await _recorder!.stopRecorder();
    isRecording = false;
    isRecordingPaused = false;
    update();

    if (recordPath == null || recordPath.isEmpty) return;
    File file = File(recordPath);
    if (!await file.exists()) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.insert(
        0,
        ChatMessage(
          imageUrl: null,
          reaction: [],
          senderName: sharedPreferences!.getString("username") ??
              sharedPreferences!.getString("usernameGust") ??
              "",
          message: recordPath,
          messageType: 'voice',
          messageId: tempId,
          isFromSender: true,
          isPending: true,
          timestamp: DateFormat('h:mm a').format(DateTime.now()),
        ));

    await sendMessage(audioFile: file, messageType: 'audio', tempId: tempId);
  }

  reactMessage({required String messageId, required String react}) async {
    var response = await _chatsRemoteData.sendReactMessages(
      messageId: int.parse(messageId),
      react: react,
    );

    statuesRequest = handlingData(response);
    if (statuesRequest == StatuesRequest.success) {
      final messageIndex =
          messages.indexWhere((msg) => msg.messageId == messageId);
      if (messageIndex != -1) {
        final reactionIndex = messages[messageIndex]
            .reaction
            .indexWhere((reaction) => reaction.id == null);
        if (reactionIndex != -1) {
          messages[messageIndex].reaction[reactionIndex].id =
              response['data']['id'];
          messages[messageIndex].reaction[reactionIndex].user!.id =
              response['data']['user']['id'];
          messages[messageIndex].reaction[reactionIndex].user!.username =
              response['data']['user']['username'];
        }
        messages.refresh();
      }
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  void addReactionToMessage(
      int messageIndex, String reaction, String messageId) {
    if (messageIndex >= 0 && messageIndex < messages.length) {
      final currentUserId = int.tryParse(sharedPreferences!.getString("id") ??
              sharedPreferences!.getString("idGust") ??
              "0") ??
          0;

      final existingReactionIndex = messages[messageIndex]
          .reaction
          .indexWhere((r) => r.user!.id == currentUserId);

      if (existingReactionIndex != -1) {
        if (messages[messageIndex].reaction[existingReactionIndex].react ==
            reaction) {
          messages[messageIndex].reaction.removeAt(existingReactionIndex);
        } else {
          messages[messageIndex].reaction[existingReactionIndex].react =
              reaction;
        }
      } else {
        messages[messageIndex].reaction.add(MessageReactions(
              react: reaction,
              id: null,
              user: User(
                id: currentUserId,
                username: sharedPreferences!.getString("username") ??
                    sharedPreferences!.getString("usernameGust") ??
                    "",
                image: sharedPreferences!.getString("img"),
              ),
            ));
      }

      reactMessage(messageId: messageId, react: reaction);
      messages.refresh();
    }
  }

  bool memberClick = true;
  changeClick(member) {
    memberClick = member;
    if (memberClick && members.isEmpty) getMembers();
    if (!memberClick && memmbersRequests.isEmpty) getMembers();
    update();
  }

  StatuesRequest statuesRequestMembers = StatuesRequest.none;
  List<MemberOfChatModel> members = [];
  List<MemberOfChatModel> memmbersRequests = [];
  int currentMembersPage = 1;
  bool isLoadingMoreMembers = false;
  bool hasMoreMembers = true;
  int currentRequestsPage = 1;
  bool isLoadingMoreRequests = false;
  bool hasMoreRequests = true;
  List<MemberOfChatModel> memberIdToBlock = [];

  getMemberToBlock() async {
    memberIdToBlock.clear();
    var response = await _chatsRemoteData.getMemberOfChat(
      perPage: 10,
      page: 1,
      chatId: int.parse(chatId),
    );
    if (handlingData(response) == StatuesRequest.success) {
      List responseBody = response['data'];
      final myId = sharedPreferences!.getString("id");
      memberIdToBlock.addAll(responseBody
          .map((e) => MemberOfChatModel.fromJson(e))
          .where((e) => e.id.toString() != myId));
    }
  }

  getMembers({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      members.clear();
      memmbersRequests.clear();
      currentMembersPage = 1;
      currentRequestsPage = 1;
      hasMoreMembers = true;
      hasMoreRequests = true;
    }

    if (memberClick && (isLoadingMoreMembers || !hasMoreMembers)) return;
    if (!memberClick && (isLoadingMoreRequests || !hasMoreRequests)) return;

    if (loadMore) {
      memberClick ? isLoadingMoreMembers = true : isLoadingMoreRequests = true;
    } else {
      statuesRequestMembers = StatuesRequest.loading;
    }
    update();

    var response = await _chatsRemoteData.getMemberOfChat(
      perPage: 10,
      page: memberClick ? currentMembersPage : currentRequestsPage,
      chatId: int.parse(chatId),
    );

    statuesRequestMembers = handlingData(response);
    if (statuesRequestMembers == StatuesRequest.success) {
      List responseBody = response['data'];
      if (responseBody.isEmpty) {
        memberClick ? hasMoreMembers = false : hasMoreRequests = false;
      } else {
        List<MemberOfChatModel> newMembers =
            responseBody.map((e) => MemberOfChatModel.fromJson(e)).toList();
        var accepted = newMembers
            .where((e) => e.memberStatus != "Waiting_for_acceptance")
            .toList();
        var pending = newMembers
            .where((e) => e.memberStatus == "Waiting_for_acceptance")
            .toList();

        members.addAll(accepted);
        memmbersRequests.addAll(pending);

        if (memberClick && accepted.isNotEmpty) currentMembersPage++;
        if (!memberClick && pending.isNotEmpty) currentRequestsPage++;

        createChatController.members = members;
        createChatController.chatAdmin.clear();
        for (var member in members) {
          if (member.isAdmin == 1) {
            createChatController.chatAdmin
                .add({"chat_admin_id": member.id.toString()});
          }
        }
      }
    } else {
      memberClick ? hasMoreMembers = false : hasMoreRequests = false;
    }

    isLoadingMoreMembers = false;
    isLoadingMoreRequests = false;
    update();
  }

  Future<void> loadMoreMembers() async {
    if (memberClick && (!hasMoreMembers || isLoadingMoreMembers)) return;
    if (!memberClick && (!hasMoreRequests || isLoadingMoreRequests)) return;
    await getMembers(
        page: memberClick ? currentMembersPage : currentRequestsPage,
        loadMore: true);
  }

  sendFriendRequest({required friendID}) async {
    var response = await _chatsRemoteData.sendFriendRequest(
      friendId: friendID,
    );
    statuesRequestMembers = handlingData(response);
    update();
  }

  blockOrUnBlock({required friendID, required int status}) async {
    var response = await _chatsRemoteData.blockOrUnBlock(
      status: status,
      id: friendID,
    );
    if (handlingData(response) == StatuesRequest.success) update();
  }

  createChatFriend({required friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.createChatFriend(
      friendId: friendID,
    );
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      navigateToChats(userchat: UserChatModel.fromJson(response['data']));
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  void navigateToChats({UserChatModel? userchat}) {
    chatId = '';
    messages.clear();
    Get.to(
      () => ChatView(isGust: false, isPin: false, userChatModel: userchat),
      arguments: {"chatId": userchat!.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
    );
  }

  acceptNeedTochat({required int membeerId}) async {
    statuesRequest = StatuesRequest.loading;
    update(); // تحديث عشان لو عامل Loading يظهر

    var response = await _chatsRemoteData.acceptMemberToChat(
      chatID: chatId,
      idUSer: membeerId,
    );

    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final acceptedIndex =
          memmbersRequests.indexWhere((member) => member.id == membeerId);
      if (acceptedIndex != -1) {
        final acceptedMember = memmbersRequests[acceptedIndex];
        acceptedMember.memberStatus = "accepted";
        if (!members.any((m) => m.id == membeerId)) {
          members.add(acceptedMember);
        }
      }
      memmbersRequests.removeWhere((member) => member.id == membeerId);

      update();
    } else {
      showUserFriendlyError(statuesRequest);
    }
    update();
  }

  Future<void> getRadios() async {
    radioStatusRequest = StatuesRequest.loading;
    update();
    try {
      radios = await _radioRemoteData.getRadios();
      radioStatusRequest = StatuesRequest.success;
    } catch (e) {
      radioStatusRequest = StatuesRequest.serverException;
    }
    update();
  }

  Future<void> playRadio(int radioIndex) async {
    if (radioIndex < 0 || radioIndex >= radios.length) return;
    try {
      await audioPlayer.stop();
      currentRadioIndex = radioIndex;
      isRadioPlaying = true;
      update();

      await audioPlayer.setUrl(radios[radioIndex].radioUrl);
      await audioPlayer.play();
    } catch (e) {
      isRadioPlaying = false;
      currentRadioIndex = null;
      update();
      if (Get.context != null) {
        Get.snackbar('Error', 'Unable to play radio.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
      }
    }
  }

  Future<void> stopRadio() async {
    isRadioPlaying = false;
    currentRadioIndex = null;
    update();
    await audioPlayer.stop();
  }

  shareChat({required String link}) async {
    // Generate a deep link instead of sharing the raw ID/url if needed
    // Assuming 'link' here was the raw URL or just ID. If it's ID, we pass it.
    // I will extract ID if it's a URL, or just use chatId.
    String dynamicLink = DynamicLinkService.createDynamicLink(chatId);
    SharePlus.instance.share(ShareParams(uri: Uri.parse(dynamicLink)));
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    messageController.dispose();
    _recorder?.closeRecorder();
    for (var channel in subscribedChannels) {
      pusher.unsubscribe(channelName: channel);
    }
    pusher.disconnect();
    super.onClose();
  }
}
