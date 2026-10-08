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
import 'package:permission_handler/permission_handler.dart';

// Agora Configuration Class
class AgoraConfig {
  static const String appId = "ecf6da5484bc41b5ab1063f200587588";
}

class VideoCallController extends GetxController {
  static String get appId => AgoraConfig.appId;
  static String token = '';
  static String channelName = "";
  static String chatId = "";
  bool isGroubCall = false;
  static int? uId;

  // User name properties
  String localUserName = '';
  String? remoteUserName;
  final RxMap<int, String> userNamesMap = <int, String>{}.obs;

  // Core observables
  final RxList<int> _remoteUsers = <int>[].obs;
  final RxMap<int, bool> _remoteVideoStates = <int, bool>{}.obs;
  final RxBool _localUserJoined = false.obs;
  final RxBool _isJoined = false.obs;
  final RxBool _cameraEnabled = false.obs;
  final RxBool _audioEnabled = false.obs;
  final RxBool _isMuted = false.obs;
  final RxBool _isVideoStopped = false.obs;
  final RxString _permissionStatus = "Checking permissions...".obs;
  final RxBool _isInitializing = true.obs;
  final RxString _networkQuality = "Unknown".obs;

  // Private variables
  RtcEngine? _engine;
  Worker? _statusWorker;
  bool _isDisposed = false;

  // Track if user manually ended the call (not disconnected)
  bool _userEndedCall = false;

