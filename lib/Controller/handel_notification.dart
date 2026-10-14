// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_chat/Controller/audio_call_controller.dart';
import 'package:live_chat/Controller/video_call_controller.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Screens/notifications/notifications.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:live_chat/View/Widget/PublicWidget/video_call_notification.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:live_chat/firebase_options.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

// ⚠️ IMPORTANT: Top-level function for background notifications
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("==================================================");
  print("📩 [BACKGROUND] Notification Received!");
  print("Message ID: ${message.messageId}");
  print("Notification Title: ${message.notification?.title}");
  print("Notification Body: ${message.notification?.body}");
  print("Data: ${message.data}");
  print("==================================================");

  final data = message.data;
  final status = data['status'] ?? '';
  final type = data['type'] ?? '';

  bool isCall = status == "started_call" ||
      status == "start_call" ||
      type == "call" ||
      data['call_type'] != null;

  if (isCall) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getString("id") ?? "";
      final callerId = data['caller_id']?.toString() ??
          data['sender_id']?.toString() ??
          data['user_id']?.toString() ??
          "";
      if (myId.isNotEmpty && callerId.isNotEmpty && myId == callerId) {
        print("🔇 [BACKGROUND] Ignoring call notification: I am the caller ($myId == $callerId)");
        return;
      }
    } catch (e) {
      print("Error checking myId in background: $e");
    }

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
  } else if (message.notification == null && data.isNotEmpty) {
    // If backend sent a data-only message in background, show local notification
    String title = data['title'] ?? data['conversation_name'] ?? 'Live Chat';
    String body = data['body'] ?? data['message'] ?? 'لديك إشعار جديد';
    try {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: AppColors.primaryColor,
            playSound: true,
            enableVibration: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    } catch (e) {
      print("Background local notification show error: $e");
    }
  }
}

