//region ChatMessage Model
import 'package:live_chat/Data/Model/message_model.dart';

class ChatMessage {
  final String message;
  final bool isFromSender;
  final String timestamp;
  final String? imageUrl;
  final String? senderName;
  final String messageId;
  final List<MessageReactions> reaction;
  final String messageType;
  final bool isPending;
  final bool isRead;

  ChatMessage({
    required this.senderName,
    required this.message,
    required this.isFromSender,
    required this.timestamp,
    required this.imageUrl,
    required this.reaction,
    required this.messageId,
    required this.messageType,
    required this.isPending,
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? senderName,
    String? message,
    bool? isFromSender,
    String? timestamp,
    String? imageUrl,
    List<MessageReactions>? reaction,
    String? messageId,
    String? messageType,
    bool? isPending,
    bool? isRead,
  }) {
    return ChatMessage(
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      isFromSender: isFromSender ?? this.isFromSender,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      reaction: reaction ?? this.reaction,
      messageId: messageId ?? this.messageId,
      messageType: messageType ?? this.messageType,
      isPending: isPending ?? this.isPending,
      isRead: isRead ?? this.isRead,
    );
  }
}
//endregion