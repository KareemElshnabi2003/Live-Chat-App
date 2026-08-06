import 'package:live_chat/Data/Model/user_chat_model.dart';

class MessageModel {
  int? id;
  int? conversationId;
  int? senderId;
  String? senderName;
  String? senderImage;
  String? message;
  String? messageType;
  List<MessageReactions>? messageReactions;
  String? createdAt;

  MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.message,
    this.messageType,
    this.messageReactions,
    this.createdAt,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    senderImage = json['sender_image'];
    message = json['message'];
    messageType = json['message_type'] ?? 'text';
    if (json['message_reactions'] != null) {
      messageReactions = <MessageReactions>[];
      json['message_reactions'].forEach((v) {
        messageReactions!.add(MessageReactions.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['sender_name'] = senderName;
    data['sender_image'] = senderImage;
    data['message'] = message;
    data['message_type'] = messageType;
    if (messageReactions != null) {
      data['message_reactions'] =
          messageReactions!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    return data;
  }
}

class MessageReactions {
  int? id;
  String? react;
  User? user;

  MessageReactions({this.id, this.react, this.user});

  MessageReactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    react = json['react'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['react'] = react;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
