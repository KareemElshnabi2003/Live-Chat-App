import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

// Agora Configuration Class
class AgoraConfig {
  static const String appId = "ecf6da5484bc41b5ab1063f200587588";
}

// Participant Model
class Participant {
  final int uid;
  String name;
  final RxBool isMuted;
  final RxBool isSpeaking;
  final DateTime joinedAt;

  Participant({
    required this.uid,
    required this.name,
    bool isMuted = false,
    bool isSpeaking = false,
  })  : isMuted = RxBool(isMuted),
        isSpeaking = RxBool(isSpeaking),
        joinedAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'isMuted': isMuted.value,
      'isSpeaking': isSpeaking.value,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class AudioCallController extends GetxController {
  static String get appId => AgoraConfig.appId;
  static String token = '';
  static String channelName = '';
  static String chatId = '';
  static int? uId;

  // Observables
  final Rx<int?> remoteUid = Rx<int?>(null);
  final RxBool localUserJoined = false.obs;
  final RxBool isJoined = false.obs;
  final RxBool audioEnabled = false.obs;
  final RxBool isMuted = false.obs;
  final RxBool speakerEnabled = false.obs;
  final RxString permissionStatus = 'Checking permissions...'.obs;
  final RxBool isInitializing = true.obs;
  final RxInt tokenExpirationTime = 0.obs;

  // Group call observables
  final RxBool isGroupCall = false.obs;
  final RxList<Participant> participantsList = <Participant>[].obs;
  final RxBool isSpeaking = false.obs;
  final RxInt activeSpeakerUid = 0.obs;
  final RxMap<int, int> userVolumeMap = <int, int>{}.obs;

  // User names
  final RxString localUserName = 'You'.obs;
  final RxString remoteUserName = 'User'.obs;
  final RxMap<int, String> userNamesMap = <int, String>{}.obs;

  // Private Members
  RtcEngine? _engine;
  static const int volumeThreshold = 30;
  bool _isDisposed = false;
  final ChatsRemoteData _chatsRemoteData =
      ChatsRemoteData(api: Get.find<Api>());
  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;

    token = Get.arguments?['Token'] ?? '';
    uId = Get.arguments?['UId'];
    channelName = Get.arguments?['ChannelName'] ?? '';
    isGroupCall.value = Get.arguments?['IsGroupCall'] ?? false;
    chatId = Get.arguments?['chatId'] ?? '';
    localUserName.value = Get.arguments?['LocalUserName'] ?? 'You';
    remoteUserName.value = Get.arguments?['RemoteUserName'] ?? 'User';

    final Map<dynamic, dynamic>? namesMap = Get.arguments?['UserNamesMap'];
    if (namesMap != null) {
      userNamesMap.value = namesMap.map(
        (key, value) => MapEntry(int.parse(key.toString()), value.toString()),
      );
    }

    log('''
token: $token,
uid: $uId,
channelName: $channelName,
isGroupCall: ${isGroupCall.value},
chatId: $chatId,
localUserName: ${localUserName.value},
remoteUserName: ${remoteUserName.value},
userNamesMap: ${userNamesMap.toString()}
''');

    _initializeCall();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _disposeEngine();
    super.onClose();
  }

  void _safeUpdate(void Function() updateFn) {
    if (!_isDisposed && Get.isRegistered<AudioCallController>()) {
      updateFn();
      update();
    }
  }

  // Add this method to fetch conversation users
  Future<void> fetchConversationUsers() async {
    if (chatId.isEmpty) {
      log('⚠️ Cannot fetch conversation users: chatId is empty');
      return;
    }
    try {
      log('🔄 Fetching conversation users for chat: $chatId');

      var response = await _chatsRemoteData.getConversationUsers(
        chatId: int.parse(chatId),
      );

      if (response['status'] == 'success') {
        List<dynamic> usersData = response['data'];
        log('✅ Fetched ${usersData.length} conversation users');

        // Update the user names map with the API data
        for (var userData in usersData) {
          final uid = int.parse(userData['uid'].toString());
          final username = userData['username'] ?? 'User';
          userNamesMap[uid] = username;

          // Also update existing participants with proper names
          final participant =
              participantsList.firstWhereOrNull((p) => p.uid == uid);
          if (participant != null) {
            participant.name = username;
          }
        }

        participantsList.refresh();
        update();
      } else {
        log('❌ Failed to fetch conversation users: ${response['message']}');
      }
    } catch (e) {
      log('❌ Error fetching conversation users: $e');
    }
  }

