import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/Controller/create_chat_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/DataSource/radio_remote_data.dart';
import 'package:live_chat/Data/Model/member_of_chat_model.dart';
import 'package:live_chat/Data/Model/message_model.dart';
import 'package:live_chat/Data/Model/radio_model.dart';
import 'package:live_chat/Data/Model/token_call_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/audio_call_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view_friend.dart';
import 'package:live_chat/View/Screens/create%20chat/video_call_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  final CreateChatController createChatController =
      Get.put(CreateChatController());
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());
  final RadioRemoteData _radioRemoteData =
      RadioRemoteData(api: Get.find<Api>());

  late PusherChannelsFlutter pusher;
  final Set<String> subscribedChannels = {};
  FlutterSoundRecorder? _recorder;
  bool isRecording = false;
  static bool _pusherInitialized = false;
  String? currentlyPlaying; // تم استرجاعه
  StatuesRequest statuesRequest = StatuesRequest.none;
  MessageModel? messageModel;
  List<MessageModel> messagesApi = [];
  String chatId = '';
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreMessages = true;
  bool audio = false;
  TokenCallModel? tokenCallModel;

  late final AudioPlayer audioPlayer;
  bool music1 = false, music2 = false, music3 = false;
  List<RadioModel> radios = [];
  StatuesRequest radioStatusRequest = StatuesRequest.none;
  int? currentRadioIndex;
  bool isRadioPlaying = false;

  final TextEditingController messageController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  bool answer = true;

  @override
  void onInit() {
    super.onInit();
    chatId = Get.arguments['chatId'].toString();
    getMemberToBlock();
    initPusher();
    getMessages();
    getRadios();
    audioPlayer = AudioPlayer();
    _recorder = FlutterSoundRecorder();
    _recorder!.openRecorder();
  }

  void initPusher() async {
    pusher = PusherChannelsFlutter.getInstance();
    if (!_pusherInitialized) {
      try {
        await pusher.init(
          apiKey: "f63bff3d533540e54682",
          cluster: "ap2",
          onEvent: (event) async {
            if (!Get.isRegistered<ChatController>()) return;
            final ctrl = Get.find<ChatController>();
            if (event.data.toString() == "{}") return;
            jsonDecode(event.data.toString());

            if (event.eventName == "message-created" &&
                event.channelName == "live-chat-ngoum-${ctrl.chatId}") {
              // ... منطق الاستقبال ...
              ctrl.update();
            }
          },
        );
      } catch (e) {
        log("Pusher error: $e");
      }
      _pusherInitialized = true;
    }
    if (!subscribedChannels.contains("live-chat-ngoum-$chatId")) {
      await pusher.subscribe(channelName: "live-chat-ngoum-$chatId");
      subscribedChannels.add("live-chat-ngoum-$chatId");
    }
    await pusher.connect();
  }

  call({
    required bool isGroub,
    required type,
    required Map<int, String> groubUsersNames,
    required usernameFriend,
  }) async {
    log("tokennnnnnnnnnnnnnnnnn");
    statuesRequest = StatuesRequest.loading;
    update();

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
        log("get token loaded successfully >>> ${response['data']}  <<< ");
        audio == true
            ? Get.to(
                () => const AudioCallPage(),
                arguments: {
                  "ChannelName": tokenCallModel!.channel,
                  "Token": tokenCallModel!.token,
                  "UId": tokenCallModel!.uid,
                  "IsGroupCall": isGroub,
                  "chatId": chatId,
                  "RemoteUserName": usernameFriend,
                  "UserNamesMap": groubUsersNames,
                  "LocalUserName": sharedPreferences!.getString("name")
                },
              )
            : Get.to(
                () => const VideoCallPage(),
                arguments: {
                  "ChannelName": tokenCallModel!.channel,
                  "Token": tokenCallModel!.token,
                  "UId": tokenCallModel!.uid,
                  "IsGroupCall": isGroub,
                  "chatId": chatId,
                  "RemoteUserName": usernameFriend,
                  "UserNamesMap": groubUsersNames,
                  "LocalUserName": sharedPreferences!.getString("name")
                },
              );
      } else {

        log("get token data is null");
      
          showUserFriendlyError(statuesRequest);
        
      }
    }

    update();
  }

  checkCall(
      {required bool isGroub,
      required Map<int, String>? groubUsersNames,
      required usernameFriend}) async {
    log("check");
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.checkCall(
      id: chatId,
    );
    log(response.toString());
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      log("check call  >>> ${response['data']}  <<< ");

      final responseBody = response['data'];
      if (responseBody != null) {
        log("check call  >>> ${response['data']['status']}  <<< ");
        String type = '';
        if (response['data']['status'] == 0) {
          type = 'publisher';
          call(
              isGroub: isGroub,
              type: type,
              groubUsersNames: groubUsersNames!,
              usernameFriend: usernameFriend);
        } else {
          type = "subscriber";
          call(
              isGroub: isGroub,
              type: type,
              groubUsersNames: groubUsersNames!,
              usernameFriend: usernameFriend);
        }
      } else {
        
          showUserFriendlyError(statuesRequest);
        
        log("check call data is null");
      }
    }

    update();
  }

  getTokenCall(
      {required bool isGroub,
      required Map<int, String> groubUsersNames,
      required usernameFriend}) async {
    await checkCall(
        isGroub: isGroub,
        groubUsersNames: groubUsersNames,
        usernameFriend: usernameFriend);
  }

  Future<void> getMessages({int page = 1}) async {
    if (isLoadingMore || !hasMoreMessages) return;

    if (page == 1) {
    } else {
      isLoadingMore = true;
    }
    update();

    var response = await _chatsRemoteData.getMessages(
      tokenDevice: sharedPreferences!.getString("deviceId"),
      idChat: chatId,
      token: sharedPreferences!.getString("token"),
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
        if (page == 1) {
          messagesApi.clear();
        }
        messagesApi.addAll(newMessages);
        List answers = [];
        answers.add(messagesApi.where(
          (element) =>
              element.senderId.toString() == sharedPreferences!.getString("id"),
        ));

        if (answers.toString() == "[()]") {
          answer = false;
          update();
        } else {
          answer = true;
          update();
        }
        // ignore: unused_local_variable
        final myId = sharedPreferences!.getString("id") ??
            sharedPreferences!.getString("idGust") ??
            "";
        List<ChatMessage> newChatMessages = newMessages.map((e) {
          String messageContent = e.message ?? '';
          String finalMessage = messageContent;
          String messageType = e.messageType ?? 'text';

          if (messageType == 'image' || messageType == 'voice') {
            finalMessage = messageContent;
          }

          return ChatMessage(
            senderName: e.senderName ?? 'Unknown',
            imageUrl: e.senderImage,
            reaction: e.messageReactions?.isNotEmpty == true
                ? e.messageReactions!
                : [],
            message: finalMessage,
            messageType: messageType,
            messageId: e.id.toString(),
            isPending: false,
            isFromSender:
                sharedPreferences!.getString("id").toString() == "null"
                    ? "${e.senderId}" ==
                        sharedPreferences!.getString("idGust").toString()
                    : "${e.senderId}" ==
                        sharedPreferences!.getString("id").toString(),
            timestamp:
                DateFormat('h:mm a').format(DateTime.parse(e.createdAt!)),
          );
        }).toList();

        if (page == 1) {
          messages.clear();
          messages.addAll(newChatMessages);
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
    var response;
    log(imgFile.toString());
    log(audioFile.toString());
    if (imgFile != null || audioFile != null) {
      response = await _chatsRemoteData.sendMessagesWithFile(
        chatId: chatId,
        audio: audioFile,
        image: imgFile,
        tokenDevice: sharedPreferences!.getString("deviceId"),
        token: sharedPreferences!.getString("token"),
      );
    } else {
      response = await _chatsRemoteData.sendMessages(
        chatId: chatId,
        message: text ?? '',
        tokenDevice: sharedPreferences!.getString("deviceId"),
        token: sharedPreferences!.getString("token"),
      );
    }

    log(response.toString());

    statuesRequest = handlingData(response);
    if (statuesRequest == StatuesRequest.success) {
      if (response['code'] == 403) {
        messageError(
            S.of(Get.context!).warning, S.of(Get.context!).waitForAccept);
      } else {
        if (sharedPreferences!.getString("id").toString() == "null") {
          if (sharedPreferences!.getString("idGust").toString() == "null") {
            sharedPreferences!
                .setString("idGust", response['data']['sender_id'].toString());
          }
        }
        if (sharedPreferences!.getString("username").toString() == "null") {
          if (sharedPreferences!.getString("usernameGust").toString() ==
              "null") {
            sharedPreferences!.setString(
                "usernameGust", response['data']['sender_name'].toString());
          }
        }

        int indexToUpdate =
            messages.indexWhere((msg) => msg.messageId == tempId);

        if (indexToUpdate != -1) {
          log(response.toString());
          String messageContent = response['data']['message'] ?? '';
          String finalMessage = messageContent;
          String messageTypeFromResponse =
              response['data']['message_type'] ?? messageType;

          if (messageTypeFromResponse == 'image' ||
              messageTypeFromResponse == 'voice') {
            finalMessage = messageContent;
          }

          messages[indexToUpdate] = ChatMessage(
            imageUrl: messages[indexToUpdate].imageUrl == "null"
                ? response['data']['sender_image']
                : messages[indexToUpdate].imageUrl,
            senderName: messages[indexToUpdate].senderName == ""
                ? response['data']['sender_name']
                : messages[indexToUpdate].senderName,
            reaction: messages[indexToUpdate].reaction,
            message: finalMessage,
            messageType: messageTypeFromResponse,
            messageId: response['data']['id'].toString(),
            isFromSender: true,
            isPending: false,
            timestamp: messages[indexToUpdate].timestamp,
          );
          messages.refresh();
        }
      }
    } else if (statuesRequest == StatuesRequest.forbiddenException) {
      messageError(S.of(Get.context!).warning, S.of(Get.context!).waitAccept);
      messages.removeWhere((msg) => msg.messageId == tempId);
      messages.refresh();
    } else {
      messages.removeWhere((msg) => msg.messageId == tempId);
      messages.refresh();
                showUserFriendlyError(statuesRequest);

    }

    update();
  }

  Future<void> sendTextMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.insert(
        0,
        ChatMessage(
          imageUrl: "null",
          reaction: [],
          senderName: sharedPreferences!.getString("username") ??
              sharedPreferences!.getString("usernameGust") ??
              "",
          message: messageController.text.trim(),
          messageType: 'text',
          messageId: tempId,
          isFromSender: true,
          isPending: false,
          timestamp: DateFormat('h:mm a').format(DateTime.now()),
        ),
      );
      String text = messageController.text;
      messageController.clear();
      await sendMessage(text: text, messageType: 'text', tempId: tempId);
    }
  }

  Future<void> sendImageMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.insert(
        0,
        ChatMessage(
          imageUrl: "null",
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
        ),
      );
      await sendMessage(imgFile: file, messageType: 'image', tempId: tempId);
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
      update();
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder!.stopRecorder();
      isRecording = false;
      if (path != null && await File(path!).exists()) {
        await File(path!).delete(); // Delete temporary file
      }
      path = null;
      update();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
      Get.snackbar('Error', 'Failed to cancel recording');
    }
  }

  Future<void> stopRecording() async {
    String? path = await _recorder!.stopRecorder();
    if (path == null || path.isEmpty) {
      log('Error: Recorder returned null or empty path');
      return; // Handle the error gracefully
    }

    isRecording = false;
    update();

    File file = File(path);
    if (!await file.exists()) {
      log('Error: Audio file does not exist at path: $path');
      return; // Handle the error gracefully
    }

    log('Audio file path: $path');
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    messages.insert(
      0,
      ChatMessage(
        imageUrl: "null",
        reaction: [],
        senderName: sharedPreferences!.getString("username") ??
            sharedPreferences!.getString("usernameGust") ??
            "",
        message: path,
        messageType: 'voice',
        messageId: tempId,
        isFromSender: true,
        isPending: true,
        timestamp: DateFormat('h:mm a').format(DateTime.now()),
      ),
    );
    await sendMessage(audioFile: file, messageType: 'audio', tempId: tempId);
  }

  reactMessage({required String messageId, required String react}) async {
    var response = await _chatsRemoteData.sendReactMessages(
        messageId: int.parse(messageId),
        react: react,
        tokenDevice: sharedPreferences!.getString("deviceId"),
        token: sharedPreferences!.getString("token") ?? "");

    statuesRequest = handlingData(response);
    if (statuesRequest == StatuesRequest.success) {
      final messageIndex =
          messages.indexWhere((msg) => msg.messageId == messageId);

      if (messageIndex != -1) {
        final reactionIndex = messages[messageIndex]
            .reaction
            .indexWhere((reaction) => reaction.id == null);

        if (reactionIndex != -1) {
          if (statuesRequest == StatuesRequest.success) {
            messages[messageIndex].reaction[reactionIndex].id =
                response['data']['id'];
            messages[messageIndex].reaction[reactionIndex].user!.id =
                response['data']['user']['id'];
            messages[messageIndex].reaction[reactionIndex].user!.username =
                response['data']['user']['username'];
          } else {
            messages[messageIndex].reaction.removeAt(reactionIndex);
                    showUserFriendlyError(statuesRequest);

          
          }
        }

        messages.refresh();
      }
    }else{
                showUserFriendlyError(statuesRequest);

    }
    update();
  }

  bool memberClick = true;
  changeClick(member) {
    if (member == true) {
      memberClick = true;
      if (members.isEmpty) {
        getMembers();
      }
    } else {
      memberClick = false;
      if (memmbersRequests.isEmpty) {
        getMembers();
      }
    }
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
      token: sharedPreferences!.getString("token"),
    );

    statuesRequestMembers = handlingData(response);

    if (statuesRequestMembers == StatuesRequest.success) {
      List responseBody = response['data'];
      log("members ::::: ${responseBody.toString()}");

      if (responseBody.length > 1) {
        memberIdToBlock.addAll(responseBody
            .map((e) => MemberOfChatModel.fromJson(e))
            .where((element) =>
                element.id.toString() != sharedPreferences!.getString("id")));
      } else {
        memberIdToBlock
            .addAll(responseBody.map((e) => MemberOfChatModel.fromJson(e)));
      }
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

    if (memberClick) {
      if (isLoadingMoreMembers || !hasMoreMembers) return;
      if (loadMore) {
        isLoadingMoreMembers = true;
      } else {
        statuesRequestMembers = StatuesRequest.loading;
      }
    } else {
      if (isLoadingMoreRequests || !hasMoreRequests) return;
      if (loadMore) {
        isLoadingMoreRequests = true;
      } else {
        statuesRequestMembers = StatuesRequest.loading;
      }
    }

    update();

    var response = await _chatsRemoteData.getMemberOfChat(
      perPage: 10,
      page: memberClick ? currentMembersPage : currentRequestsPage,
      chatId: int.parse(chatId),
      token: sharedPreferences!.getString("token"),
    );

    statuesRequestMembers = handlingData(response);

    if (statuesRequestMembers == StatuesRequest.success) {
      List responseBody = response['data'];

      if (responseBody.isEmpty) {
        if (memberClick) {
          hasMoreMembers = false;
        } else {
          hasMoreRequests = false;
        }
      } else {
        List<MemberOfChatModel> newMembers =
            responseBody.map((e) => MemberOfChatModel.fromJson(e)).toList();

        List<MemberOfChatModel> acceptedMembers = newMembers
            .where(
                (element) => element.requestStatus != "Waiting_for_acceptance")
            .toList();

        List<MemberOfChatModel> pendingRequests = newMembers
            .where(
                (element) => element.requestStatus == "Waiting_for_acceptance")
            .toList();

        if (loadMore) {
          members.addAll(acceptedMembers);
          memmbersRequests.addAll(pendingRequests);
        } else {
          members.addAll(acceptedMembers);
          memmbersRequests.addAll(pendingRequests);
        }

        if (memberClick && acceptedMembers.isNotEmpty) {
          currentMembersPage++;
        } else if (!memberClick && pendingRequests.isNotEmpty) {
          currentRequestsPage++;
        }

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
      if (memberClick) {
        hasMoreMembers = false;
      } else {
        hasMoreRequests = false;
      }
    }

    isLoadingMoreMembers = false;
    isLoadingMoreRequests = false;
    update();
  }

  Future<void> loadMoreMembers() async {
    if (memberClick) {
      if (!hasMoreMembers || isLoadingMoreMembers) return;
    } else {
      if (!hasMoreRequests || isLoadingMoreRequests) return;
    }

    await getMembers(
        page: memberClick ? currentMembersPage : currentRequestsPage,
        loadMore: true);
  }

  sendFriendRequest({required friendID}) async {
    var response = await _chatsRemoteData.sendFriendRequest(
        friendId: friendID, token: sharedPreferences!.getString("token"));

    statuesRequestMembers = handlingData(response);

    update();
  }

  blockOrUnBlock({required friendID, required bool  status}) async {
    var response = await _chatsRemoteData.blockOrUnBlock(
        status: status,
        id: friendID,
        token: sharedPreferences!.getString("token"));

    statuesRequestMembers = handlingData(response);

    if (statuesRequestMembers == StatuesRequest.success) {
      update();
    }

    update();
  }

  createChatFriend({required friendID}) async {
    statuesRequest = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.createChatFriend(
        friendId: friendID, token: sharedPreferences!.getString("token"));
    statuesRequest = handlingData(response);

    if (statuesRequest == StatuesRequest.success) {
      final responseBody = response['data'];
      navigateToChats(userchat: UserChatModel.fromJson(responseBody));
    }else{
                showUserFriendlyError(statuesRequest);

    }

    update();
  }

  void navigateToChats({UserChatModel? userchat}) {
    chatId = '';
    messages.clear();
    Get.to(
      () => ChatViewFriend(
        isGust: false,
        isPin: false,
        userChatModel: userchat,
      ),
      arguments: {"chatId": userchat!.id.toString()},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    Get.forceAppUpdate();
  }

  acceptNeedTochat({required membeerId}) async {
    statuesRequestMembers = StatuesRequest.loading;
    update();
    var response = await _chatsRemoteData.acceptMemberToChat(
        chatID: chatId,
        idUSer: membeerId,
        token: sharedPreferences!.getString("token"));

    statuesRequestMembers = handlingData(response);

    update();
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
      music1 = false;
      music2 = false;
      music3 = false;

      currentRadioIndex = radioIndex;
      isRadioPlaying = true;
      currentlyPlaying = radios[radioIndex].radioUrl; // تعيين الرابط الحالي
      final radioUrl = radios[radioIndex].radioUrl;
      debugPrint('🎵 Playing radio: $radioUrl');

      // Check if URL is HTTP
      if (radioUrl.startsWith('http://')) {
        debugPrint('⚠️ Warning: Using HTTP connection. Consider HTTPS.');
      }

      await audioPlayer.setUrl(radioUrl);
      await audioPlayer.play();

      update();
    } catch (e) {
      debugPrint('❌ Radio playback error: $e');

      isRadioPlaying = false;
      currentRadioIndex = null;

      // Show error to user
      if (Get.context != null) {
        Get.snackbar(
          'Playback Error',
          'Unable to play radio. Please check your internet connection.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      update();
    }
  }

  Future<void> stopRadio() async {
    try {
      await audioPlayer.stop();
      isRadioPlaying = false;
      currentRadioIndex = null;
      update();
    } catch (e) {
      log(e.toString());
    }
  }

  void addReactionToMessage(
      int messageIndex, String reaction, String messageId) {
    if (messageIndex >= 0 && messageIndex < messages.length) {
      final currentUserIdStr = sharedPreferences!.getString("id") ??
          sharedPreferences!.getString("idGust") ??
          "0";
      final currentUserId = int.tryParse(currentUserIdStr) ?? 0;

      final existingReactionIndex = messages[messageIndex].reaction.indexWhere(
          (reactionItem) =>
              reactionItem.user!.id.toString() == currentUserId.toString());

      if (existingReactionIndex != -1) {
        final existingReaction =
            messages[messageIndex].reaction[existingReactionIndex];
        if (existingReaction.react == reaction) {
          messages[messageIndex].reaction.removeAt(existingReactionIndex);
        } else {
          messages[messageIndex].reaction[existingReactionIndex] =
              MessageReactions(
            react: reaction,
            id: existingReaction.id,
            user: existingReaction.user,
          );
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

  shareChat({required String link}) {
    SharePlus.instance.share(ShareParams(uri: Uri.parse(link)));
  }
}
