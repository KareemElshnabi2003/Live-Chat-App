import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';

class SuggestFreindModel {
  int? id;
  String? name;
  String? username;
  String? image;
  String? requestStatus;
  PowerModel? power;
  String? isBlocked;
  int? conversationId;
  LastMessage? lastMessage;

  SuggestFreindModel({
    this.id,
    this.name,
    this.username,
    this.image,
    this.requestStatus,
    this.power,
    this.isBlocked,
    this.conversationId,
    this.lastMessage,
  });

  SuggestFreindModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    image = json['image'];
    requestStatus = json['request_status'];
    power = json['power'] != null ? PowerModel.fromJson(json['power']) : null;
    isBlocked = json['is_blocked'];
    if (json['conversation_id'] != null) {
      conversationId = int.tryParse(json['conversation_id'].toString());
    } else if (json['last_message'] != null && json['last_message']['conversation_id'] != null) {
      conversationId = int.tryParse(json['last_message']['conversation_id'].toString());
    }
    if (json['last_message'] != null && json['last_message'] is Map<String, dynamic>) {
      lastMessage = LastMessage.fromJson(json['last_message']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['image'] = image;
    data['request_status'] = requestStatus;
    if (power != null) {
      data['power'] = power!.toJson();
    }
    data['is_blocked'] = isBlocked;
    data['conversation_id'] = conversationId;
    if (lastMessage != null) {
      data['last_message'] = lastMessage!.toJson();
    }
    return data;
  }
}