  String getUserName(int uid) {
    // First check if we have the name in our map (from API)
    if (userNamesMap.containsKey(uid)) {
      return userNamesMap[uid]!;
    }

    // For local user
    if (uid == uId) {
      return localUserName.value;
    }

    // For remote users before API data is fetched
    // Check if we have a temporary name from initial arguments
    if (userNamesMap.isNotEmpty) {
      return userNamesMap[uid] ?? 'User $uid';
    }

    // Final fallback
    return 'User $uid';
  }

  Future<void> _initializeCall() async {
    try {
      if (appId.isEmpty) throw Exception('Agora App ID is not configured');
      if (token.isEmpty) throw Exception('Agora token is required');
      if (channelName.isEmpty) throw Exception('Channel name is required');

      debugPrint('📱 Initializing call with:');
      debugPrint('  - App ID: ${appId.substring(0, 8)}...');
      debugPrint('  - Channel: $channelName');
      debugPrint('  - UID: $uId');
      debugPrint('  - Group Call: ${isGroupCall.value}');
      debugPrint('  - Local User Name: ${localUserName.value}');
      debugPrint('  - Remote User Name: ${remoteUserName.value}');
      debugPrint('  - User Names Map: ${userNamesMap.toString()}');

      await _checkPermissions();
    } catch (e) {
      debugPrint('Initialization error: $e');
      _safeUpdate(() {
        permissionStatus.value = 'Initialization error: $e';
        isInitializing.value = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    try {
      var micStatus = await Permission.microphone.status;
      _safeUpdate(
        () => permissionStatus.value = 'Microphone: ${micStatus.name}',
      );
      debugPrint('Initial Microphone Permission: ${micStatus.name}');

      if (!micStatus.isGranted) {
        PermissionStatus status = await Permission.microphone.request();
        debugPrint('Microphone permission request result: ${status.name}');
        _safeUpdate(
          () => permissionStatus.value =
              'After request - Microphone: ${status.name}',
        );
        micStatus = status;
      }

      if (micStatus.isGranted) {
        await _initializeAgora();
      } else {
        _safeUpdate(() {
          permissionStatus.value =
              'Microphone permission denied! Please enable in settings.';
          isInitializing.value = false;
        });
        if (Get.context != null && Get.context!.mounted) {
          _showPermissionDialog(Get.context!);
        }
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      _safeUpdate(() {
        permissionStatus.value = 'Permission error: $e';
        isInitializing.value = false;
      });
    }
  }

  Future<void> _initializeAgora() async {
    try {
      _safeUpdate(() => permissionStatus.value = 'Initializing Agora...');

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: isGroupCall.value
              ? ChannelProfileType.channelProfileLiveBroadcasting
              : ChannelProfileType.channelProfileCommunication,
        ),
      );

      await _configureAudioSettings();
      _registerEventHandlers();
      await _joinChannel();
    } catch (e) {
      debugPrint('❌ AGORA INIT ERROR: $e');
      _safeUpdate(() {
        permissionStatus.value = 'Agora initialization error: $e';
        isInitializing.value = false;
      });
    }
  }

  Future<void> _configureAudioSettings() async {
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    await _engine!
        .enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);
    await _engine!.enableAudio();
  }

  void _registerEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: _onJoinChannelSuccess,
        onUserJoined: _onUserJoined,
        onUserOffline: _onUserOffline,
        onLocalAudioStateChanged: _onLocalAudioStateChanged,
        onRemoteAudioStateChanged: _onRemoteAudioStateChanged,
        onError: _onError,
        onAudioVolumeIndication: _onAudioVolumeIndication,
        onActiveSpeaker: _onActiveSpeaker,
        onTokenPrivilegeWillExpire: _onTokenPrivilegeWillExpire,
      ),
    );
  }

  Future<void> _joinChannel() async {
    debugPrint('🔗 Joining audio channel: $channelName');
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uId!,
      options: ChannelMediaOptions(
        channelProfile: isGroupCall.value
            ? ChannelProfileType.channelProfileLiveBroadcasting
            : ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: false,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: false,
      ),
    );

    _safeUpdate(() => permissionStatus.value = 'Joining audio channel...');
  }

  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    debugPrint('✅ JOIN SUCCESS: local user ${connection.localUid} joined');
    _safeUpdate(() {
      localUserJoined.value = true;
      isJoined.value = true;
      isInitializing.value = false;
      permissionStatus.value = 'Connected! Local UID: ${connection.localUid}';
      // Add local user to participants for group calls
      if (isGroupCall.value && !participantsList.any((p) => p.uid == uId)) {
        participantsList.add(
          Participant(uid: uId!, name: localUserName.value),
        );
      }
    });
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    final userName = getUserName(remoteUid);
    debugPrint('✅ REMOTE USER JOINED: $remoteUid, Name: $userName');

    _safeUpdate(() {
      if (isGroupCall.value) {
        if (!participantsList.any((p) => p.uid == remoteUid)) {
          participantsList.add(
            Participant(uid: remoteUid, name: userName),
          );
          debugPrint('👥 Total participants: ${participantsList.length}');

          // Fetch conversation users when someone joins (only for group calls)
          if (isGroupCall.value) {
            _fetchUsersAfterJoin();
          }
        }
      } else {
        this.remoteUid.value = remoteUid;
        if (remoteUserName.value == 'User' || remoteUserName.value.isEmpty) {
          remoteUserName.value = userName;
        }
      }
    });
  }

  // Add this method to handle delayed fetching
  void _fetchUsersAfterJoin() {
    // Wait a moment for the user to fully join, then fetch conversation data
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isDisposed && isJoined.value) {
        fetchConversationUsers();
      }
    });
  }

  void _onUserOffline(
      RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
    debugPrint(
        '❌ REMOTE USER LEFT: $remoteUid, Name: ${getUserName(remoteUid)}, reason: ${reason.name}');
    _safeUpdate(() {
      if (isGroupCall.value) {
        participantsList.removeWhere((p) => p.uid == remoteUid);
        userVolumeMap.remove(remoteUid);
        debugPrint('👥 Remaining participants: ${participantsList.length}');
      } else {
        this.remoteUid.value = null;
      }
    });
  }

  void _onLocalAudioStateChanged(RtcConnection connection,
      LocalAudioStreamState state, LocalAudioStreamReason error) {
    debugPrint(
        '🎤 LOCAL AUDIO STATE: state: ${state.name}, error: ${error.name}');
    _safeUpdate(() {
      audioEnabled.value =
          state == LocalAudioStreamState.localAudioStreamStateRecording ||
              state == LocalAudioStreamState.localAudioStreamStateEncoding;
      if (isGroupCall.value) {
        final participant =
            participantsList.firstWhereOrNull((p) => p.uid == uId);
        if (participant != null) {
          participant.isMuted.value = isMuted.value;
        }
      }
    });
  }

  void _onRemoteAudioStateChanged(RtcConnection connection, int remoteUid,
      RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
    debugPrint(
        '🔊 REMOTE AUDIO STATE CHANGED: uid: $remoteUid, state: ${state.name}, reason: ${reason.name}');
    _safeUpdate(() {
      if (isGroupCall.value) {
        final participant =
            participantsList.firstWhereOrNull((p) => p.uid == remoteUid);
        participant?.isMuted.value =
            state == RemoteAudioState.remoteAudioStateStopped;
      }
    });
  }

  void _onError(ErrorCodeType err, String msg) {
    debugPrint('❌ AGORA ERROR: $err, $msg');
    _safeUpdate(() {
      if (err == ErrorCodeType.errInvalidToken) {
        permissionStatus.value =
            'Token expired! Generate a new token from Agora Console';
      } else {
        permissionStatus.value = 'Agora Error: $err - $msg';
      }
      isInitializing.value = false;
    });
  }

  void _onAudioVolumeIndication(RtcConnection connection,
      List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
    _safeUpdate(() {
      for (var speaker in speakers) {
        final volume = speaker.volume ?? 0;
        if (speaker.uid == 0) {
          isSpeaking.value = volume > volumeThreshold;
          debugPrint(
              '🎤 Local volume: $volume (speaking: ${isSpeaking.value})');
        } else {
          userVolumeMap[speaker.uid!] = volume;
          if (isGroupCall.value) {
            final participant =
                participantsList.firstWhereOrNull((p) => p.uid == speaker.uid);
            participant?.isSpeaking.value = volume > volumeThreshold;
            debugPrint(
                '🔊 Remote user ${speaker.uid} (${getUserName(speaker.uid!)}) volume: $volume (speaking: ${participant?.isSpeaking.value})');
          }
        }
      }
    });
  }

  void _onActiveSpeaker(RtcConnection connection, int uid) {
    debugPrint('🗣️ ACTIVE SPEAKER: $uid, Name: ${getUserName(uid)}');
    _safeUpdate(() => activeSpeakerUid.value = uid);
  }

  void _onTokenPrivilegeWillExpire(RtcConnection connection, String token) {
    debugPrint('⚠️ TOKEN WILL EXPIRE SOON! Please renew token.');
    _safeUpdate(
        () => permissionStatus.value = 'Token expiring soon - please renew!');
  }

  Future<void> toggleMute() async {
    if (_engine != null && !_isDisposed) {
      try {
        _safeUpdate(() => isMuted.value = !isMuted.value);
        await _engine!.muteLocalAudioStream(isMuted.value);
        debugPrint('🎤 Audio ${isMuted.value ? 'MUTED' : 'UNMUTED'}');
        if (isGroupCall.value) {
          final participant =
              participantsList.firstWhereOrNull((p) => p.uid == uId);
          if (participant != null) {
            participant.isMuted.value = isMuted.value;
          }
        }
      } catch (e) {
        debugPrint('Toggle mute error: $e');
        _safeUpdate(() => isMuted.value = !isMuted.value);
      }
    }
  }

  Future<void> toggleSpeaker() async {
    if (_engine != null && !_isDisposed) {
      try {
        _safeUpdate(() => speakerEnabled.value = !speakerEnabled.value);
        await _engine!.setEnableSpeakerphone(speakerEnabled.value);
        debugPrint(
            '🔊 Speaker ${speakerEnabled.value ? 'ENABLED' : 'DISABLED'}');
      } catch (e) {
        debugPrint('Toggle speaker error: $e');
        _safeUpdate(() => speakerEnabled.value = !speakerEnabled.value);
      }
    }
  }

  // Add this method for manual refresh
  Future<void> refreshUserNames() async {
    if (isGroupCall.value) {
      await fetchConversationUsers();

      if (Get.context != null && Get.context!.mounted) {
        Get.snackbar(
          'Updated',
          'User names refreshed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> addParticipant() async {
    if (!isGroupCall.value || _isDisposed) {
      debugPrint('⚠️ Cannot add participants in single call mode or disposed');
      return;
    }
    if (Get.context != null && Get.context!.mounted) {
      Get.snackbar(
        'Add Participant',
        'Invite link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> muteParticipant(int uid, bool mute) async {
    if (_engine != null && isGroupCall.value && !_isDisposed) {
      try {
        await _engine!.muteRemoteAudioStream(uid: uid, mute: mute);
        _safeUpdate(() {
          final participant =
              participantsList.firstWhereOrNull((p) => p.uid == uid);
          participant?.isMuted.value = mute;
        });
        debugPrint(
            '${mute ? 'MUTED' : 'UNMUTED'} participant $uid (${getUserName(uid)})');
      } catch (e) {
        debugPrint('Mute participant error: $e');
      }
    }
  }

  Future<void> removeParticipant(int uid) async {
    if (_isDisposed) return;
    debugPrint('⚠️ Remove participant feature requires server implementation');
    if (Get.context != null && Get.context!.mounted) {
      Get.snackbar(
        'Remove Participant',
        'This feature requires server-side implementation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> switchCallMode(bool toGroupCall) async {
    if (_isDisposed) return;
    if (isJoined.value) {
      if (Get.context != null && Get.context!.mounted) {
        Get.snackbar(
          'Mode Switch',
          'Please end the current call to switch modes',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      return;
    }
    _safeUpdate(() => isGroupCall.value = toGroupCall);
    debugPrint('📞 Call mode switched to: ${toGroupCall ? 'GROUP' : 'SINGLE'}');
  }

  Future<void> endCall() async {
    if (_isDisposed) return;

    // Count OTHER participants (excluding myself)
    int otherParticipantsCount = 0;

    if (isGroupCall.value) {
      // In group call, count all participants except the current user
      otherParticipantsCount =
          participantsList.where((p) => p.uid != uId).length;
    } else {
      // In one-on-one call, check if remote user is still connected
      otherParticipantsCount = remoteUid.value != null ? 1 : 0;
    }

    debugPrint(
        '🔚 Ending call - Other participants count: $otherParticipantsCount');
    debugPrint('🔚 Is group call: ${isGroupCall.value}');
    debugPrint('🔚 Total participants: ${participantsList.length}');
    debugPrint('🔚 Current UID: $uId');

    // Only call endCallApi if I'm the last one in the call
    bool isLastParticipant = otherParticipantsCount == 0;

    if (isLastParticipant) {
      debugPrint('✅ Last participant leaving - calling endCallApi');
      await endCallApi();
    } else {
      debugPrint('⏭️ Not last participant - skipping endCallApi');
    }

    await _disposeEngine();

    if (!_isDisposed && Get.context != null && Get.context!.mounted) {
      Get.back();
    }
  }

  StatuesRequest statuesRequest = StatuesRequest.none;

  Future<void> endCallApi() async {
    if (chatId.isEmpty) {
      log('⚠️ Cannot end call: chatId is empty');
      return;
    }
    log('🔚 Calling endCallApi - I am the last participant');
    _safeUpdate(() => statuesRequest = StatuesRequest.loading);

    try {
      var response = await _chatsRemoteData.endCall(id: chatId);
      log('📞 End call response: ${response.toString()}');

      _safeUpdate(() {
        statuesRequest = handlingData(response);
        if (statuesRequest == StatuesRequest.success) {
          log('✅ End call successful >>> ${response['data']} <<<');
          if (Get.isRegistered<ChatController>()) {
            Get.find<ChatController>().sendSystemMessage(isGroupCall.value ? "|||GROUP_CALL_ENDED|||" : "|||CALL_ENDED|||");
          } else {
            _chatsRemoteData.sendMessages(
                chatId: chatId, 
                message: isGroupCall.value ? "|||GROUP_CALL_ENDED|||" : "|||CALL_ENDED|||"
            );
          }
          final responseBody = response['data'];
          if (responseBody != null) {
            log('📊 End call data >>> ${response['data']} <<<');
          } else {
            log('⚠️ End call data is null');
          }
        } else {
          showUserFriendlyError(statuesRequest);
        }
        //  else if (statuesRequest == StatuesRequest.socketException) {
        //   log('❌ Socket exception when ending call');
        // } else if (statuesRequest == StatuesRequest.unprocessableException) {
        //   log('❌ Unprocessable exception: ${response["error"]["message"]}');
        // } else {
        //   log('❌ Failed to end call: $statuesRequest');
        // }
      });
    } catch (e) {
      log('❌ Exception in endCallApi: $e');
      _safeUpdate(() => statuesRequest = StatuesRequest.serverException);
    }
  }

  void _showPermissionDialog(BuildContext context) {
    if (_isDisposed || !context.mounted) return;
    Get.dialog(
      AlertDialog(
        title: Text(S.of(context).microphonePermissionRequired),
        content: Text(S.of(context).permissionRequiredMessage),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text(S.of(context).openSettings),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(S.of(context).cancel),
          ),
        ],
      ),
    );
  }

  Future<void> retryConnection() async {
    if (_isDisposed) return;
    _safeUpdate(() {
      isInitializing.value = true;
      permissionStatus.value = 'Retrying connection...';
    });
    await _initializeCall();
  }

  Future<void> _disposeEngine() async {
    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
        debugPrint('✅ Engine disposed successfully');
      } catch (e) {
        debugPrint('Engine disposal error: $e');
      }
    }

    _safeUpdate(() {
      participantsList.clear();
      userVolumeMap.clear();
      localUserJoined.value = false;
      isJoined.value = false;
    });
  }

  bool get isConnected =>
      !_isDisposed &&
      localUserJoined.value &&
      (isGroupCall.value
          ? participantsList.isNotEmpty
          : remoteUid.value != null);

  bool get isWaiting =>
      !_isDisposed &&
      isJoined.value &&
      (isGroupCall.value ? participantsList.isEmpty : remoteUid.value == null);

  bool get hasError =>
      !_isDisposed &&
      (permissionStatus.value.contains('error') ||
          permissionStatus.value.contains('denied') ||
          permissionStatus.value.contains('Error'));

  String get statusText {
    if (_isDisposed) return 'Call ended';
    if (isGroupCall.value) {
      if (participantsList.isEmpty) {
        return 'Waiting for others to join...';
      } else {
        return '${participantsList.length} ${S.of(Get.context!).participantsincall}';
      }
    } else {
      if (remoteUid.value != null) {
        return 'In call with ${remoteUserName.value}';
      } else if (isJoined.value) {
        return 'Waiting for ${remoteUserName.value} to join...';
      } else {
        return 'Connecting...';
      }
    }
  }

  List<Map<String, dynamic>> get participants =>
      _isDisposed ? [] : participantsList.map((p) => p.toMap()).toList();

  int get participantCount => _isDisposed ? 0 : participantsList.length;

  Map<String, dynamic> get debugInfo => _isDisposed
      ? {}
      : {
          'appId': '${appId.substring(0, 8)}...',
          'channelName': channelName,
          'uId': uId,
          'isGroupCall': isGroupCall.value,
          'participantCount': participantCount,
          'isConnected': isConnected,
          'isWaiting': isWaiting,
          'hasError': hasError,
          'localUserName': localUserName.value,
          'remoteUserName': remoteUserName.value,
          'userNamesMap': userNamesMap.toString(),
        };
}
