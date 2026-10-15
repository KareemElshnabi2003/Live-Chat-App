import 'dart:developer';

class NormalizedCallData {
  final bool isGroup;
  final bool isAudio;
  final String callType; // "audio" or "video"
  final String chatId;
  final String callerName;
  final String callerImage;
  final String callerId;
  final String conversationName;
  final String conversationImage;
  final dynamic rawIsGroup;
  final dynamic rawCallType;

  NormalizedCallData({
    required this.isGroup,
    required this.isAudio,
    required this.callType,
    required this.chatId,
    required this.callerName,
    required this.callerImage,
    required this.callerId,
    required this.conversationName,
    required this.conversationImage,
    required this.rawIsGroup,
    required this.rawCallType,
  });
}

class CallDataHelper {
  /// يقوم بتحليل وتوحيد بيانات المكالمة من أي مصدر (FCM / Pusher / Notification)
  /// مع طباعة القيم الخام ونوعها والقيم المعالجة في اللوج بدقة
  static NormalizedCallData normalizeCallData(Map<dynamic, dynamic> data, {String source = "FCM"}) {
    final rawIsGroup = data['is_group'] ?? data['isGroup'] ?? data['is_groub'] ?? data['isGroub'];
    final rawCallType = data['call_type'] ?? data['callType'] ?? data['type'];

    // 1. تفسير isGroup بكل الصيغ الممكنة (boolean, number, string)
    bool isGroup = false;
    if (rawIsGroup != null) {
      if (rawIsGroup is bool) {
        isGroup = rawIsGroup;
      } else if (rawIsGroup is num) {
        isGroup = rawIsGroup != 0;
      } else {
        final str = rawIsGroup.toString().trim().toLowerCase();
        isGroup = str == '1' || str == 'true' || str == 'yes' || str == 'group' || str == 'public';
      }
    } else {
      final chatStatus = (data['chat_status'] ?? data['status'] ?? data['conversation_type'])?.toString().toLowerCase();
      if (chatStatus == 'public' || chatStatus == 'group') {
        isGroup = true;
      }
    }

    // 2. تفسير callType و isAudio
    String callType = 'audio';
    bool isAudio = true;
    if (rawCallType != null) {
      final str = rawCallType.toString().trim().toLowerCase();
      if (str.contains('video')) {
        callType = 'video';
        isAudio = false;
      } else if (str.contains('audio') || str.contains('voice')) {
        callType = 'audio';
        isAudio = true;
      }
    }

    final chatId = (data['conversation_id'] ?? data['chat_id'] ?? data['conversationId'] ?? data['id'] ?? '').toString();
    final callerId = (data['caller_id'] ?? data['sender_id'] ?? data['user_id'] ?? '').toString();
    final callerName = (data['caller_name'] ?? data['sender_name'] ?? data['name'] ?? 'Unknown').toString();
    final callerImage = (data['caller_image'] ?? data['sender_image'] ?? data['image'] ?? '').toString();
    final conversationName = (data['conversation_name'] ?? data['group_name'] ?? data['title'] ?? '').toString();
    final conversationImage = (data['conversation_image'] ?? data['group_image'] ?? '').toString();

    // 📊 طباعة القيم الخام والمفسرة للتتبع الدقيق
    log('📞 [$source CALL DATA NORMALIZED] rawIsGroup: "$rawIsGroup" (${rawIsGroup?.runtimeType}) -> isGroup: $isGroup | rawCallType: "$rawCallType" (${rawCallType?.runtimeType}) -> isAudio: $isAudio | chatId: "$chatId" | callerName: "$callerName" | callerId: "$callerId"');

    return NormalizedCallData(
      isGroup: isGroup,
      isAudio: isAudio,
      callType: callType,
      chatId: chatId,
      callerName: callerName,
      callerImage: callerImage,
      callerId: callerId,
      conversationName: conversationName,
      conversationImage: conversationImage,
      rawIsGroup: rawIsGroup,
      rawCallType: rawCallType,
    );
  }
}