class FirebaseNotification {
  static bool isHandlingCallLaunch = false;
  static bool isAnsweringNotificationCall = false;
  final firebaseMessagin = FirebaseMessaging.instance;
Future<void> intilizeNotification() async {
    // 🌟 1. طلب الصلاحيات أولاً (عشان فايربيز يفتح البوابات)
    await checkAndRequestNotificationPermission(showDialogIfPermanentlyDenied: false);

    // 🌟 2. إعداد طريقة عرض إشعارات الـ Foreground
    try {
      await firebaseMessagin.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print("setForeground error: $e");
    }

    // 🌟 3. تهيئة الإشعارات المحلية وإنشاء القناة (Channel)
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              handelMassage(RemoteMessage(data: data));
            } catch (e) {
              print("Error handling local notification click: $e");
            }
          }
        },
      );

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(highImportanceChannel);
      }
    } catch (e) {
      print("Error initializing local notifications: $e");
    }

    // 🌟 4. جلب التوكن وتخزينه
    try {
      String? token = await firebaseMessagin.getToken();
      if (token != null) {
        sharedPreferences!.setString("deviceToken", token);
        print("Device token :::>>> $token");
      } else {
        print("Failed to get device token");
      }
    } catch (e) {
      print("Error getting device token: $e");
    }

    // تجديد التوكن لو اتغير
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      sharedPreferences!.setString("deviceToken", newToken);
      print("🔄 Device token refreshed :::>>> $newToken");
    });

    // ========================================================
    // 🌟 5. أخيراً: تشغيل مستمعات الإشعارات (بعد ما كل حاجة جهزت)
    // ========================================================
    handelBackGround();
    handleForGround();

    // 🌟 6. فحص ما إذا كان التطبيق فُتح عن طريق قبول مكالمة وهو مقفول
    try {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if (activeCalls.isNotEmpty) {
        log("📞 [STARTUP] Found active CallKit calls: $activeCalls");
        for (var c in activeCalls) {
          if (c.extra != null && c.isAccepted) {
            final extra = Map<String, dynamic>.from(c.extra!);
            log("📞 [STARTUP] User accepted call from terminated state! Answering now...");
            isHandlingCallLaunch = true;
            await FlutterCallkitIncoming.endAllCalls();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 600), () {
                answerCallFromNotification(extra);
              });
            });
            break;
          }
        }
      }
    } catch (e) {
      log("Error checking active calls: $e");
    }

    // 🌟 7. مستمع المكالمات (CallKit)
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;
      switch (event.eventName) {
        case CallEventConstants.actionCallAccept:
          await FlutterCallkitIncoming.endAllCalls();
          final data = event is CallEventActionCallAccept
              ? event.callKitParams.extra
              : null;
          if (data != null) {
            isHandlingCallLaunch = true;
            answerCallFromNotification(Map<String, dynamic>.from(data));
          }
          break;
        case CallEventConstants.actionCallDecline:
          await FlutterCallkitIncoming.endAllCalls();
          final data = event is CallEventActionCallDecline
              ? event.callKitParams.extra
              : null;
          if (data != null && data['status'] == 'started_call') {
            final chatId = data['conversation_id'];
            final isGroup = data['is_group'].toString() == 'true';
            if (chatId != null && !isGroup) {
               if (Get.isRegistered<ChatsRemoteData>()) {
                 final chatsData = Get.find<ChatsRemoteData>();
                 chatsData.sendMessages(chatId: chatId.toString(), message: "|||CALL_DECLINED|||");
               } else {
                 final api = Api();
                 final chatsData = ChatsRemoteData(api: api);
                 chatsData.sendMessages(chatId: chatId.toString(), message: "|||CALL_DECLINED|||");
               }
            }
          }
          break;
        default:
          break;
      }
    });
  }

  // 🌟 دالة موحدة لجميع مسارات الرد على المكالمات (من CallKit أو شاشة الرنين أو الضغط على الإشعار)
  // تمر دائماً عبر ChatController لتسجيل دور المشترك (isJoin: true) والربط مع شات المحادثة
  Future<void> answerCallThroughChatController({
    required String chatId,
    required bool isAudio,
    required bool isGroub,
    required String callerName,
    required String callerImage,
    Map<int, String>? groubUsersNames,
  }) async {
    log("📞 [UNIFIED] Answering call through ChatController: chatId=$chatId, isAudio=$isAudio, isGroub=$isGroub");

    try {
      // 🌟 إذا كان المستخدم في مكالمة جارية بالفعل، ننهيها أولاً قبل الانتقال للمكالمة الجديدة
      if (Get.isRegistered<VideoCallController>()) {
        log("🔚 Ending current video call to accept new call");
        await Get.find<VideoCallController>().endCall();
        Get.delete<VideoCallController>(force: true);
      }
      if (Get.isRegistered<AudioCallController>()) {
        log("🔚 Ending current audio call to accept new call");
        await Get.find<AudioCallController>().endCall();
        Get.delete<AudioCallController>(force: true);
      }

      // 1. إذا كان ChatController مسجلاً بالفعل لنفس الشات، نستخدمه مباشرة
      if (Get.isRegistered<ChatController>()) {
        final ctrl = Get.find<ChatController>();
        if (ctrl.chatId.toString() == chatId.toString()) {
          ctrl.audio = isAudio;
          await ctrl.getTokenCall(
            isGroub: isGroub,
            groubUsersNames: groubUsersNames ?? {},
            usernameFriend: isGroub ? "" : callerName,
            isJoin: true,
          );
          return;
        } else {
          // إذا كان مسجلاً لشات مختلف، نحذفه لإنشاء كنترولر الشات الجديد
          Get.delete<ChatController>(force: true);
        }
      }

      // 2. إذا لم يكن مسجلاً أو لشات مختلف، نقوم بفتح ChatView أولاً لتهيئة الشات والـ Pusher والـ Controllers
      final currentUserId = int.tryParse(sharedPreferences?.getString("id") ?? "0");
      final chatModel = UserChatModel(
        id: int.tryParse(chatId),
        name: isGroub ? (callerName.isNotEmpty ? callerName : 'Group Chat') : callerName,
        image: callerImage,
        status: isGroub ? 'Public' : 'Private',
        accept: '1',
        user: User(id: currentUserId),
      );

      // ⚠️ تنبيه هام: لا نستخدم await هنا لأن Get.to() تُرجع Future يكتمل فقط عند إغلاق الشاشة (Pop)!
      Get.to(
        () => ChatView(
          userChatModel: chatModel,
          isPin: false,
          isGust: false,
        ),
        arguments: {"chatId": chatId},
      );

      // 🌟 تأخير بسيط (400ms) لإعطاء فرصة لـ initState في ChatView لتسجيل ChatController
      await Future.delayed(const Duration(milliseconds: 400));

      // 3. الآن تم تسجيل ChatController في الذاكرة ومتاح بشكل كامل
      if (Get.isRegistered<ChatController>()) {
        final ctrl = Get.find<ChatController>();
        ctrl.audio = isAudio;
        await ctrl.getTokenCall(
          isGroub: isGroub,
          groubUsersNames: groubUsersNames ?? {},
          usernameFriend: isGroub ? "" : callerName,
          isJoin: true,
        );
      }
    } catch (e) {
      log("❌ [UNIFIED] Error in answerCallThroughChatController: $e");
    }
  }

  Future<void> answerCallFromNotification(Map<String, dynamic> data) async {
    if (isAnsweringNotificationCall) {
      log("🔇 Ignoring answer call: Already in progress");
      return;
    }
    isAnsweringNotificationCall = true;

    try {
      final isAudio = data['call_type'] == "audio";
      final isGroub = data['is_group'] == "1" ||
          data['is_group'] == 1 ||
          data['is_group'].toString() == 'true';
      final callerName = data['caller_name'] ??
          data['sender_name'] ??
          data['title'] ??
          'Unknown';
      final callerImage = (data['caller_image'] ?? '').toString();

      Map<int, String> groubUsersNames = {};
      if (isGroub) {
        final currentUserIdStr = sharedPreferences?.getString("id") ?? "0";
        final currentUserName = sharedPreferences?.getString("username") ?? 'You';
        groubUsersNames = {
          int.tryParse(currentUserIdStr) ?? 0: currentUserName,
        };
        if (data['caller_id'] != null) {
          final callerId = int.tryParse(data['caller_id'].toString()) ?? 0;
          groubUsersNames[callerId] = callerName;
        }
      }

      log("📞 Answering call directly from notification: chatId=${data['conversation_id']}, isAudio=$isAudio");

      await answerCallThroughChatController(
        chatId: data['conversation_id']?.toString() ?? '',
        isAudio: isAudio,
        isGroub: isGroub,
        callerName: callerName,
        callerImage: callerImage,
        groubUsersNames: groubUsersNames,
      );
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        isAnsweringNotificationCall = false;
      });
    }
  }

  // handle foreground messages
  Future<void> handleForGround() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final notification = message.notification;

      print("==================================================");
      print("🔔 [FOREGROUND] Notification Received while app is OPEN!");
      print("Message ID: ${message.messageId}");
      print("Notification Title: ${notification?.title}");
      print("Notification Body: ${notification?.body}");
      print("Data: $data");
      print("==================================================");

      final type = data['type'] ?? '';
      final status = data['status'] ?? '';

      // 🔔 Handle call notification
      bool isCallNotification = status == "started_call" ||
          status == "start_call" ||
          type == "call" ||
          data['call_type'] != null;

      if (isCallNotification) {
        // 🛡️ 1. لا تظهر إشعار المكالمة لنفسي لو أنا اللي متصل
        final myId = sharedPreferences?.getString("id") ?? "";
        final callerId = data['caller_id']?.toString() ??
            data['sender_id']?.toString() ??
            data['user_id']?.toString() ??
            "";
        if (myId.isNotEmpty && callerId.isNotEmpty && myId == callerId) {
          log("🔇 [FOREGROUND] Ignoring call notification: I am the caller ($myId == $callerId)");
          return;
        }

        // 🛡️ 2. إذا كان المستخدم في نفس المكالمة الجارية بالفعل، نتجاهل الإشعار المكرر
        final bool isAlreadyInCall = Get.isRegistered<AudioCallController>() ||
            Get.isRegistered<VideoCallController>();
        final callingChatId = data['conversation_id']?.toString() ?? "";
        String currentCallChatId = VideoCallController.chatId.isNotEmpty
            ? VideoCallController.chatId
            : AudioCallController.chatId;

        if (isAlreadyInCall && callingChatId == currentCallChatId) {
          log("🔇 [FOREGROUND] Already in this active call, ignoring duplicate notification");
          return;
        }

        // 🛡️ 3. منع تكرار شاشة الرنين إذا كانت شاشة الرنين معروضة بالفعل (مثلاً تم فتحها عبر Pusher)
        if (IncomingCallScreen.isShowing) {
          log("🔇 [FOREGROUND] IncomingCallScreen is already showing, skipping duplicate.");
          return;
        }

        final isAudio = data['call_type'] == "audio";
        final isGroub =
            data['is_group'] == "1" || data['is_group'] == 1 ? true : false;
        final callerName = data['caller_name'] ?? 'Unknown';
        final callerImage = (data['caller_image'] ?? '').toString();

        Map<int, String> groubUsersNames = {};
        if (isGroub) {
          groubUsersNames = {
            int.parse(sharedPreferences!.getString("id")!):
                sharedPreferences!.getString("username") ?? 'You'
          };
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
                answerCallThroughChatController(
                  chatId: data['conversation_id']?.toString() ?? '',
                  isAudio: isAudio,
                  isGroub: isGroub,
                  callerName: callerName,
                  callerImage: callerImage,
                  groubUsersNames: groubUsersNames,
                );
              },
              onPressReject: () {
                final api = Get.isRegistered<Api>() ? Get.find<Api>() : Api();
                final chatsData = ChatsRemoteData(api: api);
                final cId = data['conversation_id']?.toString();
                if (cId != null && cId.isNotEmpty) {
                  chatsData.sendMessages(
                    chatId: cId,
                    message: "|||CALL_DECLINED|||",
                  );
                }
              },
              callerName: callerName,
              callerImage: callerImage,
              isVideoCall: !isAudio,
            ));
        return;
      }

      final currentLang = sharedPreferences?.getString("selectedLanguage") ??
          Get.locale?.languageCode ??
          'ar';
      final isArabic = currentLang == 'ar';

      // 🌟 استخراج العنوان والنص مع مراعاة لغة التطبيق الحالية (Localization)
      String title = notification?.title ??
          data['title'] ??
          data['conversation_name'] ??
          (isArabic ? 'تنبيه جديد' : 'New Notification');
      String body = notification?.body ??
          data['body'] ??
          data['message'] ??
          (isArabic ? 'لديك إشعار جديد' : 'You have a new notification');

      // تعديل العنوان والنص بناءً على نوع الداتا (لو جاية من الباك إند)
      if (notification == null && data.isNotEmpty) {
        if (type == "friend_request" && status == "pending") {
          title = isArabic ? 'طلب صداقة' : 'Friend Request';
          body = isArabic
              ? 'أرسل إليك ${data['username'] ?? 'مستخدم'} طلب صداقة'
              : '${data['username'] ?? 'User'} sent you a friend request';
        } else if (type == "friend_request" && status == "accepted") {
          title = isArabic ? 'طلب صداقة' : 'Friend Request';
          body = isArabic
              ? 'تم قبول طلب الصداقة من ${data['username'] ?? 'المستخدم'}'
              : '${data['username'] ?? 'User'} accepted your friend request';
        } else if (status == "want_to_join_chat") {
          title = data['conversation_name'] ??
              (isArabic ? 'محادثة' : 'Chat');
          body = isArabic
              ? 'طلب ${data['username'] ?? ''} الانضمام إلى المحادثة : ${data['conversation_name'] ?? ''}'
              : '${data['username'] ?? ''} requested to join chat : ${data['conversation_name'] ?? ''}';
        }
      }

      void onTapAction() {
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
        } else if (status == "want_to_join_chat" &&
            data['conversation'] != null) {
          onPressGroubChat(
            chatModel: data['conversation'] is Map
                ? UserChatModel.fromJson(data['conversation'])
                : data['conversation'],
            isGust: false,
            id: data['conversation']['id'],
          );
        } else {
          Get.to(() => Notifications(),
              transition: Transition.leftToRight,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut);
        }
      }

      // 1. Show Android system notification in Status Bar
      try {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              highImportanceChannel.id,
              highImportanceChannel.name,
              channelDescription: highImportanceChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: AppColors.primaryColor,
              playSound: true,
              enableVibration: true,
            ),
          ),
          payload: jsonEncode(data),
        );
      } catch (e) {
        print("Local notification show error: $e");
      }

      // 2. Show in-app top banner
      showInAppNotificationBanner(
        title: title,
        body: body,
        onTap: onTapAction,
      );
    });
  }

  // Future<void> intilizeNotification() async {
  //   print(
  //       " 👌👌👌======================intilizeNotification====================== 👌👌👌");
  //   // 1. Register foreground and background handlers immediately
  //   handleForGround();
  //   handelBackGround();

  //   // 2. Set presentation options for foreground notifications
  //   try {
  //     await firebaseMessagin.setForegroundNotificationPresentationOptions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );
  //   } catch (e) {
  //     log("setForegroundNotificationPresentationOptions error: $e");
  //   }

  //   // 3. Initialize Flutter Local Notifications
  //   try {
  //     const AndroidInitializationSettings initializationSettingsAndroid =
  //         AndroidInitializationSettings('@mipmap/launcher_icon');

  //     const DarwinInitializationSettings initializationSettingsDarwin =
  //         DarwinInitializationSettings();

  //     const InitializationSettings initializationSettings =
  //         InitializationSettings(
  //       android: initializationSettingsAndroid,
  //       iOS: initializationSettingsDarwin,
  //     );

  //     await flutterLocalNotificationsPlugin.initialize(
  //       initializationSettings,
  //       onDidReceiveNotificationResponse: (NotificationResponse response) {
  //         if (response.payload != null && response.payload!.isNotEmpty) {
  //           try {
  //             final Map<String, dynamic> data = jsonDecode(response.payload!);
  //             handelMassage(RemoteMessage(data: data));
  //           } catch (e) {
  //             log("Error handling local notification click: $e");
  //           }
  //         }
  //       },
  //     );

  //     final androidPlugin =
  //         flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //             AndroidFlutterLocalNotificationsPlugin>();
  //     if (androidPlugin != null) {
  //       await androidPlugin.createNotificationChannel(highImportanceChannel);
  //     }
  //   } catch (e) {
  //     log("Error initializing local notifications: $e");
  //   }

  //   // 4. Retrieve and store device token
  //   try {
  //     String? token = await firebaseMessagin.getToken();
  //     if (token != null) {
  //       sharedPreferences!.setString("deviceToken", token);
  //       print("Device token :::>>> $token");
  //     } else {
  //       print("Failed to get device token");
  //     }
  //   } catch (e) {
  //     log("Error getting device token: $e");
  //   }

  //   // Keep token refreshed
  //   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  //     sharedPreferences!.setString("deviceToken", newToken);
  //     print("🔄 Device token refreshed :::>>> $newToken");
  //   });

  //   // Listen to CallKit events (Accept / Decline)
  //   FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
  //     if (event == null) return;
  //     switch (event.eventName) {
  //       case CallEventConstants.actionCallAccept:
  //         if (event is CallEventActionCallAccept) {
  //           final data = event.callKitParams.extra;
  //           if (data != null) {
  //             // Reconstruct a RemoteMessage from data and pass to handelMassage
  //             final msg = RemoteMessage(data: Map<String, dynamic>.from(data));
  //             handelMassage(msg);
  //           }
  //         }
  //         break;
  //       case CallEventConstants.actionCallDecline:
  //         if (event is CallEventActionCallDecline) {
  //           final data = event.callKitParams.extra;
  //           if (data != null && data['status'] == 'started_call') {
  //             final chatId = data['conversation_id'];
  //             final isGroup = data['is_group'].toString() == 'true';
  //             if (chatId != null && !isGroup) {
  //               if (Get.isRegistered<ChatsRemoteData>()) {
  //                 final chatsData = Get.find<ChatsRemoteData>();
  //                 chatsData.sendMessages(
  //                     chatId: chatId.toString(),
  //                     message: "|||CALL_DECLINED|||");
  //               } else {
  //                 // Fallback if not registered
  //                 final api = Api();
  //                 final chatsData = ChatsRemoteData(api: api);
  //                 chatsData.sendMessages(
  //                     chatId: chatId.toString(),
  //                     message: "|||CALL_DECLINED|||");
  //               }
  //             }
  //           }
  //         }
  //         break;
  //       default:
  //         break;
  //     }
  //   });
  // }

  // handle background & terminated messages
  Future<void> handelBackGround() async {
    // App opened from TERMINATED state
    firebaseMessagin.getInitialMessage().then((message) {
      if (message != null) {
        print(
            "🚀 [TERMINATED OPEN] App opened by tapping notification: ${message.data}");
        handelMassage(message);
      }
    });

    // App opened from BACKGROUND state
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(
          "📲 [BACKGROUND OPEN] App opened by tapping notification: ${message.data}");
      handelMassage(message);
    });
  }

  // handle foreground messages
  // Future<void> handleForGround() async {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("================================================== 👌👌👌");
  //     final data = message.data;
  //     final notification = message.notification;

  //     print("==================================================");
  //     print("🔔 [FOREGROUND] Notification Received while app is OPEN!");
  //     print("Message ID: ${message.messageId}");
  //     print("Notification Title: ${notification?.title}");
  //     print("Notification Body: ${notification?.body}");
  //     print("Data: $data");
  //     print("==================================================");

  //     final type = data['type'] ?? '';
  //     final status = data['status'] ?? '';

  //     // 🔔 Handle call notification
  //     bool isCallNotification = status == "started_call" ||
  //         status == "start_call" ||
  //         type == "call" ||
  //         data['call_type'] != null;

  //     if (isCallNotification) {
  //       final isAudio = data['call_type'] == "audio";
  //       final isGroub =
  //           data['is_group'] == "1" || data['is_group'] == 1 ? true : false;

  //       final callerName = data['caller_name'] ?? 'Unknown';
  //       final callerImage = (data['caller_image'] ?? '').toString();
  //       final usernameFriend = isGroub ? "" : callerName;

  //       Map<int, String> groubUsersNames = {};
  //       if (isGroub) {
  //         groubUsersNames = {
  //           int.parse(sharedPreferences!.getString("id")!):
  //               sharedPreferences!.getString("username") ?? 'You'
  //         };

  //         if (data['caller_id'] != null) {
  //           final callerId = int.parse(data['caller_id'].toString());
  //           groubUsersNames[callerId] = callerName;
  //         }
  //       }

  //       Get.to(() => IncomingCallScreen(
  //             groubImg: data['conversation_image'] ?? '',
  //             groubName: data['conversation_name'] ?? '',
  //             isGroub: isGroub,
  //             onPressAnswer: () {
  //               checkCall(
  //                 groubUsersNames: groubUsersNames,
  //                 usernameFriend: usernameFriend,
  //                 chatId: data['conversation_id'],
  //                 audio: isAudio,
  //                 isGroub: isGroub,
  //               );
  //             },
  //             callerName: callerName,
  //             callerImage: callerImage,
  //             isVideoCall: !isAudio,
  //           ));
  //       return;
  //     }

  //     // Determine Title & Body
  //     String title = notification?.title ?? '';
  //     String body = notification?.body ?? '';

  //     if (title.isEmpty) {
  //       if (type == "friend_request" && status == "pending") {
  //         title =
  //             Get.locale?.languageCode == 'ar' ? 'طلب صداقة' : 'Friend Request';
  //         body = Get.locale?.languageCode == 'ar'
  //             ? 'أرسل إليك ${data['username'] ?? 'مستخدم'} طلب صداقة'
  //             : '${data['username'] ?? 'User'} sent you a friend request';
  //       } else if (type == "friend_request" && status == "accepted") {
  //         title =
  //             Get.locale?.languageCode == 'ar' ? 'طلب صداقة' : 'Friend Request';
  //         body = Get.locale?.languageCode == 'ar'
  //             ? 'تم قبول طلب الصداقة من ${data['username'] ?? 'المستخدم'}'
  //             : '${data['username'] ?? 'User'} accepted your friend request';
  //       } else if (status == "want_to_join_chat") {
  //         title = data['conversation_name'] ??
  //             (Get.locale?.languageCode == 'ar' ? 'محادثة' : 'Chat');
  //         body = Get.locale?.languageCode == 'ar'
  //             ? 'انضم ${data['username'] ?? ''} إلى المحادثة: ${data['conversation_name'] ?? ''}'
  //             : '${data['username'] ?? ''} joined the chat: ${data['conversation_name'] ?? ''}';
  //       } else {
  //         title = data['title'] ?? 'Live Chat';
  //         body = data['body'] ??
  //             data['message'] ??
  //             (notification?.body ?? 'لديك إشعار جديد');
  //       }
  //     }

  //     if (body.isEmpty) {
  //       body = data['body'] ?? data['message'] ?? 'لديك إشعار جديد';
  //     }

  //     void onTapAction() {
  //       if (type == "friend_request" && status == "pending") {
  //         Get.to(() => Requests(),
  //             transition: Transition.leftToRight,
  //             duration: const Duration(milliseconds: 800),
  //             curve: Curves.easeOut);
  //       } else if (type == "friend_request" && status == "accepted") {
  //         Get.to(() => Friends(),
  //             transition: Transition.leftToRight,
  //             duration: const Duration(milliseconds: 800),
  //             curve: Curves.easeOut);
  //       } else if (status == "want_to_join_chat" &&
  //           data['conversation'] != null) {
  //         onPressGroubChat(
  //           chatModel: data['conversation'] is Map
  //               ? UserChatModel.fromJson(data['conversation'])
  //               : data['conversation'],
  //           isGust: false,
  //           id: data['conversation']['id'],
  //         );
  //       } else {
  //         Get.to(() => Notifications(),
  //             transition: Transition.leftToRight,
  //             duration: const Duration(milliseconds: 800),
  //             curve: Curves.easeOut);
  //       }
  //     }

  //     // 1. Show Android system notification in Status Bar / Drawer
  //     try {
  //       flutterLocalNotificationsPlugin.show(
  //         message.hashCode,
  //         title,
  //         body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             highImportanceChannel.id,
  //             highImportanceChannel.name,
  //             channelDescription: highImportanceChannel.description,
  //             importance: Importance.max,
  //             priority: Priority.high,
  //             icon: '@mipmap/launcher_icon',
  //             playSound: true,
  //             enableVibration: true,
  //           ),
  //         ),
  //         payload: jsonEncode(data),
  //       );
  //     } catch (e) {
  //       log("Local notification show error: $e");
  //     }

  //     // 2. Show in-app top banner
  //     showInAppNotificationBanner(
  //       title: title,
  //       body: body,
  //       onTap: onTapAction,
  //     );
  //   });
  // }

  // 🎯 Main handler for background/terminated notification taps
  void handelMassage(RemoteMessage? remotemess) async {
    if (remotemess == null) return;

    print(
        "👆 [NOTIFICATION TAP] User tapped notification. Title: ${remotemess.notification?.title}, Body: ${remotemess.notification?.body}, Data: ${remotemess.data}");

    final data = remotemess.data;

    if (data.isEmpty) {
      print("⚠️ No custom data in tapped notification");
      return;
    }

    // Add small delay to ensure app is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));

    final type = data['type'] ?? '';
    final status = data['status'] ?? '';

    // 🔔 Handle call notification (when app was closed/background)
    bool isCallNotification = status == "started_call" ||
        status == "start_call" ||
        type == "call" ||
        data['call_type'] != null;

    if (isCallNotification) {
      // 🛡️ 1. لا تظهر إشعار المكالمة لنفسي لو أنا اللي متصل
      final myId = sharedPreferences?.getString("id") ?? "";
      final callerId = data['caller_id']?.toString() ??
          data['sender_id']?.toString() ??
          data['user_id']?.toString() ??
          "";
      if (myId.isNotEmpty && callerId.isNotEmpty && myId == callerId) {
        log("🔇 [TAP] Ignoring call notification: I am the caller ($myId == $callerId)");
        return;
      }

      // 🛡️ 2. إذا كان المستخدم في نفس المكالمة الجارية بالفعل، نتجاهل الإشعار المكرر
      final bool isAlreadyInCall = Get.isRegistered<AudioCallController>() ||
          Get.isRegistered<VideoCallController>();
      final callingChatId = data['conversation_id']?.toString() ?? "";
      String currentCallChatId = VideoCallController.chatId.isNotEmpty
          ? VideoCallController.chatId
          : AudioCallController.chatId;

      if (isAlreadyInCall && callingChatId == currentCallChatId) {
        log("🔇 [TAP] Already in this active call, ignoring duplicate notification");
        return;
      }

      // 🛡️ 3. منع تكرار شاشة الرنين إذا كانت شاشة الرنين معروضة بالفعل
      if (IncomingCallScreen.isShowing) {
        log("🔇 [TAP] IncomingCallScreen is already showing, skipping duplicate.");
        return;
      }

      final isAudio = data['call_type'] == "audio";
      final isGroub =
          data['is_group'] == "1" || data['is_group'] == 1 ? true : false;

      // Extract caller information properly
      final callerName = data['caller_name'] ?? 'Unknown';
      final callerImage = (data['caller_image'] ?? '').toString();

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
              answerCallThroughChatController(
                chatId: data['conversation_id']?.toString() ?? '',
                isAudio: isAudio,
                isGroub: isGroub,
                callerName: callerName,
                callerImage: callerImage,
                groubUsersNames: groubUsersNames,
              );
            },
            onPressReject: () {
              final api = Get.isRegistered<Api>() ? Get.find<Api>() : Api();
              final chatsData = ChatsRemoteData(api: api);
              final cId = data['conversation_id']?.toString();
              if (cId != null && cId.isNotEmpty) {
                chatsData.sendMessages(
                  chatId: cId,
                  message: "|||CALL_DECLINED|||",
                );
              }
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

  onPressGroubChat({
    required UserChatModel chatModel,
    required bool isGust,
    required id,
  }) {
    // 🌟 استكمال بيانات الشات لو جاية ناقصة من الإشعار لضمان ظهور الإعدادات وصلاحيات قبول الأعضاء
    final currentUserId = sharedPreferences?.getString("id")?.trim();
    if ((chatModel.user == null || chatModel.user?.id == null) &&
        chatModel.userId == null &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      chatModel.userId = int.tryParse(currentUserId);
      chatModel.user = User(id: chatModel.userId);
    }
    if (chatModel.accept == null ||
        chatModel.accept == "null" ||
        chatModel.accept!.isEmpty) {
      chatModel.accept = "1";
    }
    if (chatModel.status == null ||
        chatModel.status == "null" ||
        chatModel.status!.isEmpty) {
      chatModel.status = "Private";
    }

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

  Future<void> firebasemessaginsetting() async {
    try {
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
    } catch (e) {
      log('Firebase requestPermission error: $e');
    }
  }

  /// فحص وطلب إذن الإشعارات - وإذا كان معطلاً يطلب من المستخدم فتحه من الإعدادات
  Future<bool> checkAndRequestNotificationPermission(
      {bool showDialogIfPermanentlyDenied = true}) async {
    try {
      // 1. طلب الصلاحية عبر Firebase Messaging
      await firebasemessaginsetting();

      // 2. فحص الصلاحية في أندرويد (خصوصاً Android 13+)
      final status = await Permission.notification.status;
      log("🔔 Notification permission status: $status");

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final requestStatus = await Permission.notification.request();
        if (requestStatus.isGranted) {
          log("✅ Notification permission granted by user");
          return true;
        } else if (requestStatus.isPermanentlyDenied &&
            showDialogIfPermanentlyDenied) {
          showPermissionSettingsDialog();
          return false;
        }
      } else if (status.isPermanentlyDenied && showDialogIfPermanentlyDenied) {
        showPermissionSettingsDialog();
        return false;
      }
    } catch (e) {
      log("Error checking notification permission: $e");
    }
    return false;
  }

  /// حوار توجيه المستخدم لفتح إعدادات الهاتف لتفعيل الإشعارات
  void showPermissionSettingsDialog() {
    if (Get.context == null) return;
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = pref ?? false;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkcolor : AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppColors.secondaryColor.withOpacity(isDark ? 0.35 : 0.2),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondaryColor.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.secondaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isArabic ? 'تفعيل الإشعارات' : 'Enable Notifications',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color:
                      isDark ? AppColors.whiteColor : AppColors.blackTextColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'إذن الإشعارات معطل في هاتفك. يرجى تفعيله من إعدادات الهاتف لتتمكن من استقبال إشعارات الرسائل والمكالمات الواردة.'
              : 'Notification permission is disabled. Please enable it in system settings to receive message and incoming call notifications.',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            height: 1.5,
            color: isDark ? AppColors.inActiveColor : AppColors.black2TextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              isArabic ? 'لاحقاً' : 'Later',
              style: GoogleFonts.cairo(
                color: AppColors.inActiveColor,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppColors.secondaryColor : AppColors.primaryColor,
              foregroundColor:
                  isDark ? AppColors.primaryColor : AppColors.whiteColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text(
              isArabic ? 'فتح الإعدادات' : 'Open Settings',
              style: GoogleFonts.cairo(
                color: isDark ? AppColors.primaryColor : AppColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}

void showInAppNotificationBanner({
  required String title,
  required String body,
  required VoidCallback onTap,
  Duration duration = const Duration(seconds: 4),
}) {
  final isDark = pref ?? false;
  final currentLang = sharedPreferences?.getString("selectedLanguage") ??
      Get.locale?.languageCode ??
      'ar';
  final isRtl = currentLang == 'ar';

  Get.rawSnackbar(
    snackPosition: SnackPosition.TOP,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1B2319),
              const Color(0xFF111710),
            ]
          : [
              AppColors.primaryColor,
              const Color(0xFF1A2E17),
            ],
    ),
    borderColor: AppColors.secondaryColor.withOpacity(0.45),
    borderWidth: 1.2,
    borderRadius: 16.0,
    margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 16.0,
        offset: const Offset(0, 6),
      ),
    ],
    duration: duration,
    isDismissible: true,
    messageText: Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. أيقونة الإشعار مع مسافة مريحة من الحافة ومن النص
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsetsDirectional.only(end: 12.0),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondaryColor.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.secondaryColor,
              size: 22,
            ),
          ),

          // 2. العنوان والنص مع محاذاة تلقائية حسب اتجاه اللغة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor.withOpacity(0.88),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // 3. زر العرض مع مسافة مريحة من النص ومن الحافة الخارجية
          Container(
            margin: const EdgeInsetsDirectional.only(start: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: AppColors.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14.0, vertical: 6.0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                if (Get.isSnackbarOpen) {
                  Get.closeCurrentSnackbar();
                }
                onTap();
              },
              child: Text(
                isRtl ? 'عرض' : 'View',
                style: GoogleFonts.cairo(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    onTap: (_) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      onTap();
    },
  );
}

void showCustomSnackBar({
  BuildContext? context,
  required String title,
  required String body,
  required VoidCallback onTap,
  Duration duration = const Duration(seconds: 4),
}) {
  showInAppNotificationBanner(
    title: title,
    body: body,
    onTap: onTap,
    duration: duration,
  );
}
