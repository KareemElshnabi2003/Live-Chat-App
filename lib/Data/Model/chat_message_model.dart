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
  });
}
//endregion