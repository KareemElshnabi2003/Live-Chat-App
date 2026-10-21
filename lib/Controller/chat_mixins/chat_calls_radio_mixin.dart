import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/Controller/audio_call_controller.dart';
import 'package:live_chat/Controller/video_call_controller.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/Model/radio_model.dart';
import 'package:live_chat/Data/Model/token_call_model.dart';
import 'package:live_chat/View/Screens/create%20chat/audio_call_view.dart';
import 'package:live_chat/View/Screens/create%20chat/video_call_view.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'chat_base_controller.dart';

mixin ChatCallsRadioMixin on ChatBaseController {
  bool isIncomingCallScreenShowing = false;
  bool isIncomingCallActive = false;
  bool audio = false;
  TokenCallModel? tokenCallModel;

  late final AudioPlayer audioPlayer;
  bool music1 = false, music2 = false, music3 = false;
  List<RadioModel> radios = [];
  StatuesRequest radioStatusRequest = StatuesRequest.none;
  int? currentRadioIndex;
  bool isRadioPlaying = false;

  void initCallsAndRadio() {
    audioPlayer = AudioPlayer();
  }

  void disposeCallsAndRadio() {
    audioPlayer.dispose();
  }

  @override
  void updateCallActiveStatus() {
    update();
  }

  void updateCallActiveStatusFromMessages() {
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
        isIncomingCallActive = true;
        break;
      }
    }
  }

  call({
    required bool isGroub,
    required dynamic type,
    required Map<int, String> groubUsersNames,
    required dynamic usernameFriend,
  }) async {
    final isBlocked = userChatModel?.isBlocked;
    final bool isBlockedByMe = isBlocked == "You blocked them";
    final bool isBlockedByThem = isBlocked == "They blocked you";
    final bool isGeneralBlocked =
        isBlockedByMe || isBlockedByThem || isBlocked == "blocked";

    if (!isGroub && isGeneralBlocked) {
      Get.snackbar(
        S.of(Get.context!).warning,
        isBlockedByThem
            ? S.of(Get.context!).msgBlockUser
            : S.of(Get.context!).msgIBlock,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.block, color: Colors.white),
      );
      return;
    }

    final int callStartTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint("⏱️ [CALL PERF] User tapped call button (audio: $audio, isGroub: $isGroub, type: $type)");

    statuesRequest = StatuesRequest.loading;
    update();

    try {
      var response = await chatsRemoteData.getTokenCall(
          callType: audio ? "audio" : "video",
          isGroub: isGroub,
          role: type,
          chatId: int.parse(chatId));

      final int tokenDuration = DateTime.now().millisecondsSinceEpoch - callStartTime;
      debugPrint("⏱️ [CALL PERF] Got token from API in ${tokenDuration}ms");

      statuesRequest = handlingData(response);

      if (statuesRequest != StatuesRequest.success) {
        final serverMsg = (Api.serverMessage ??
                (response is Map
                    ? (response['message']?.toString() ??
                        response['msg']?.toString() ??
                        '')
                    : ''))
            .toLowerCase();

        final isAlreadyActive = serverMsg.contains('جارية') ||
            serverMsg.contains('active') ||
            serverMsg.contains('already') ||
            serverMsg.contains('exist');

        if (isAlreadyActive) {
          log("🔄 Call already active on server. Automatically joining as subscriber...");
          type = "subscriber";
          response = await chatsRemoteData.getTokenCall(
              callType: audio ? "audio" : "video",
              isGroub: isGroub,
              role: "subscriber",
              chatId: int.parse(chatId));
          statuesRequest = handlingData(response);
        }
      }

      if (statuesRequest == StatuesRequest.success) {
        final responseBody = response['data'];
        if (responseBody != null) {
          tokenCallModel = TokenCallModel.fromJson(responseBody);

          final bool isCaller = (type == 'publisher');
          ChatController.isOutgoingCallInProgress = isCaller;
          ChatController.isCurrentCallPublisher = isCaller;
          ChatController.activeOutgoingChatId = chatId;

          if (audio) {
            AudioCallController.chatId = chatId;
          } else {
            VideoCallController.chatId = chatId;
          }

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
            "CallStartTime": callStartTime,
          };

          if (isCaller) {
            final startMsg = isGroub
                ? "|||GROUP_CALL_START|||${audio ? 'audio' : 'video'}"
                : "|||PRIVATE_CALL_START|||${audio ? 'audio' : 'video'}";
            sendSystemMessage(startMsg, targetChatId: chatId);
          }

          statuesRequest = StatuesRequest.none;
          update();

          if (audio) {
            await Get.to(() => const AudioCallPage(), arguments: callArgs);
          } else {
            await Get.to(() => const VideoCallPage(), arguments: callArgs);
          }
          ChatController.isOutgoingCallInProgress = false;
          ChatController.isCurrentCallPublisher = false;
          ChatController.activeOutgoingChatId = "";
          isIncomingCallActive = false;
          updateCallActiveStatus();
        } else {
          showUserFriendlyError(StatuesRequest.serverError);
        }
      } else {
        showUserFriendlyError(statuesRequest);
      }
    } catch (e) {
      log("❌ Exception in call(): $e");
      Get.snackbar("خطأ", "تعذر بدء المكالمة",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      statuesRequest = StatuesRequest.none;
      update();
    }
  }

  checkCall({
    required bool isGroub,
    required Map<int, String> groubUsersNames,
    required dynamic usernameFriend,
    bool isJoin = false,
  }) async {
    final isBlocked = userChatModel?.isBlocked;
    final bool isBlockedByMe = isBlocked == "You blocked them";
    final bool isBlockedByThem = isBlocked == "They blocked you";
    final bool isGeneralBlocked =
        isBlockedByMe || isBlockedByThem || isBlocked == "blocked";

    if (!isGroub && isGeneralBlocked) {
      Get.snackbar(
        S.of(Get.context!).warning,
        isBlockedByThem
            ? S.of(Get.context!).msgBlockUser
            : S.of(Get.context!).msgIBlock,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.block, color: Colors.white),
      );
      return;
    }

    if (statuesRequest == StatuesRequest.loading) return;
    statuesRequest = StatuesRequest.loading;
    update();

    try {
      var response = await chatsRemoteData.checkCall(id: chatId);
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

          String type = isJoin ? "subscriber" : "publisher";

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
              groubUsersNames: groubUsersNames,
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

  @override
  Future<void> getTokenCall({
    required bool isGroub,
    required Map<int, String> groubUsersNames,
    required dynamic usernameFriend,
    bool isJoin = false,
  }) async {
    await checkCall(
        isGroub: isGroub,
        groubUsersNames: groubUsersNames,
        usernameFriend: usernameFriend,
        isJoin: isJoin);
  }

  Future<void> getRadios() async {
    radioStatusRequest = StatuesRequest.loading;
    update();
    try {
      radios = await radioRemoteData.getRadios();
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
}
