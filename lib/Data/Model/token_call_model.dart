// ignore_for_file: unnecessary_this, prefer_collection_literals, unnecessary_new

import 'package:live_chat/Data/Model/user_chat_model.dart';

class TokenCallModel {
  int? uid;
  String? token;
  String? channel;
  UserChatModel? conversation;
  String? expireAt;

  TokenCallModel(
      {this.uid, this.token, this.channel, this.conversation, this.expireAt});

  TokenCallModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    token = json['token'];
    channel = json['channel'];
    conversation = json['conversation'] != null
        ? new UserChatModel.fromJson(json['conversation'])
        : null;
    expireAt = json['expire_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['token'] = this.token;
    data['channel'] = this.channel;
    if (this.conversation != null) {
      data['conversation'] = this.conversation!.toJson();
    }
    data['expire_at'] = this.expireAt;
    return data;
  }
}
