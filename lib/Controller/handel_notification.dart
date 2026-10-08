// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Class/error_handler.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/Core/function/handling_data.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/token_call_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/audio_call_view.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/View/Screens/create%20chat/video_call_view.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Screens/notifications/notifications.dart';
import 'package:live_chat/View/Screens/settings/notification_view.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/video_call_notification.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:live_chat/firebase_options.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

// ⚠️ IMPORTANT: Top-level function for background notifications
@pragma('vm:entry-point')


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log("📩 Background notification received: ${message.data}");
  
  final data = message.data;
  final status = data['status'] ?? '';

  if (status == "started_call") {
    final callerName = data['caller_name'] ?? 'Unknown';
    final isAudio = data['call_type'] == "audio";
    
    CallKitParams callKitParams = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: callerName,
      appName: 'Live Chat',
      avatar: data['caller_image'] ?? '',
      handle: isAudio ? 'Audio Call' : 'Video Call',
      type: 0,
      duration: 30000,
      
      // Removed textAccept and textDecline since they are not in CallKitParams directly
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: Map<String, dynamic>.from(data),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
}

class FirebaseNotification {
  final firebaseMessagin = FirebaseMessaging.instance;

  Future<void> intilizeNotification() async {
    await firebaseMessagin.requestPermission();
    String? token = await firebaseMessagin.getToken();
    if (token != null) {
      sharedPreferences!.setString("deviceToken", token);
      log("Device token :::>>> $token");
    } else {
      log("Failed to get device token");
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    handelBackGround();
    handleForGround();

    // Listen to CallKit events (Accept / Decline)
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;
      switch (event.eventName) {
        case CallEventConstants.actionCallAccept:
          if (event is CallEventActionCallAccept) {
            final data = event.callKitParams.extra;
            if (data != null) {
              // Reconstruct a RemoteMessage from data and pass to handelMassage
              final msg = RemoteMessage(data: Map<String, dynamic>.from(data));
              handelMassage(msg);
            }
          }
          break;
        case CallEventConstants.actionCallDecline:
          if (event is CallEventActionCallDecline) {
            final data = event.callKitParams.extra;
            if (data != null && data['status'] == 'started_call') {
              final chatId = data['conversation_id'];
              final isGroup = data['is_group'].toString() == 'true';
              if (chatId != null && !isGroup) {
                 if (Get.isRegistered<ChatsRemoteData>()) {
                   final chatsData = Get.find<ChatsRemoteData>();
                   chatsData.sendMessages(chatId: chatId.toString(), message: "|||CALL_DECLINED|||");
                 } else {
                   // Fallback if not registered
                   final api = Api();
                   final chatsData = ChatsRemoteData(api: api);
                   chatsData.sendMessages(chatId: chatId.toString(), message: "|||CALL_DECLINED|||");
                 }
              }
            }
          }
          break;
        default:
          break;
      }
    });
  }

  // handle background & terminated messages
  Future<void> handelBackGround() async {
    // App opened from TERMINATED state
    firebaseMessagin.getInitialMessage().then((message) {
      if (message != null) {
        log("🚀 App opened from terminated state");
        handelMassage(message);
      }
    });

    // App opened from BACKGROUND state
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("📲 App opened from background state");
      handelMassage(message);
    });
  }

  // handle foreground messages
  Future<void> handleForGround() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final notification = message.notification;

      log("Message received while app is open: ${data.isNotEmpty ? data : "No Data"}");

      String title = '';
      String body = '';

      // 🧩 Check if message contains data
      if (data.isNotEmpty) {
        final type = data['type'] ?? '';
        final status = data['status'] ?? '';

        if (type == "friend_request" && status == "pending") {
          if (Get.locale == const Locale('ar')) {
            title = 'طلب صداقة';
            body = 'أرسل إليك ${data['username']} طلب صداقة';
          } else {
            title = 'Friend Request';
            body = '${data['username']} sent you a friend request';
          }
        } else if (type == "friend_request" && status == "accepted") {
          if (Get.locale == const Locale('ar')) {
            title = 'طلب صداقة';
            body = 'تم قبول طلب الصداقة من ${data['username']}';
          } else {
            title = 'Friend Request';
            body = '${data['username']} accepted your friend request';
          }
        } else if (status == "want_to_join_chat") {
          if (Get.locale == const Locale('ar')) {
            title = data['conversation_name'] ?? 'محادثة';
            body =
            'انضم ${data['username']} إلى المحادثة: ${data['conversation_name']}';
          } else {
            title = data['conversation_name'] ?? 'Chat';
            body =
            '${data['username']} joined the chat: ${data['conversation_name']}';
          }
        } else {
          title = notification?.title ?? 'Live Chat';
          body = notification?.body ?? 'You have a new message';
        }

        // 🔔 Handle call notification
        if (status == "started_call") {
          final isAudio = data['call_type'] == "audio";
          final isGroub =
          data['is_group'] == "1" || data['is_group'] == 1 ? true : false;

          // Extract caller information properly
          final callerName = data['caller_name'] ?? 'Unknown';
          final callerImage = (data['caller_image'] ?? '').toString();

          // For one-on-one calls, the remote user is the caller
          final usernameFriend = isGroub ? "" : callerName;

          // For group calls, prepare user names map
          Map<int, String> groubUsersNames = {};
          if (isGroub) {
            // Add current user to the map for group calls
            groubUsersNames = {
              int.parse(sharedPreferences!.getString("id")!):
              sharedPreferences!.getString("username") ?? 'You'
            };

            // If we have caller info, add it too
            if (data['caller_id'] != null) {
              final callerId = int.parse(data['caller_id'].toString());
              groubUsersNames[callerId] = callerName;
            }
          }

          Get.to(() => IncomingCallScreen(
            groubImg: data['conversation_image'] ?? '',
            groubName: data['conversation_name'] ?? '',
            isGroub: isGroub,
            onPressAnswer: () {
              checkCall(
                groubUsersNames: groubUsersNames,
                usernameFriend: usernameFriend,
                chatId: data['conversation_id'],
                audio: isAudio,
                isGroub: isGroub,
              );
            },
            callerName: callerName,
            callerImage: callerImage,
            isVideoCall: !isAudio,
          ));
          return;
        }

        // 🧭 Other notifications (snack bar)
        showCustomSnackBar(
          context: Get.context!,
          title: title,
          body: body,
          duration: const Duration(seconds: 3),
          onTap: () {
            if (type == "friend_request" && status == "pending") {
              Get.to(() => Requests(),
                  transition: Transition.leftToRight,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut);
            } else if (type == "friend_request" && status == "accepted") {
              Get.to(() => Friends(),
                  transition: Transition.leftToRight,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut);
            } else if (status == "want_to_join_chat") {
              onPressGroubChat(
                chatModel: data['conversation'],
                isGust: false,
                id: data['conversation']['id'],
              );
            } else {
              Get.to(() => NotificationView(),
                  transition: Transition.leftToRight,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut);
            }
          },
        );
      } else {
        // 🔕 fallback if no data
        log("⚠️ Message had no data. Title: ${notification?.title}, Body: ${notification?.body}");
      }
    });
  }

  // 🎯 Main handler for background/terminated notification taps
  void handelMassage(RemoteMessage? remotemess) async {
    if (remotemess == null) return;

    log("👆 User tapped on notification: ${remotemess.data}");

    final data = remotemess.data;

    if (data.isEmpty) {
      log("⚠️ No data in notification");
      return;
    }

    // Add small delay to ensure app is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));

    final type = data['type'] ?? '';
    final status = data['status'] ?? '';

    // 🔔 Handle call notification (when app was closed/background)
    if (status == "started_call") {
      final isAudio = data['call_type'] == "audio";
      final isGroub =
      data['is_group'] == "1" || data['is_group'] == 1 ? true : false;

      // Extract caller information properly
      final callerName = data['caller_name'] ?? 'Unknown';
      final callerImage = (data['caller_image'] ?? '').toString();

      // For one-on-one calls, the remote user is the caller
      final usernameFriend = isGroub ? "" : callerName;

      // For group calls, prepare user names map
      Map<int, String> groubUsersNames = {};
      if (isGroub) {
        groubUsersNames = {
          int.parse(sharedPreferences!.getString("id")!):
          sharedPreferences!.getString("username") ?? 'You'
        };

        // If we have caller info, add it too
        if (data['caller_id'] != null) {
          final callerId = int.parse(data['caller_id'].toString());
          groubUsersNames[callerId] = callerName;
        }
      }

      log("📞 Opening call screen: ${isAudio ? 'Audio' : 'Video'}, Group: $isGroub, Caller: $callerName");

      Get.to(() => IncomingCallScreen(
        groubImg: data['conversation_image'] ?? '',
        groubName: data['conversation_name'] ?? '',
        isGroub: isGroub,
        onPressAnswer: () {
          checkCall(
            groubUsersNames: groubUsersNames,
            usernameFriend: usernameFriend,
            chatId: data['conversation_id'],
            audio: isAudio,
            isGroub: isGroub,
          );
        },
        callerName: callerName,
        callerImage: callerImage,
        isVideoCall: !isAudio,
      ));
      return;
    }

    // 👥 Handle friend request notification
    if (type == "friend_request" && status == "pending") {
      log("👥 Opening friend requests");
      Get.to(() => Requests(),
          transition: Transition.leftToRight,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut);
      return;
    }

    // ✅ Handle accepted friend request
    if (type == "friend_request" && status == "accepted") {
      log("✅ Opening friends list");
      Get.to(() => Friends(),
          transition: Transition.leftToRight,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut);
      return;
    }

    // 💬 Handle join chat notification
    if (status == "want_to_join_chat") {
      log("💬 Opening chat");
      try {
        onPressGroubChat(
          chatModel: UserChatModel.fromJson(data['conversation']),
          isGust: false,
          id: data['conversation']['id'],
        );
      } catch (e) {
        log("❌ Error opening chat: $e");
        Get.snackbar(
          'Error',
          'Failed to open chat',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
        );
      }
      return;
    }

    // 🔔 Default: Open notifications screen
    log("🔔 Opening notifications screen");
    Get.to(() => Notifications(),
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut);
  }


  final ChatsRemoteData _chatsRemoteData = ChatsRemoteData(api: Get.find<Api>());

  StatuesRequest statuesRequest = StatuesRequest.none;
  TokenCallModel? _tokenCallModel;

  checkCall({
    required chatId,
    required bool audio,
    required bool isGroub,
    required Map<int, String> groubUsersNames,
    required String usernameFriend,
  }) async {
    log("check");
    statuesRequest = StatuesRequest.loading;
    Get.appUpdate();

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

        if (response['data']['status'] == 0) {
          messageError(
              S.of(Get.context!).warning, S.of(Get.context!).closeCall);
        } else {

          Map<int, String> updatedUserNamesMap = {...groubUsersNames};

          if (isGroub) {
            var usersResponse = await _chatsRemoteData.getConversationUsers(
              chatId: int.parse(chatId.toString()),
            );

            if (usersResponse['status'] == 'success' &&
                usersResponse['data'] != null) {
              for (var userData in usersResponse['data']) {
                final uid = int.parse(userData['uid'].toString());
                final username = userData['username'] ?? 'User';
                updatedUserNamesMap[uid] = username;
              }
              log("✅ Fetched ${updatedUserNamesMap.length} users for group call");
            }
          }

          getTokenCall(
              chatId: chatId,
              audio: audio,
              isGroub: isGroub,
              groubUsersNames: updatedUserNamesMap, // Pass updated map
              usernameFriend: usernameFriend);
        }
      } else {
        log("check call data is null");
                  showUserFriendlyError(statuesRequest);

      }
    }

    Get.appUpdate();
  }

  Future<void> getTokenCall({
    required chatId,
    required bool audio,
    required bool isGroub,
    required Map<int, String> groubUsersNames,
    required String usernameFriend,
  }) async {

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      barrierDismissible: false,
    );

    try {
      var response = await _chatsRemoteData.getTokenCall(
        callType: audio ? "audio" : "video",
        isGroub: isGroub,
        role: "subscriber",
        chatId: int.parse(chatId.toString()),
      );

      statuesRequest = handlingData(response);


      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (statuesRequest == StatuesRequest.success) {
        final responseBody = response['data'];
        if (responseBody != null) {
          _tokenCallModel = TokenCallModel.fromJson(responseBody);
          log("✅ Token loaded successfully >>> ${response['data']} <<<");

          final remoteUserName = isGroub
              ? ""
              : (usernameFriend.isNotEmpty ? usernameFriend : 'User');

          if (audio) {
            Get.off(() => const AudioCallPage(), arguments: {
              "ChannelName": _tokenCallModel!.channel,
              "Token": _tokenCallModel!.token,
              "UId": _tokenCallModel!.uid,
              "IsGroupCall": isGroub,
              "chatId": chatId,
              "RemoteUserName": remoteUserName,
              "UserNamesMap": groubUsersNames,
              "LocalUserName": sharedPreferences!.getString("name") ?? 'You'
            });
          } else {
            Get.off(() => const VideoCallPage(), arguments: {
              "ChannelName": _tokenCallModel!.channel,
              "Token": _tokenCallModel!.token,
              "UId": _tokenCallModel!.uid,
              "IsGroupCall": isGroub,
              "chatId": chatId,
              "RemoteUserName": remoteUserName,
              "UserNamesMap": groubUsersNames,
              "LocalUserName": sharedPreferences!.getString("name") ?? 'You'
            });
          }
        } else {
          log("❌ Token data is null");
          Get.snackbar(
            'Error',
            'Failed to get call token',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red[700],
            colorText: Colors.white,
          );
        }
      } else {
        log("❌ Failed to get token: ${statuesRequest.toString()}");
   
   
                  showUserFriendlyError(statuesRequest);

      }
    } catch (e) {
      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      log("❌ Error in getTokenCall: $e");
      Get.snackbar(
        'Error',
        'Failed to load call information',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    }
  }

  onPressGroubChat({
    required UserChatModel chatModel,
    required bool isGust,
    required id,
  }) {
    Get.to(
          () => ChatView(
        userChatModel: chatModel,
        isPin: false,
        isGust: isGust,
      ),
      arguments: {"chatId": id},
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  firebasemessaginsetting() async {
    NotificationSettings settings = await firebaseMessagin.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        log('✅ User granted permission');
        break;
      case AuthorizationStatus.provisional:
        log('⚠️ User granted provisional permission');
        break;
      default:
        log('❌ User declined or has not accepted permission');
    }
  }
}

void showCustomSnackBar({
  required BuildContext context,
  required String title,
  required String body,
  required VoidCallback onTap,
  Duration duration = const Duration(seconds: 4),
}) {
  final snackBar = SnackBar(
    content: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFb30086), Color(0xFFd939d2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            body,
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(
      bottom: 20.0,
      left: 16.0,
      right: 16.0,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    duration: duration,
    action: SnackBarAction(
      label: 'عرض',
      textColor: Colors.yellowAccent,
      onPressed: onTap,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}