import 'dart:io';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class ChatsRemoteData {
  final Api api; // إضافة final
  ChatsRemoteData({required this.api});

  getConversationUsers({required int chatId}) async {
    var response =
        await api.getData("${AppApi.baseUrl}/get-conversation-users/$chatId");
    return response.fold((l) => l, (r) => r);
  }

  getPinChatGust({required String deviceToken}) async {
    var response = await api.getData(
      "${AppApi.getPinedChat}?device_id=$deviceToken",
    );
    return response.fold((l) => l, (r) => r);
  }

  checkCall({required id}) async {
    var response = await api.getData("${AppApi.checkCallUrl}/$id");
    return response.fold((l) => l, (r) => r);
  }

  endCall({required id}) async {
    var response = await api.postData("${AppApi.endCallUrl}/$id", {});
    return response.fold((l) => l, (r) => r);
  }

  getTokenCall(
      {required int chatId,
      required String role,
      required callType,
      required bool isGroub}) async {
    Map<String, dynamic> data = role == "publisher"
        ? {
            "conversation_id": "$chatId",
            "role": role,
            "call_type": callType,
            "is_group": isGroub,
            "user_id": "${sharedPreferences!.getString("id")}"
          }
        : {
            "conversation_id": "$chatId",
            "role": role,
            "call_type": callType,
            "is_group": isGroub,
          };
    var response = await api.postData(AppApi.getTokenCallUrl, data);
    return response.fold((l) => l, (r) => r);
  }

  getRecentChatGust({perPage, page, required deviceToken}) async {
    var response = await api.getData(
        "${AppApi.getRecentChatsUrl}?device_id=$deviceToken&per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getSystemChatsGust({perPage, page, required deviceToken}) async {
    var response = await api.getData(
        "${AppApi.getSystemChatUrl}?per_page=$perPage&page=$page&device_id=$deviceToken");
    return response.fold((l) => l, (r) => r);
  }

  getMemberOfChat(
      {required chatId,
      required token,
      required perPage,
      required page}) async {
    var response = await api.getData(
        "${AppApi.getMemberChatUrl}/$chatId?per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getuserChats({required token, required perPage, required page}) async {
    var response = await api
        .getData("${AppApi.getUsersChatUrl}?per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getFriendeRecommendation(
      {required perPage, required token, required page}) async {
    var response = await api.getData(
        "${AppApi.getSuggerstFriendesUrl}?per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getFriende({required perPage, required token, required page}) async {
    var response = await api
        .getData("${AppApi.getFriendesUrl}?per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getMessages(
      {required token, required idChat, page, required tokenDevice}) async {
    var response = await api.getData(
        "${AppApi.getMessagesChatUrl}?conversation_id=$idChat&page=$page&per_page=20&device_id=$tokenDevice");
    return response.fold((l) => l, (r) => r);
  }

  sendMessagesWithFile(
      {required token,
      required chatId,
      required File? audio,
      required File? image,
      required tokenDevice}) async {
    var response = await api.postDataWithRecordAndImage(
        AppApi.sendMessagesUrl,
        image == null
            ? {
                "conversation_id": chatId,
                "message_type": "voice",
                "device_id": tokenDevice
              }
            : {
                "conversation_id": chatId,
                "message_type": "image",
                "device_id": tokenDevice
              },
        image,
        audio);
    return response.fold((l) => l, (r) => r);
  }

  sendMessages(
      {required token,
      required chatId,
      required message,
      required tokenDevice}) async {
    var response = await api.postData(AppApi.sendMessagesUrl, {
      "conversation_id": chatId,
      "message": message,
      "message_type": "text",
      "device_id": tokenDevice
    });
    return response.fold((l) => l, (r) => r);
  }

  sendReactMessages(
      {required token,
      required messageId,
      required react,
      required tokenDevice}) async {
    var response = await api.postData(AppApi.reactToMessageUrl,
        {"message_id": messageId, "react": react, "device_id": tokenDevice});
    return response.fold((l) => l, (r) => r);
  }

  sendFriendRequest({required token, required friendId}) async {
    var response =
        await api.getData("${AppApi.sendFriendRequestUrl}/$friendId");
    return response.fold((l) => l, (r) => r);
  }

  removeFriend({required token, required friendId}) async {
    var response = await api.getData("${AppApi.removeFriendUrl}/$friendId");
    return response.fold((l) => l, (r) => r);
  }

  acceptOrRejectRequestFriend(
      {required token, required status, required friendId}) async {
    var response = await api
        .getData("${AppApi.acceptOrRejectFriendUrl}/$friendId?status=$status");
    return response.fold((l) => l, (r) => r);
  }

  createChatFriend({required token, required friendId}) async {
    var response =
        await api.postData(AppApi.createChatFriendUrl, {"member": friendId});
    return response.fold((l) => l, (r) => r);
  }

  deleteChat({required token, required chatId}) async {
    var response = await api.deleteData("${AppApi.deleteChatUrl}/$chatId");
    return response.fold((l) => l, (r) => r);
  }

  createGeneralChat({
    required token,
    required imgChat,
    required them,
    required name,
    required status,
    required accept,
    required themeID,
  }) async {
    Map<String, dynamic> data = themeID == "null"
        ? {
            "name": name,
            "status": status.toString(),
            "accept": accept.toString()
          }
        : {
            "name": name,
            "status": status.toString(),
            "theme_id": themeID,
            "accept": accept.toString()
          };
    var response = await api.postRequestwithfile(
        AppApi.createChatUrl, data, imgChat, them);
    return response.fold((l) => l, (r) => r);
  }

  updateGeneralChat(
      {required token,
      required imgChat,
      required them,
      required name,
      required status,
      required accept,
      required themeID,
      required List<Map<String, dynamic>> chatAdmins,
      required chatID}) async {
    Map<String, dynamic> requestData = themeID == "null"
        ? {"name": name, "status": status, "accept": accept, "_method": "Patch"}
        : {
            "name": name,
            "status": status,
            "theme_id": themeID,
            "accept": accept,
            "_method": "Patch"
          };

    requestData["chat_admins[][chat_admin_id]"] =
        sharedPreferences!.getString("id");
    for (int i = 0; i < chatAdmins.length; i++) {
      requestData["chat_admins[][chat_admin_id]"] =
          chatAdmins[i]["chat_admin_id"];
    }

    var response = await api.updateRequestwithfile(
        "${AppApi.createChatUrl}/$chatID", requestData, imgChat, them);
    return response.fold((l) => l, (r) => r);
  }

  acceptMemberToChat({required token, required chatID, required idUSer}) async {
    var response = await api.postData(AppApi.acceptMemberToChat, {
      "conversation_id": chatID,
      "user_ids": [idUSer]
    });
    return response.fold((l) => l, (r) => r);
  }

  getThems({required token}) async {
    var response = await api.getData(AppApi.getThemsUrl);
    return response.fold((l) => l, (r) => r);
  }

  blockOrUnBlock({required token, required bool status, required id}) async {
    var response =
        await api.postData("${AppApi.blockUrl}/$id/block", {"block": status});
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getSystemConversations({required String token}) async {
    try {
      var response = await api
          .getData(AppApi.getSystemChatUrl);
      return response.fold((l) => l, (r) => r);
    } catch (e) {
      rethrow;
    }
  }

  joinToCgat({required token, required chatId, required memberId}) async {
    var response = await api.getData(
        "${AppApi.baseUrl}/join-to-conversation/$chatId?membr=$memberId");
    return response.fold((l) => l, (r) => r);
  }
}
