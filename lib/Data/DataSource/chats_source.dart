import 'dart:io';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class ChatsRemoteData {
  final Api api; // إضافة final
  ChatsRemoteData({required this.api});
  final String deviceId=sharedPreferences!.getString("deviceId")??"";

  getConversationUsers({required int chatId}) async {
    var response =
        await api.getData("${AppApi.baseUrl}/get-conversation-users/$chatId?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  getPinChatGust() async {
    var response = await api.getData(
      "${AppApi.getPinedChat}?device_id=$deviceId",
    );
    return response.fold((l) => l, (r) => r);
  }

  checkCall({required id}) async {
    var response = await api.getData("${AppApi.checkCallUrl}/$id?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  endCall({required id}) async {
    var response = await api.postData("${AppApi.endCallUrl}/$id?device_id=$deviceId", {});
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
    var response = await api.postData("${AppApi.getTokenCallUrl}?device_id=$deviceId", data);
    return response.fold((l) => l, (r) => r);
  }

  getRecentChatGust({perPage, page}) async {
    var response = await api.getData(
        "${AppApi.getRecentChatsUrl}?device_id=$deviceId&per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getSystemChatsGust({perPage, page}) async {
    var response = await api.getData(
        "${AppApi.getSystemChatUrl}?per_page=$perPage&page=$page&device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  getMemberOfChat(
      {required chatId,

      required perPage,
      required page}) async {
    var response = await api.getData(
        "${AppApi.getMemberChatUrl}/$chatId?device_id=$deviceId&per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getuserChats({ required perPage, required page}) async {
    var response = await api
        .getData("${AppApi.getUsersChatUrl}?device_id=$deviceId&per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getFriendeRecommendation(
      {required perPage,  required page}) async {
    var response = await api.getData(
        "${AppApi.getSuggerstFriendesUrl}?device_id=$deviceId&per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getFriende({required perPage,  required page}) async {
    var response = await api
        .getData("${AppApi.getFriendesUrl}?device_id=$deviceId&per_page=$perPage&page=$page");
    return response.fold((l) => l, (r) => r);
  }

  getMessages(
      { required idChat, page}) async {
    var response = await api.getData(
        "${AppApi.getMessagesChatUrl}?conversation_id=$idChat&page=$page&per_page=20&device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  sendMessagesWithFile(
      {
      required chatId,
      required File? audio,
      required File? image
     }) async {
    var response = await api.postDataWithRecordAndImage(
        AppApi.sendMessagesUrl,
        image == null
            ? {
                "conversation_id": chatId,
                "message_type": "voice",
                "device_id": deviceId
              }
            : {
                "conversation_id": chatId,
                "message_type": "image",
                "device_id": deviceId
              },
        image,
        audio);
    return response.fold((l) => l, (r) => r);
  }

  sendMessages(
      {
      required chatId,
      required message
      }) async {
    print("tokenDevice >>>$deviceId");
    var response = await api.postData(AppApi.sendMessagesUrl, {
      "conversation_id": chatId,
      "message": message,
      "message_type": "text",
      "device_id": deviceId
    });
    return response.fold((l) => l, (r) => r);
  }

  sendReactMessages(
      {
      required messageId,
      required react
    }) async {
    var response = await api.postData(AppApi.reactToMessageUrl,
        {"message_id": messageId, "react": react, "device_id": deviceId});
    return response.fold((l) => l, (r) => r);
  }

  sendFriendRequest({ required friendId}) async {
    var response =
        await api.getData("${AppApi.sendFriendRequestUrl}/$friendId?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  removeFriend({ required friendId}) async {
    var response = await api.getData("${AppApi.removeFriendUrl}/$friendId?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  acceptOrRejectRequestFriend(
      { required status, required friendId}) async {
    var response = await api
        .getData("${AppApi.acceptOrRejectFriendUrl}/$friendId?status=$status&device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  createChatFriend({required friendId}) async {
    var response =
        await api.postData("${AppApi.createChatFriendUrl}?device_id=$deviceId", {"member": friendId});
    return response.fold((l) => l, (r) => r);
  }

  deleteChat({ required chatId}) async {
    var response = await api.deleteData("${AppApi.deleteChatUrl}/$chatId?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  createGeneralChat({

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
       "${AppApi.createChatUrl}?device_id=$deviceId", data, imgChat, them);
    return response.fold((l) => l, (r) => r);
  }

  updateGeneralChat(
      {
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
        "${AppApi.createChatUrl}/$chatID?device_id=$deviceId", requestData, imgChat, them);
    return response.fold((l) => l, (r) => r);
  }

  acceptMemberToChat({ required chatID, required idUSer}) async {
    var response = await api.postData("${AppApi.acceptMemberToChat}?device_id=$deviceId", {
      "conversation_id": chatID,
      "user_id": idUSer
    });
    return response.fold((l) => l, (r) => r);
  }

  getThems() async {
    var response = await api.getData("${AppApi.getThemsUrl}?device_id=$deviceId");
    return response.fold((l) => l, (r) => r);
  }

  blockOrUnBlock({ required int status, required id}) async {
    var response =
        await api.postData("${AppApi.blockUrl}/$id/block?device_id=$deviceId", {"block": status});
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getSystemConversations() async {
    try {
      var response = await api
          .getData("${AppApi.getSystemChatUrl}?device_id=$deviceId");
      return response.fold((l) => l, (r) => r);
    } catch (e) {
      rethrow;
    }
  }  Future<dynamic> getGeneralChat() async {
    try {
      var response = await api
          .getData("${AppApi.getGeneralChatsUrl}?device_id=$deviceId");
      return response.fold((l) => l, (r) => r);
    } catch (e) {
      rethrow;
    }
  }

  joinToCgat({ required chatId}) async {
    var response = await api.postData(
        "${AppApi.baseUrl}/join-to-conversation/$chatId?device_id=$deviceId",{});
    return response.fold((l) => l, (r) => r);
  }
}
