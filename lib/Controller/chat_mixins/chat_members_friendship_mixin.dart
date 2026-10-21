import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/View/Widget/ChatWidgets/chat_helpers.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/dynamic_link_service.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/Model/member_of_chat_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/main.dart';
import 'package:share_plus/share_plus.dart';
import 'chat_base_controller.dart';

mixin ChatMembersFriendshipMixin on ChatBaseController {
  bool memberClick = true;
  int currentMembersPage = 1;
  bool isLoadingMoreMembers = false;
  bool hasMoreMembers = true;
  int currentRequestsPage = 1;
  bool isLoadingMoreRequests = false;
  bool hasMoreRequests = true;
  StatuesRequest statuesRequestMembers = StatuesRequest.none;

  changeClick(member) {
    memberClick = member;
    if (memberClick && members.isEmpty) getMembers();
    if (!memberClick && memmbersRequests.isEmpty) getMembers();
    update();
  }

  getMemberToBlock() async {
    memberIdToBlock.clear();
    var response = await chatsRemoteData.getMemberOfChat(
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
    update();
  }

  getMembers({int page = 1, bool loadMore = false}) async {
    if (loadMore) {
      if (memberClick) {
        isLoadingMoreMembers = true;
      } else {
        isLoadingMoreRequests = true;
      }
    } else {
      statuesRequestMembers = StatuesRequest.loading;
      if (memberClick) {
        members.clear();
        currentMembersPage = 1;
        hasMoreMembers = true;
      } else {
        memmbersRequests.clear();
        currentRequestsPage = 1;
        hasMoreRequests = true;
      }
    }
    update();

    var response = await chatsRemoteData.getMemberOfChat(
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

  Future<bool> sendFriendRequest({required dynamic friendID}) async {
    var response = await chatsRemoteData.sendFriendRequest(
      friendId: friendID,
    );
    statuesRequestMembers = handlingData(response);
    if (statuesRequestMembers == StatuesRequest.success) {
      final index = members.indexWhere((m) => m.id == friendID);
      if (index != -1) {
        members[index].requestStatus = "request_sent";
      }
    }
    update();
    return statuesRequestMembers == StatuesRequest.success;
  }

  Future<bool> acceptFriendRequest({required dynamic friendID}) async {
    var response = await chatsRemoteData.acceptOrRejectRequestFriend(
      status: 1,
      friendId: friendID,
    );
    final status = handlingData(response);
    if (status == StatuesRequest.success) {
      final index = members.indexWhere((m) => m.id == friendID);
      if (index != -1) {
        members[index].requestStatus = "friends";
      }
      update();
      return true;
    } else {
      showUserFriendlyError(status);
      return false;
    }
  }

  Future<bool> cancelFakeFriendRequest({required dynamic friendID}) async {
    try {
      var response = await chatsRemoteData.sendFriendRequest(friendId: friendID);
      final status = handlingData(response);
      return status == StatuesRequest.success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectOrCancelFriendRequest({required dynamic friendID}) async {
    var response = await chatsRemoteData.acceptOrRejectRequestFriend(
      status: 0,
      friendId: friendID,
    );
    final status = handlingData(response);
    if (status == StatuesRequest.success) {
      final index = members.indexWhere((m) => m.id == friendID);
      if (index != -1) {
        members[index].requestStatus = "none";
      }
      update();
      return true;
    } else {
      showUserFriendlyError(status);
      return false;
    }
  }

  Future<bool> blockOrUnBlock({required dynamic friendID, required int status}) async {
    var response = await chatsRemoteData.blockOrUnBlock(
      status: status,
      id: friendID,
    );
    final isSuccess = handlingData(response) == StatuesRequest.success;
    if (isSuccess) update();
    return isSuccess;
  }

  createChatFriend({required dynamic friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await chatsRemoteData.createChatFriend(
      friendId: friendID,
    );
    var status = handlingData(response);

    if (status != StatuesRequest.success) {
      final rawMsg = Api.serverMessage?.toLowerCase() ??
          (response is Map ? response['message']?.toString().toLowerCase() ?? '' : '');
      final isRequestNeeded = rawMsg.contains("اقبل طلب") ||
          rawMsg.contains("طلب صداقة") ||
          rawMsg.contains("accept friend request");

      if (isRequestNeeded) {
        Api.serverMessage = null;
        final userChat = await ChatHelpers.openChatWithFriendRequestTrick(
          chatsRemoteData: chatsRemoteData,
          friendId: friendID,
          navigateToChats: (u) => navigateToChats(userchat: u),
        );
        if (userChat != null) {
          statuesRequest = StatuesRequest.none;
          update();
          return;
        }
      }
    }
    statuesRequest = status;

    if (statuesRequest == StatuesRequest.success) {
      final userChat = UserChatModel.fromJson(response['data']);
      userChat.otherUserId = friendID is int ? friendID : int.tryParse(friendID.toString());
      userChat.user ??= User(id: userChat.otherUserId);

      // Check friendship status from group members list:
      final matchingMember = members.firstWhereOrNull((m) => m.id?.toString() == friendID.toString()) ??
          memmbersRequests.firstWhereOrNull((m) => m.id?.toString() == friendID.toString());
      if (matchingMember != null && matchingMember.requestStatus != null) {
        if (matchingMember.requestStatus == 'friends') {
          userChat.status = 'friends';
        } else {
          userChat.status = 'not friend';
        }
      } else {
        if (userChat.status?.toLowerCase() != 'friends') {
          userChat.status = 'not friend';
        }
      }

      navigateToChats(userchat: userChat);
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
      arguments: {
        "chatId": userchat?.id?.toString() ?? '',
        "userChatModel": userchat,
      },
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
    );
  }

  acceptNeedTochat({required int membeerId}) async {
    statuesRequest = StatuesRequest.loading;
    update();

    var response = await chatsRemoteData.acceptMemberToChat(
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

  shareChat({required String link}) async {
    String dynamicLink = DynamicLinkService.createDynamicLink(chatId);
    SharePlus.instance.share(ShareParams(uri: Uri.parse(dynamicLink)));
  }
}
