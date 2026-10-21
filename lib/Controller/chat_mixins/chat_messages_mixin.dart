import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Core/function/html_decoder.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/Data/Model/message_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'chat_base_controller.dart';

mixin ChatMessagesMixin on ChatBaseController {
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreMessages = true;
  bool isImagePickerActive = false;

  void handleMessageReadInternal(dynamic eventData);
  void syncReadStatusForPassedMessagesInternal();
  void updateCallStatusInternal();

  @override
  Future<void> getMessages({int page = 1}) async {
    if (isLoadingMore || !hasMoreMessages) return;
    if (page > 1) {
      isLoadingMore = true;
    } else {
      if (messages.isEmpty) {
        isLoadingInitial.value = true;
      }
    }
    update();

    var response = await chatsRemoteData.getMessages(
      idChat: chatId,
      page: page,
    );

    statuesRequest = handlingData(response);

    final bool isForbidden = statuesRequest == StatuesRequest.forbiddenException ||
        (response is Map &&
            (response['code'] == 403 ||
                response['code'] == "403" ||
                response['status'] == 403));

    if (isForbidden) {
      log("ChatMessagesMixin: getMessages 403 Forbidden for chatId $chatId - suppressing error popup");
      hasMoreMessages = false;
      isLoadingInitial.value = false;
      isLoadingMore = false;
      statuesRequest = StatuesRequest.none;
      update();
      return;
    }

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
            imageUrl: e.senderImage,
            reaction: e.messageReactions ?? [],
            message: decodeHtmlEntities(e.message ?? ''),
            messageType: messageType,
            messageId: e.id.toString(),
            isPending: false,
            isFromSender: isMe,
            isRead: e.isRead ?? false,
            timestamp:
                DateFormat('h:mm a').format(DateTime.parse(e.createdAt!)),
          );
        }).toList();

        if (page == 1) {
          messages.assignAll(newChatMessages);
          if (chatId.isNotEmpty) {
            ChatBaseController.messagesCache[chatId] = List.from(newChatMessages);
          }
          updateCallStatusInternal();
        } else {
          messages.addAll(newChatMessages);
          if (chatId.isNotEmpty) {
            ChatBaseController.messagesCache[chatId] = List.from(messages);
          }
        }
        syncReadStatusForPassedMessagesInternal();
        currentPage = page;
      }
    } else {
      hasMoreMessages = false;
      if (messages.isEmpty) {
        showUserFriendlyError(statuesRequest);
      }
    }
    isLoadingMore = false;
    isLoadingInitial.value = false;
    update();
  }

  Future<void> loadMoreMessages() async {
    if (!hasMoreMessages || isLoadingMore) return;
    await getMessages(page: currentPage + 1);
  }

  @override
  Future<void> sendMessage({
    String? text,
    File? imgFile,
    File? audioFile,
    required String messageType,
    String? tempId,
  }) async {
    if (isGroupChat && !isJoined) {
      await joinCurrentChat();
    }

    final isNotFriend = !isGroupChat && userChatModel?.status?.toLowerCase() != "friends";

    if (isNotFriend) {
      final otherUserId = getOtherUserId();
      final myId = sharedPreferences?.getString("id")?.trim() ?? "";
      final bool hasIncomingMessage = messages.any((m) => !m.isFromSender) ||
          (userChatModel?.lastMessage != null &&
              userChatModel!.lastMessage!.senderId?.toString() != myId);

      if (otherUserId != null) {
        if (hasIncomingMessage && !answer) {
          answer = true;
          try {
            await chatsRemoteData.acceptOrRejectRequestFriend(
                friendId: otherUserId, status: 1);
          } catch (e) {
            log("Error accepting friend request: $e");
          }
        } else if (!hasSentFriendRequest) {
          hasSentFriendRequest = true;
          try {
            await chatsRemoteData.sendFriendRequest(friendId: otherUserId);
          } catch (e) {
            log("Error sending friend request: $e");
          }
        }
      }
    }

    dynamic response;
    if (imgFile != null || audioFile != null) {
      response = await chatsRemoteData.sendMessagesWithFile(
        chatId: chatId,
        audio: audioFile,
        image: imgFile,
      );
    } else {
      response = await chatsRemoteData.sendMessages(
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

        // 🌟 After sending the message and friend request, the conversation is now active.
        // Sync messages from the backend:
        hasMoreMessages = true;
        getMessages(page: 1);

        if (Get.isRegistered<HomeNavigationController>()) {
          Get.find<HomeNavigationController>().getMyChat();
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

  @override
  Future<void> sendSystemMessage(String finalMessage, {String? targetChatId}) async {
    final effectiveChatId = (targetChatId != null && targetChatId.isNotEmpty)
        ? targetChatId
        : chatId;
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    messages.insert(
        0,
        ChatMessage(
          imageUrl: null,
          reaction: [],
          senderName: sharedPreferences?.getString("name") ??
              sharedPreferences?.getString("username") ??
              sharedPreferences?.getString("usernameGust") ??
              "",
          message: finalMessage,
          messageType: 'text',
          messageId: tempId,
          isFromSender: true,
          isPending: true,
          timestamp: DateFormat('h:mm a').format(DateTime.now()),
        ));
    update();

    var response = await chatsRemoteData.sendMessages(
        chatId: effectiveChatId, message: finalMessage);

    final reqStatus = handlingData(response);
    final isSuccess = reqStatus == StatuesRequest.success ||
        (response is Map && (response['status'] == 'success' || response['code'] == 200));

    if (isSuccess) {
      log('✅ System message sent: $finalMessage');
      int indexToUpdate = messages.indexWhere((msg) => msg.messageId == tempId);
      if (indexToUpdate != -1) {
        messages[indexToUpdate] = ChatMessage(
          imageUrl: messages[indexToUpdate].imageUrl,
          senderName: messages[indexToUpdate].senderName,
          reaction: messages[indexToUpdate].reaction,
          message: messages[indexToUpdate].message,
          messageType: messages[indexToUpdate].messageType,
          messageId: (response is Map && response['data'] != null)
              ? response['data']['id']?.toString() ?? tempId
              : tempId,
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
            isPending: true,
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
    } catch (e) {
      log("Error picking image: $e");
    } finally {
      isImagePickerActive = false;
      update();
    }
  }

  reactMessage({required String messageId, required String react}) async {
    if (isGroupChat && !isJoined) {
      joinCurrentChat();
    }
    var response = await chatsRemoteData.sendReactMessages(
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
}
