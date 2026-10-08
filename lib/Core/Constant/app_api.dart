class AppApi {
  static const String baseUrl = "https://api.mayo.live/api/v1";


  static const String getAds = "$baseUrl/admin_ads";
  static const String privacyPolicy = "$baseUrl/pages/privacy-policy";
  static const String terms = "$baseUrl/pages/terms-conditions";
  static const String adsWithUs = "$baseUrl/pages/admin-ads";
  static const String pinChat = "$baseUrl/pinned-conversations";
  static const String checkCallUrl = "$baseUrl/status";
  static const String endCallUrl = "$baseUrl/end";
  static const String blockUrl = "$baseUrl/users";
  static const String getTokenCallUrl = "$baseUrl/generate-token";
  static const String changeThemeUrl = "$baseUrl/auth/change-mobile-theme";
  static const String getRadiosUrl = "$baseUrl/radios";
  static const String sendStars = "$baseUrl/send-stars";

  //AUth
  static const String loginUrl = "$baseUrl/auth/login";
  static const String registerUrl = "$baseUrl/auth/register";
  static const String checkOTPUrl = "$baseUrl/auth/check-otp";
  static const String sendOTPUrl = "$baseUrl/auth/send-otp";
  static const String resendOTPUrl = "$baseUrl/auth/resend-otp";
  static const String logoutUrl = "$baseUrl/auth/logout";
  static const String gustUrl = "$baseUrl/auth/verify-guest-user";
  //Profile
  static const String deleteAccUrl = "$baseUrl/auth/delete-account";
  static const String getProfileUrl = "$baseUrl/auth/get-profile";
  static const String updateProfileUrl = "$baseUrl/auth/update-profile";
  static const String getUserPower = "$baseUrl/user_powers";
  static const String storePower = "$baseUrl/store-powers";
  static const String stores = "$baseUrl/stores";
//Send request
  static const String sendFriendRequestUrl = "$baseUrl/send-friend-request";
  static const String removeFriendUrl = "$baseUrl/remove-friend";

  static const String acceptOrRejectFriendUrl = "$baseUrl/reply-on-friend";
  static const String acceptMemberToChat = "$baseUrl/accept-members";
  //Notification
  static const String getNotificationUrl = "$baseUrl/get-user-notifications";
  //craete chat friend& global & deleet &update
  static const String createChatUrl = "$baseUrl/conversations";
  static const String createChatFriendUrl = "$baseUrl/conversations-friend";

  //Chat
  static const String storeChatUrl = "$baseUrl/conversations";
  static const String getSuggerstFriendesUrl =
      "$baseUrl/get-friend-recommendations";
  static const String getMemberChatUrl = "$baseUrl/get-conversation-members";
  static const String getFriendesUrl = "$baseUrl/get-user-friends";
  static const String getGeneralChatsUrl = "$baseUrl/get-general-conversation";
  static const String getRecentChatsUrl = "$baseUrl/get-recent-conversations";
  static const String getSystemChatUrl = "$baseUrl/get-system-conversations";
  static const String getPinedChat = "$baseUrl/pinned-conversations";
  static const String updateChatUrl =
      "$baseUrl/conversations"; //3==> update 3 id chat
  static const String deleteChatUrl =
      "$baseUrl/conversations"; //3==>delete 3 id chatt
  static const String getUsersChatUrl = "$baseUrl/get-user-conversations";
  static const String joinChatUrl =
      "$baseUrl/join-to-conversation"; //2 ==> chat you want gto join
  static const String getChatBySlugUrl =
      "$baseUrl/conversations/{islamwalied96-at-gmailc-1}"; //by slug
  static const String getMessagesChatUrl =
      "$baseUrl/get-messages-by-conversation-id"; //1==> id chat
  static const String sendMessagesUrl = "$baseUrl/messages";
  static const String reactToMessageUrl = "$baseUrl/message-reactions";
//get thems
  static const String getThemsUrl = "$baseUrl/chat-themes";
  static const String getAvailableTime = "$baseUrl/available-time-slots";

  //Payment
}