  // التعديل هنا: استخدام Get.find
  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.find<Api>());
  StatuesRequest statuesRequest = StatuesRequest.none;

  // Getters
  List<int> get remoteUsers => _remoteUsers;
  int get remoteUserCount => _remoteUsers.length;
  bool get localUserJoined => _localUserJoined.value;
  bool get isJoined => _isJoined.value;
  bool get cameraEnabled => _cameraEnabled.value;
  bool get audioEnabled => _audioEnabled.value;
  bool get isMuted => _isMuted.value;
  bool get isVideoStopped => _isVideoStopped.value;
  String get permissionStatus => _permissionStatus.value;
  bool get isInitializing => _isInitializing.value;
  String get networkQuality => _networkQuality.value;
  bool isRemoteVideoEnabled(int uid) => _remoteVideoStates[uid] ?? true;
  bool get isConnected => _localUserJoined.value && _remoteUsers.isNotEmpty;
  bool get isWaiting => _isJoined.value && _remoteUsers.isEmpty;
  bool get hasError =>
      _permissionStatus.value.contains('error') ||
          _permissionStatus.value.contains('denied') ||
          _permissionStatus.value.contains('Error');
  bool get canSwitchCamera => _cameraEnabled.value && !_isVideoStopped.value;

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;
    _userEndedCall = false;
    token = Get.arguments?["Token"] ?? '';
    isGroubCall = Get.arguments?["IsGroupCall"] ?? false;
    uId = Get.arguments?["UId"];
    channelName = Get.arguments?["ChannelName"] ?? '';
    chatId = Get.arguments?['chatId'] ?? '';
    localUserName = Get.arguments?['LocalUserName'] ?? 'You';
    remoteUserName = Get.arguments?['RemoteUserName'];

    final map = Get.arguments?['UserNamesMap'] as Map<dynamic, dynamic>?;
    if (map != null) {
      userNamesMap.assignAll(map.map((key, value) =>
          MapEntry(int.parse(key.toString()), value.toString())));
    }

    debugPrint("📹 Initializing with:");
    debugPrint("  - LocalUserName: $localUserName");
    debugPrint("  - RemoteUserName: $remoteUserName");
    debugPrint("  - IsGroupCall: $isGroubCall");
    debugPrint("  - UserNamesMap: $userNamesMap");

    _initializeVideoCall();
    _setupWorkers();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _statusWorker?.dispose();
    _disposeEngine();
    super.onClose();
  }

  String getUserName(int uid) {
    if (uid == 0 || uid == uId) {
      return localUserName;
    }
    return userNamesMap[uid] ?? remoteUserName ?? 'User $uid';
  }

  void _setupWorkers() {
    _statusWorker = debounce(
      _permissionStatus,
          (status) => debugPrint("Status updated: $status"),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> _initializeVideoCall() async {
    try {
      if (appId.isEmpty) throw Exception("Agora App ID is not configured");
      if (token.isEmpty) throw Exception("Agora token is required");
      if (channelName.isEmpty) throw Exception("Channel name is required");

      debugPrint("📹 Initializing video call with:");
      debugPrint("  - App ID: ${appId.substring(0, 8)}...");
      debugPrint("  - Channel: $channelName");
      debugPrint("  - UID: $uId");
      debugPrint("  - Local User: $localUserName");

      await _checkPermissions();
    } catch (e) {
      debugPrint("Video call initialization error: $e");
      _permissionStatus.value = "Initialization error: $e";
      _isInitializing.value = false;
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;

      _permissionStatus.value =
      "Camera: ${cameraStatus.name}, Mic: ${micStatus.name}";
      debugPrint(
          "Initial permissions - Camera: ${cameraStatus.name}, Mic: ${micStatus.name}");

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        final statuses =
        await [Permission.camera, Permission.microphone].request();
        _permissionStatus.value =
        "After request - Camera: ${statuses[Permission.camera]!.name}, Mic: ${statuses[Permission.microphone]!.name}";

        if (statuses[Permission.camera]!.isGranted &&
            statuses[Permission.microphone]!.isGranted) {
          await _initializeAgora();
        } else {
          _permissionStatus.value =
          "Permissions denied! Please enable in settings.";
          _showPermissionDialog();
        }
      } else {
        await _initializeAgora();
      }
    } catch (e) {
      debugPrint("Permission error: $e");
      _permissionStatus.value = "Permission error: $e";
      _isInitializing.value = false;
    }
  }

  Future<void> _initializeAgora() async {
    try {
      _permissionStatus.value = "Initializing Agora...";
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      await _configureMediaSettings();
      _registerEventHandlers();
      await _enableMediaAndJoin();
    } catch (e) {
      debugPrint("❌ AGORA INIT ERROR: $e");
      _permissionStatus.value = "Agora initialization error: $e";
      _isInitializing.value = false;
    }
  }

  Future<void> _configureMediaSettings() async {
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 1280, height: 720),
        frameRate: 30,
        bitrate: 2000,
        orientationMode: OrientationMode.orientationModeAdaptive,
        degradationPreference: DegradationPreference.maintainQuality,
      ),
    );
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileMusicHighQuality,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    await _engine!.enableAudioVolumeIndication(
      interval: 250,
      smooth: 3,
      reportVad: true,
    );
  }

  void _registerEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: _onJoinChannelSuccess,
        onUserJoined: _onUserJoined,
        onUserOffline: _onUserOffline,
        onLocalVideoStateChanged: _onLocalVideoStateChanged,
        onLocalAudioStateChanged: _onLocalAudioStateChanged,
        onRemoteVideoStateChanged: _onRemoteVideoStateChanged,
        onError: _onError,
        onCameraReady: _onCameraReady,
        onAudioVolumeIndication: _onAudioVolumeIndication,
        onTokenPrivilegeWillExpire: _onTokenPrivilegeWillExpire,
        onNetworkQuality: _onNetworkQuality,
        onConnectionStateChanged: _onConnectionStateChanged,
      ),
    );
  }

  Future<void> _enableMediaAndJoin() async {
    await _engine!.enableAudio();
    await _engine!.enableVideo();
    await _engine!.startPreview();
    await Future.delayed(const Duration(milliseconds: 500));
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uId!,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
    _permissionStatus.value = "Joining video channel...";
  }

  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    debugPrint("✅ JOIN SUCCESS: local user ${connection.localUid} joined");
    _batchUpdate(() {
      _localUserJoined.value = true;
      _isJoined.value = true;
      _isInitializing.value = false;
      _permissionStatus.value = "Connected! Local UID: ${connection.localUid}";
    });
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    final userName = getUserName(remoteUid);
    debugPrint("✅ REMOTE USER JOINED: $remoteUid, Name: $userName");
    _batchUpdate(() {
      if (!_remoteUsers.contains(remoteUid)) {
        _remoteUsers.add(remoteUid);
        _remoteVideoStates[remoteUid] = true;
        debugPrint("📊 Total remote users: ${_remoteUsers.length}");
      }
    });
  }

  void _onUserOffline(
      RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
    final userName = getUserName(remoteUid);
    debugPrint(
        "❌ REMOTE USER LEFT: $remoteUid, Name: $userName, reason: ${reason.name}");

    final wasLastOtherUser =
        _remoteUsers.length == 1 && _remoteUsers.contains(remoteUid);

    _batchUpdate(() {
      _remoteUsers.remove(remoteUid);
      _remoteVideoStates.remove(remoteUid);
      debugPrint("📊 Total remote users: ${_remoteUsers.length}");
    });

    if (wasLastOtherUser && !_userEndedCall && !isGroubCall) {
      debugPrint("🔚 Last remote user left - I should end the call on server");
      endCallApi();
    }
  }

  void _onLocalVideoStateChanged(VideoSourceType source,
      LocalVideoStreamState state, LocalVideoStreamReason error) {
    debugPrint(
        "📹 LOCAL VIDEO STATE: source: ${source.name}, state: ${state.name}, error: ${error.name}");
    _cameraEnabled.value =
        state == LocalVideoStreamState.localVideoStreamStateCapturing ||
            state == LocalVideoStreamState.localVideoStreamStateEncoding;
  }

  void _onLocalAudioStateChanged(RtcConnection connection,
      LocalAudioStreamState state, LocalAudioStreamReason error) {
    debugPrint(
        "🎤 LOCAL AUDIO STATE: state: ${state.name}, error: ${error.name}");
    _audioEnabled.value =
        state == LocalAudioStreamState.localAudioStreamStateRecording ||
            state == LocalAudioStreamState.localAudioStreamStateEncoding;
  }

  void _onRemoteVideoStateChanged(RtcConnection connection, int remoteUid,
      RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
    debugPrint(
        "📹 REMOTE VIDEO STATE: uid: $remoteUid, state: ${state.name}, reason: ${reason.name}");
    if (_remoteUsers.contains(remoteUid)) {
      _remoteVideoStates[remoteUid] =
          reason != RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted;
    }
  }

  void _onError(ErrorCodeType err, String msg) {
    debugPrint("❌ AGORA ERROR: $err, $msg");
    _batchUpdate(() {
      _isInitializing.value = false;
      if (err == ErrorCodeType.errInvalidToken) {
        _permissionStatus.value =
        "Token expired! Generate a new token from Agora Console";
      } else {
        _permissionStatus.value = "Agora Error: $err - $msg";
      }
    });
  }

  void _onCameraReady() {
    debugPrint("📹 CAMERA READY");
    _cameraEnabled.value = true;
  }

  void _onAudioVolumeIndication(RtcConnection connection,
      List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
    for (var speaker in speakers) {
      final speakerName =
      speaker.uid == 0 ? 'Local' : getUserName(speaker.uid!);
      debugPrint("$speakerName volume: ${speaker.volume}");
    }
  }

  void _onTokenPrivilegeWillExpire(RtcConnection connection, String token) {
    debugPrint("⚠️ TOKEN WILL EXPIRE SOON! Please renew token.");
    _permissionStatus.value = "Token expiring soon - please renew!";
  }

  void _onNetworkQuality(RtcConnection connection, int remoteUid,
      QualityType txQuality, QualityType rxQuality) {
    String quality = "Unknown";
    switch (txQuality) {
      case QualityType.qualityExcellent:
      case QualityType.qualityGood:
        quality = "Good";
        break;
      case QualityType.qualityPoor:
      case QualityType.qualityBad:
        quality = "Poor";
        break;
      case QualityType.qualityVbad:
        quality = "Very Poor";
        break;
      default:
        quality = "Unknown";
    }
    _networkQuality.value = quality;
  }

  void _onConnectionStateChanged(RtcConnection connection,
      ConnectionStateType state, ConnectionChangedReasonType reason) {
    debugPrint("🌐 Connection State: ${state.name}, Reason: ${reason.name}");
    if (state == ConnectionStateType.connectionStateDisconnected) {
      _permissionStatus.value = "Connection lost - attempting to reconnect...";
    } else if (state == ConnectionStateType.connectionStateConnected) {
      _permissionStatus.value = "Connection restored";
    }
  }

  Future<void> toggleMute() async {
    if (_engine != null && !_isDisposed) {
      try {
        _isMuted.value = !_isMuted.value;
        await _engine!.muteLocalAudioStream(_isMuted.value);
        debugPrint("🎤 Audio ${_isMuted.value ? 'MUTED' : 'UNMUTED'}");
      } catch (e) {
        debugPrint("Toggle mute error: $e");
        _isMuted.value = !_isMuted.value;
      }
    }
  }

  Future<void> toggleVideo() async {
    if (_engine != null && !_isDisposed) {
      try {
        _isVideoStopped.value = !_isVideoStopped.value;
        await _engine!.muteLocalVideoStream(_isVideoStopped.value);
        debugPrint("📹 Video ${_isVideoStopped.value ? 'STOPPED' : 'STARTED'}");
      } catch (e) {
        debugPrint("Toggle video error: $e");
        _isVideoStopped.value = !_isVideoStopped.value;
      }
    }
  }

  Future<void> switchCamera() async {
    if (_engine != null && canSwitchCamera && !_isDisposed) {
      try {
        await _engine!.switchCamera();
        debugPrint("📹 Camera switched successfully");
      } catch (e) {
        debugPrint("Camera switch error: $e");
        if (Get.context != null && Get.context!.mounted) {
          Get.snackbar(
            'Camera Error',
            'Unable to switch camera',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  Future<void> endCall() async {
    if (_isDisposed) return;

    _userEndedCall = true;

    final currentRemoteUserCount = _remoteUsers.length;
    final isOneOnOneCall = !isGroubCall;

    debugPrint('🔴 User manually ending video call:');
    debugPrint('   - Remote users count: $currentRemoteUserCount');
    debugPrint('   - Is group call: $isGroubCall');
    debugPrint('   - Is 1-on-1: $isOneOnOneCall');
    debugPrint(
        '   - Remote users: ${_remoteUsers.map((uid) => '${getUserName(uid)}($uid)').toList()}');

    bool shouldEndCall = isOneOnOneCall || currentRemoteUserCount == 0;

    debugPrint('   - Should call end API: $shouldEndCall');

    if (shouldEndCall) {
      await endCallApi();
    }

    await _disposeEngine();

    if (!_isDisposed && Get.context != null && Get.context!.mounted) {
      Get.back();
    }
  }

  Future<void> endCallApi() async {
    if (chatId.isEmpty) {
      log('⚠️ Cannot end call: chatId is empty');
      return;
    }

    try {
      log("📡 Calling end call API for chatId: $chatId");
      statuesRequest = StatuesRequest.loading;
      update();

      var response = await _chatsRemoteData.endCall(id: chatId);
      log("📥 End call API response: $response");

      statuesRequest = handlingData(response);

      if (statuesRequest == StatuesRequest.success) {
        log("✅ Call ended successfully: ${response['data']}");
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().sendSystemMessage(isGroubCall ? "|||GROUP_CALL_ENDED|||" : "|||CALL_ENDED|||");
        } else {
          _chatsRemoteData.sendMessages(
              chatId: chatId, 
              message: isGroubCall ? "|||GROUP_CALL_ENDED|||" : "|||CALL_ENDED|||"
          );
        }
        final responseBody = response['data'];
        if (responseBody != null) {
          log("   - Response data: ${response['data']}");
        } else {
          log("   - No response data");
        }
      } else{
                  showUserFriendlyError(statuesRequest);

      }

      update();
    } catch (e) {
      log("❌ Exception in endCallApi: $e");
      statuesRequest = StatuesRequest.serverException;
      update();
    }
  }

  Future<void> retryConnection() async {
    if (_isDisposed) return;
    _isInitializing.value = true;
    _permissionStatus.value = "Retrying connection...";
    await _initializeVideoCall();
  }

  void _showPermissionDialog() {
    if (Get.context != null && Get.context!.mounted && !_isDisposed) {
      Get.dialog(
        AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app needs camera and microphone permissions for video calls. Please enable them in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
          ],
        ),
      );
    }
  }

  void _batchUpdate(VoidCallback updates) {
    if (!_isDisposed) {
      updates();
      update();
    }
  }

  RtcEngine? get engine => _engine;

  String get statusText {
    if (_isDisposed) return "Call ended";

    if (_remoteUsers.isNotEmpty) {
      if (isGroubCall) {
        return "In call with ${_remoteUsers.length} user${_remoteUsers.length > 1 ? 's' : ''}";
      } else if (_remoteUsers.length == 1) {
        return "In call with ${getUserName(_remoteUsers[0])}";
      }
      return "In call";
    } else if (_isJoined.value) {
      return isGroubCall
          ? "Waiting for others to join..."
          : "Waiting for ${remoteUserName ?? 'user'} to join...";
    } else {
      return "Connecting...";
    }
  }

  Future<void> _disposeEngine() async {
    debugPrint('🧹 Disposing video engine...');

    if (_engine != null) {
      try {
        await _engine!.stopPreview();
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
        debugPrint("✅ Engine disposed successfully");
      } catch (e) {
        debugPrint("❌ Engine disposal error: $e");
      }
    }

    if (!_isDisposed) {
      _remoteUsers.clear();
      _remoteVideoStates.clear();
      _localUserJoined.value = false;
      _isJoined.value = false;
    }

    debugPrint('✅ Video engine cleanup completed');
  }

  Map<String, dynamic> get debugInfo => _isDisposed
      ? {}
      : {
    'appId': '${appId.substring(0, 8)}...',
    'channelName': channelName,
    'uId': uId,
    'isConnected': isConnected,
    'isWaiting': isWaiting,
    'hasError': hasError,
    'networkQuality': networkQuality,
    'cameraEnabled': cameraEnabled,
    'audioEnabled': audioEnabled,
    'isMuted': isMuted,
    'isVideoStopped': isVideoStopped,
    'remoteUserCount': remoteUserCount,
    'remoteUsers': _remoteUsers,
    'localUserName': localUserName,
    'remoteUserName': remoteUserName,
    'userNamesMap': userNamesMap,
    'isGroupCall': isGroubCall,
    'userEndedCall': _userEndedCall,
  };
}