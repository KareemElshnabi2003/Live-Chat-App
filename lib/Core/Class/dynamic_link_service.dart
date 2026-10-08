import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Data/DataSource/chats_source.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/View/Screens/create%20chat/chat_view.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';

class DynamicLinkService {
  static final _appLinks = AppLinks();

  /// Since standard App Links don't require an API call to generate a short link,
  /// we can just return the deep link directly.
  static String createDynamicLink(String chatId) {
    return 'https://ngoumapp.com/chat?id=$chatId';
  }

  static void initDynamicLinks() async {
    try {
      // Handle link when app is in background/foreground
      _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      }).onError((error) {
        log('onLink error: $error');
      });

      // Handle link when app is terminated
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      log('Error initializing app links: $e');
    }
  }

  static void _handleDeepLink(Uri deepLink) {
    if (deepLink.path == '/chat') {
      String? id = deepLink.queryParameters['id'];
      if (id != null) {
        // Navigate to the chat page and pass the ID
        Future.delayed(const Duration(milliseconds: 500), () async {
          // Check if we need to request to join
          if (Get.isRegistered<HomeNavigationController>()) {
            final homeCtrl = Get.find<HomeNavigationController>();
            bool joined = await homeCtrl.joinToChat(chatId: id);
            if (!joined) return; // Wait for approval or error
          } else {
            // Fallback if HomeNavigatorController is not registered
            try {
              final chatsData = Get.find<ChatsRemoteData>();
              var response = await chatsData.joinToCgat(chatId: id);
              if (response is Map && response['status'] == 'forbiddenException') {
                Get.snackbar(
                  S.current.underReview,
                  S.current.waitForAccept,
                  backgroundColor: Colors.orange.shade600,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
                return;
              }
            } catch (e) {
              log("join fallback error $e");
            }
          }

          // Provide a dummy UserChatModel to prevent UI crashes.
          // ChatController will fetch messages and handle everything else based on chatId.
          final dummyModel = UserChatModel(
            id: int.parse(id),
            name: "Loading...",
            image: "null",
            status: "Friends", 
            accept: "1",
            adTitle: "",
            adLink: "",
            adImage: "",
            chatLink: "",
          );

          Get.to(() => ChatView(
            userChatModel: dummyModel,
            isPin: false,
            isGust: false,
          ), arguments: {"chatId": id});
        });
      }
    }
  }
}

//if he nit sign to aap he must sign first you tell him he must login ND THE GO TO chat 