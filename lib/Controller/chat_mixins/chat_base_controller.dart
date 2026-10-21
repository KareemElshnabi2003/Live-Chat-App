// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_chat/Controller/create_chat_controller.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Core/function/html_decoder.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/DataSource/radio_remote_data.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/Data/Model/member_of_chat_model.dart';
import 'package:live_chat/Data/Model/message_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/main.dart';

abstract class ChatBaseController extends GetxController {
  CreateChatController get createChatController => Get.put(CreateChatController());
  final ChatsRemoteData chatsRemoteData = ChatsRemoteData(api: Get.find<Api>());
  ChatsRemoteData get _chatsRemoteData => chatsRemoteData;

  final RadioRemoteData radioRemoteData = RadioRemoteData(api: Get.find<Api>());

  StatuesRequest statuesRequest = StatuesRequest.none;
  MessageModel? messageModel;
  List<MessageModel> messagesApi = [];
  String chatId = '';
  bool isPublicChat = false;
  UserChatModel? userChatModel;
  bool isJoined = true;
  bool hasSentFriendRequest = false;

  bool answer = true;
  bool isFakeRequest = false;

  final TextEditingController messageController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  static final Map<String, List<ChatMessage>> messagesCache = {};

  final RxBool isLoadingInitial = true.obs;
  ChatMessage? replyingToMessage;

  List<MemberOfChatModel> members = [];
  List<MemberOfChatModel> memmbersRequests = [];
  List<MemberOfChatModel> memberIdToBlock = [];

  bool get shouldSkipInitialGetMessages {
    if (isGroupChat) return false;
    final status = userChatModel?.status?.toLowerCase();
    return status != 'friends' && status != 'friend';
  }

  bool get isGroupChat {
    if (userChatModel != null) {
      final status = userChatModel!.status?.toLowerCase();
      if (status == 'friends' || status == 'not friend' || status == 'friend') {
        return false;
      }
      if (status == 'public') {
        return true;
      }
      if (status == 'private') {
        final bool isGroupRoom = (userChatModel!.chatAdmins != null && userChatModel!.chatAdmins!.isNotEmpty) ||
            (userChatModel!.membersCount != null && userChatModel!.membersCount! > 2) ||
            userChatModel!.themeId != null;
        return isGroupRoom;
      }
    }
    return isPublicChat;
  }

  void setReply(ChatMessage message) {
    replyingToMessage = message;
    update();
  }

  void cancelReply() {
    replyingToMessage = null;
    update();
  }

  int? getOtherUserId() {
    final myId = sharedPreferences?.getString("id")?.trim() ?? "";
    if (userChatModel?.otherUserId != null &&
        userChatModel!.otherUserId.toString() != myId) {
      return userChatModel!.otherUserId;
    }
    if (userChatModel?.user?.id != null &&
        userChatModel!.user!.id.toString() != myId) {
      return userChatModel!.user!.id;
    }
    if (userChatModel?.userId != null &&
        userChatModel!.userId.toString() != myId) {
      return userChatModel!.userId;
    }
    if (userChatModel?.lastMessage?.senderId != null &&
        userChatModel!.lastMessage!.senderId.toString() != myId) {
      return userChatModel!.lastMessage!.senderId;
    }
    if (memberIdToBlock.isNotEmpty) {
      for (var e in memberIdToBlock) {
        if (e.id != null && e.id.toString() != myId) {
          return e.id;
        }
      }
    }
    if (members.isNotEmpty) {
      for (var m in members) {
        if (m.id != null && m.id.toString() != myId) {
          return m.id;
        }
      }
    }
    final fallback = userChatModel?.user?.id ?? userChatModel?.userId;
    if (fallback != null && fallback.toString() != myId) {
      return fallback;
    }
    return null;
  }

  void checkJoinedStatus() {
    if (!isGroupChat) {
      isJoined = true;
      return;
    }
    final currentUserId = sharedPreferences?.getString("id")?.trim() ?? "";
    final isOwner = (userChatModel?.user != null &&
            userChatModel!.user!.id.toString() == currentUserId) ||
        (userChatModel?.userId != null &&
            userChatModel!.userId.toString() == currentUserId);

    final isAdmin = userChatModel?.chatAdmins?.any(
            (admin) => admin.chatAdminId?.toString() == currentUserId) ??
        false;

    if (isOwner || isAdmin) {
      isJoined = true;
      return;
    }

    if (Get.isRegistered<HomeNavigationController>()) {
      final homeCtrl = Get.find<HomeNavigationController>();
      final int? cId = int.tryParse(chatId) ?? userChatModel?.id;
      if (cId != null && homeCtrl.joinedChatIds.contains(cId)) {
        isJoined = true;
        return;
      }
    }

    isJoined = false;
  }

  Future<bool> joinCurrentChat() async {
    final int? cId = int.tryParse(chatId) ?? userChatModel?.id;
    if (cId == null) return false;

    try {
      var response = await _chatsRemoteData.joinToCgat(chatId: cId);
      final status = handlingData(response);
      if (status == StatuesRequest.success) {
        isJoined = true;
        if (Get.isRegistered<HomeNavigationController>()) {
          Get.find<HomeNavigationController>().joinedChatIds.add(cId);
          Get.find<HomeNavigationController>().getMyChat();
        }
        update();
        return true;
      }
    } catch (e) {
      log("Error joining current chat: $e");
    }
    return false;
  }

  void seedInitialData(UserChatModel? model) {
    if (model == null) return;
    userChatModel = model;
    checkJoinedStatus();
    final effectiveId = (chatId.isNotEmpty ? chatId : model.id?.toString()) ?? '';
    if (chatId.isEmpty && effectiveId.isNotEmpty) {
      chatId = effectiveId;
    }

    if (shouldSkipInitialGetMessages) {
      isLoadingInitial.value = false;
    }

    if (effectiveId.isNotEmpty &&
        messagesCache.containsKey(effectiveId) &&
        messagesCache[effectiveId]!.isNotEmpty) {
      messages.assignAll(messagesCache[effectiveId]!);
      isLoadingInitial.value = false;
      return;
    }

    if (messages.isEmpty && model.lastMessage != null) {
      final lm = model.lastMessage!;
      if (lm.message != null && lm.message!.isNotEmpty) {
        final myIdStr = sharedPreferences?.getString("id");
        final bool isMe = "${lm.senderId}" == myIdStr?.toString();
        final initialMsg = ChatMessage(
          senderName: lm.senderName ?? (isMe ? 'Me' : model.name ?? ''),
          imageUrl: lm.senderImage,
          reaction: [],
          message: decodeHtmlEntities(lm.message ?? ''),
          messageType: lm.messageType ?? 'text',
          messageId: lm.id?.toString() ?? 'temp_last',
          isPending: false,
          isFromSender: isMe,
          isRead: true,
          timestamp: lm.createdAt != null
              ? DateFormat('h:mm a').format(DateTime.tryParse(lm.createdAt!) ?? DateTime.now())
              : '',
        );
        messages.assignAll([initialMsg]);
        isLoadingInitial.value = false;
      }
    }
  }

  // Cross-mixin contract hooks:
  Future<void> sendMessage({
    String? text,
    File? imgFile,
    File? audioFile,
    required String messageType,
    String? tempId,
  });

  Future<void> sendSystemMessage(String finalMessage, {String? targetChatId});
  void updateCallActiveStatus();
  Future<void> getMessages({int page = 1});
  Future<void> getTokenCall({
    required bool isGroub,
    required Map<int, String> groubUsersNames,
    required dynamic usernameFriend,
    bool isJoin = false,
  });
}
